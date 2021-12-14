# ECS cluster has been set up with TF ? So now it's time to deploy a real application.



# First step : Build a dummy application (folder demo_application)
# This application is a simple rack app that will display information on the EC2 instance that host the container.
cd demo_application
docker build -f Dockerfile -t yoshyn/demo-application .
docker push yoshyn/demo-application:latest

# Second Step : Create an ECS task
set REGION "eu-west-1"
set PROJECT_NAME "DEMO"
set ENV "test"
set DEFINITION_PREFIX "Artikodin"
set CONTAINER_NAME "demo-web-app"
set CONTAINER_PORT 8080
set CONTAINER_IMAGE "yoshyn/demo-application:latest"
set TASK_DEFINITION "$DEFINITION_PREFIX-$CONTAINER_NAME"
set DB_NAME "demo_application_db"

# The ECS role that will be associated to the task. Include policy for cloudwatch & for secret manager (for database secret)
set ECS_TASK_ROLE_NAME $PROJECT_NAME"-"$ENV"-ecs-task-execution-role"
set ECS_TASK_ROLE_ARN (aws iam list-roles --region $REGION --query "Roles[?(RoleName == '$ECS_TASK_ROLE_NAME')].Arn" --output text)

set RDS_CREDENTIALS_ARN (aws secretsmanager list-secrets --region $REGION --filters "Key=name,Values=/$PROJECT_NAME/$ENV/database/credentials" --query "SecretList[].ARN" --output text)

# Family is the name of the resource. But this resource are create with a sequential number on aws side
env -i bash -c "cat > ./$TASK_DEFINITION-task.json << EOF
{
  \"family\": \"$TASK_DEFINITION\",
  \"executionRoleArn\": \"$ECS_TASK_ROLE_ARN\",
  \"containerDefinitions\": [
    {
      \"name\": \"$CONTAINER_NAME\",
      \"image\": \"$CONTAINER_IMAGE\",
      \"cpu\": 128,
      \"memoryReservation\": 128,
       \"logConfiguration\": { 
          \"logDriver\": \"awslogs\",
          \"options\": { 
             \"awslogs-group\" : \"/ecs/$TASK_DEFINITION-container\",
             \"awslogs-region\": \"$REGION\",
             \"awslogs-stream-prefix\": \"ecs\",
             \"awslogs-create-group\": \"true\"
          }
       },
      \"portMappings\": [
        {
          \"containerPort\": $CONTAINER_PORT,
          \"protocol\": \"tcp\"
        }
      ],
      \"essential\": true,
      \"environment\": [
        {
          \"name\": \"CUSTOM_VALUE\",
          \"value\": \"WILL_BE_SET\"
        },
        {
          \"name\": \"DB_NAME\",
          \"value\": \"$DB_NAME\"
        }
      ],
      \"secrets\": [
        { 
          \"name\": \"PGHOST\",
          \"valueFrom\": \"$RDS_CREDENTIALS_ARN:host::\" 
        },
        { 
          \"name\": \"PGPORT\",
          \"valueFrom\": \"$RDS_CREDENTIALS_ARN:port::\" 
        },
        { 
          \"name\": \"PGUSER\",
          \"valueFrom\": \"$RDS_CREDENTIALS_ARN:username::\" 
        },
        { 
          \"name\": \"PGPASSWORD\",
          \"valueFrom\": \"$RDS_CREDENTIALS_ARN:password::\" 
        }
      ]
    }
  ]
}
EOF"

aws ecs register-task-definition --cli-input-json file://$TASK_DEFINITION-task.json --region $REGION
# aws ecs list-task-definitions --region $REGION
# Note, it's not possible to remove a task but you can deregister it.
# aws ecs deregister-task-definition --task-definition my-task:1
# Check also : https://stackoverflow.com/questions/35045264/how-do-you-delete-an-aws-ecs-task-definition

# Step three : Create the service inside the esc cluster that will handle the task.


set SERVICE_NAME "$DEFINITION_PREFIX-$CONTAINER_NAME"

set LOAD_BALANCER_ARN (aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[?(LoadBalancerName == '$PROJECT_NAME-ecs-alb')].[LoadBalancerName,DNSName,LoadBalancerArn]" | jq -r 'first | last')
set LOAD_BALANCER_TARGET_GROUP_ARN (aws elbv2 describe-target-groups --load-balancer-arn $LOAD_BALANCER_ARN --region $REGION --query "TargetGroups[?(Protocol=='HTTP')].[TargetGroupArn]" | jq -r 'first | first')

# This role came from TF (modules/ecs_cluster/main.tf:228)
set ECS_SERVICE_ROLE_NAME "ecs-srv-execution-role"
# Check if it exist : aws iam list-roles --region $REGION --query "Roles[?(RoleName == '$ECS_SERVICE_ROLE_NAME')]"

set CLUSTER_ARN (aws ecs list-clusters --region $REGION --query "clusterArns[?contains(@, 'DEMO')]" | jq -r 'first')
set CLUSTER_NAME (echo $CLUSTER_ARN | awk -F  "/" '{print $2}')

# Dummy desired_count set to the number of instance. Well. Why not ?
set DESIRED_COUNT (aws ecs describe-clusters --cluster $CLUSTER_NAME --region $REGION --query "clusters[].registeredContainerInstancesCount" | jq -r 'first')

env -i bash -c "cat > ./$SERVICE_NAME-service.json << EOF
{
    \"cluster\": \"$CLUSTER_NAME\",
    \"serviceName\": \"$SERVICE_NAME\",
    \"taskDefinition\": \"$TASK_DEFINITION\",
    \"loadBalancers\": [
        {
            \"targetGroupArn\": \"$LOAD_BALANCER_TARGET_GROUP_ARN\",
            \"containerName\": \"$CONTAINER_NAME\",
            \"containerPort\": $CONTAINER_PORT
        }
    ],
    \"desiredCount\": $DESIRED_COUNT,
    \"role\": \"$ECS_SERVICE_ROLE_NAME\"
}
EOF"

aws ecs create-service --cli-input-json file://$SERVICE_NAME-service.json --region $REGION

# /!\ To run before a terraform destroy !
# aws ecs delete-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --region $REGION --force

# Step 4 : Let's check that everything work : 
open "http://"(aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[?(LoadBalancerName == '$PROJECT_NAME-ecs-alb')].[DNSName] | [0][0]" --out text)
# Note : If you refresh often, the instance_id will change. The ALB work well.



# Step 5 : Update a service
# 1 -> recreate the task (even if there's no change inside the task cause you use the same tag for the image !)
# 2 -> update the service : aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_DEFINITION --region $REGION



# Step 5 : Run a standalone task without recreate a new task. Example here with simulation of db:create & db:seed

env -i bash -c "cat > ./db-create-task-overrides.json << EOF
{
   \"containerOverrides\":[
      {
         \"name\":\"$CONTAINER_NAME\",
         \"command\":[
            \"/bin/sh\",
            \"-c\",
            \"psql -c 'CREATE DATABASE $DB_NAME'\"
         ]
      }
   ]
}
EOF"
aws ecs run-task --region $REGION --cluster $CLUSTER_NAME --overrides file://db-create-task-overrides.json --task-definition $TASK_DEFINITION

env -i bash -c "cat > ./db-seeds-task-overrides.json << EOF
{
   \"containerOverrides\":[
      {
         \"name\":\"$CONTAINER_NAME\",
         \"command\":[
            \"/bin/sh\",
            \"-c\",
            \"psql -d $DB_NAME -f /usr/src/app/schema.sql\"
         ]
      }
   ]
}
EOF"
aws ecs run-task --region $REGION --cluster $CLUSTER_NAME --overrides file://db-seeds-task-overrides.json --task-definition $TASK_DEFINITION



# Step 6 : Going deeper. Debug, connnect to the container....

# Get ECS with the aws cli
# set INSTANCES_ARNS (aws ecs list-container-instances --cluster $CLUSTER_NAME --query 'containerInstanceArns[*]' --region $REGION | jq -r 'join(" ")')
# for instance_arn in (string split ' ' $INSTANCES_ARNS); 
#   set INSTANCE_ID (aws ecs describe-container-instances --cluster $CLUSTER_NAME --container-instances $instance_arn --output text --query 'containerInstances[*].ec2InstanceId' --region $REGION)
#   set PRV_DNS_NAME (aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[*].Instances[*].PrivateDnsName' --region $REGION)
#   echo "$INSTANCE_ID: $PRV_DNS_NAME"
#   set tasks (aws ecs list-tasks --cluster $CLUSTER_NAME --container-instance $instance_arn --query 'taskArns[*]' --region $REGION  | jq -r 'join(" ")')
#   for task in (string split ' ' $tasks); 
#   set TASK_INFO (aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $task  --output text --query 'tasks[*].{Status:lastStatus,Name:taskDefinitionArn}' --region $REGION)
#   echo $TASK_INFO | cut -d'/' -f 2
#   end
# end

# Once you've go the list of instance, you can connect directly on it with ssm.
# > aws ssm start-session --target $INSTANCE_ID --region eu-west-1
# Then you can use docker like usual
# > sudo docker ps -a
# > sudo docker exec -it 80ffcdee24b5 sh

# The task that are started are also configured to use CloudWatch. You can also consult it with the aws console.
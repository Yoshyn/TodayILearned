## Connect to Bastion (SSH) <- JUST for demo. Should not exist in production usage
output "bastion_ssh_session" {
  value = "ssh -i ~/.ssh/bastion-${var.project_name}-key-pair.pem -p 22 ec2-user@${module.bastion.public_ip}"
}

## Connect to Bastion (SSM)
output "bastion_ssm_session" {
  value = "aws ssm start-session --target ${module.bastion.id} --region ${var.region}"
}

## Connect to Database (SSH & psql)
output "rds_session" {
  value = nonsensitive(<<EOF
    # First let's start a ssh tunnel through the bastion
    ssh -i ~/.ssh/bastion-${var.project_name}-key-pair.pem -p 22 -L '*:5432:${module.database.address}:${module.database.port}' ec2-user@${module.bastion.public_ip}
    # Then retrieve rds credential stored in secret manager
    aws secretsmanager get-secret-value --secret-id '/${var.project_name}/${var.environment}/database/credentials' --region ${var.region} | jq -r '.SecretString' | jq
    # Finaly launch psql (through docker if not installed)
    docker run -it --rm postgres:latest psql -h host.docker.internal -p 5432 -U ${module.database.username}
  EOF
  )
}

## Connect to ECS nodes (SSM) :
# Please check deploy.fish to find more usefull command.
output "ecs_ssm_session" {
  value = <<EOF
    set ECS_NODES (aws ec2 describe-instances --region ${var.region} --filters 'Name=tag:Project,Values=${var.project_name}' 'Name=tag:module,Values=ecs-cluster' 'Name=tag:Env,Values=${var.environment}' 'Name=instance-state-name,Values=running' --query 'Reservations[].Instances[].{InstanceId:InstanceId, PrivateDnsName:PrivateDnsName}')
    set INSTANCE_ID (echo $ECS_NODES | jq -r 'first.InstanceId')
    aws ssm start-session --target $INSTANCE_ID --region ${var.region}
  EOF
}

output "ecs_load_balancer_dns" {
  value = module.ecs_cluster.load_balancer_dns
}

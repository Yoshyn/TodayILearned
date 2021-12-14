###########################################################################
### This role/profile will be associated to a aws_launch_configuration. ###
###########################################################################

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })

  tags = {
    Name   = "EcsInstanceRole"
    module = "ecs-cluster"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attachment_ec2" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attachment_ssm" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name

  tags = {
    Name   = "EcsInstanceProfile"
    module = "ecs-cluster"
  }
}


######################################################
### This role will be associated to a ecs service. ###
######################################################

resource "aws_iam_role" "ecs_srv_execution_role" {
  name = "ecs-srv-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs.amazonaws.com" }
      }
    ]
  })

  tags = {
    Name   = "EcsExecutionRole"
    module = "ecs-cluster"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_srv_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_srv_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}


###################################################
### This role will be associated to a ecs task. ###
###################################################

data "aws_secretsmanager_secret" "database_credentials" {
  name = "/${var.project_name}/${var.environment}/database/credentials"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })

  inline_policy {
    name = "${var.project_name}-${var.environment}-ecs-task-database-credentials_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "secretsmanager:GetSecretValue"
          Resource = [data.aws_secretsmanager_secret.database_credentials.arn]
        },
        {
          Effect   = "Allow",
          Action   = ["logs:CreateLogGroup"],
          Resource = "arn:aws:logs:*:*:*"
        }
      ]
    })
  }

  tags = {
    Name   = "EcsTaskExecutionRole"
    module = "ecs-cluster"
  }
}

# This Policiy include CloudWatch logs:CreateLogStream & logs:PutLogEvents and ecr right to fetch an image.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

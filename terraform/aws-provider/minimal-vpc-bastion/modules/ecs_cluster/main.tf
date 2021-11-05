resource "aws_ecs_cluster" "main" {
  name = "${var.global_name}-${var.environment}"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.global_name}-ecs-cluster"
    environment = "${var.environment}"
    module      = "ecs-cluster"
    Automation  = "Terraform"
  }
}

#
# IAM
#

# Docs
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
# Amazon EC2 run the Amazon ECS container agent and require an IAM role for
# the service to know that the agent belongs to you. Before you launch
# container instances and register them to a cluster, you must create an IAM
# role for your container instances to use.

data "aws_iam_policy_document" "ec2_execution_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aiip_ec2_execution_role" {
  name               = "ec2-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_execution_policy.json

  tags = {
    Name        = "${var.global_name}-aiip-ec2-execution-role"
    environment = "${var.environment}"
    module      = "ecs-cluster"
    Automation  = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "aiip_ec2_execution_role" {
  role       = aws_iam_role.aiip_ec2_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_instance_profile" "alc_ec2_execution_profile" {
  name = "ec2-execution-profile"
  role = aws_iam_role.aiip_ec2_execution_role.name

  tags = {
    Name        = "${var.global_name}-alc-ec2-execution-profile"
    environment = "${var.environment}"
    module      = "ecs-cluster"
    Automation  = "Terraform"
  }
}

#
# Security Group
#

resource "aws_security_group" "internal_only" {
  name        = "${var.global_name}-internal_only-sg"
  description = "Allow internal traffic to docker servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.global_name}-internal_only-sg"
    environment = "${var.environment}"
    module      = "ecs-cluster"
    Automation  = "Terraform"
  }
}

resource "aws_security_group" "http_access" {
  name        = "${var.global_name}-http-access-sg"
  description = "Allow external traffic to port 80 & 443"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.global_name}-http-access-sg"
    environment = "${var.environment}"
    module      = "ecs-cluster"
    Automation  = "Terraform"
  }
}

#
# EC2
#

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_launch_configuration" "ecs_instance_cfg" {
  name_prefix          = format("%s-ecs_instance_cfg", var.global_name)
  iam_instance_profile = aws_iam_instance_profile.alc_ec2_execution_profile.name

  instance_type               = "t3.micro"
  image_id                    = data.aws_ami.ecs_ami.image_id
  associate_public_ip_address = false
  security_groups             = [aws_security_group.internal_only.id]

  root_block_device {
    volume_type = "standard"
  }

  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "standard"
    encrypted   = true
  }

  user_data = <<EOF
#!/bin/bash
# The cluster this agent should check into.
echo 'ECS_CLUSTER=${aws_ecs_cluster.main.name}' >> /etc/ecs/ecs.config
# Disable privileged containers.
echo 'ECS_DISABLE_PRIVILEGED=true' >> /etc/ecs/ecs.config
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name = "${var.global_name}-ecs-asg"

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestLaunchConfiguration", "Default"]

  launch_configuration = aws_launch_configuration.ecs_instance_cfg.id

  vpc_zone_identifier = var.private_subnets_ids

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      "key"                 = "environment"
      "value"               = var.environment
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Cluster"
      "value"               = "${var.global_name}-${var.environment}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "module"
      "value"               = "ecs-cluster"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Automation"
      "value"               = "Terraform"
      "propagate_at_launch" = true
    },
  ]
}

data "aws_iam_policy_document" "ecs_task_exection_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_exection_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exection_role_policy.json

  tags = {
    Name        = "${var.global_name}-ecs-instance-role"
    environment = "${var.environment}"
    module      = "ecs-cluster"
    Automation  = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exection_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_exection_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_lb" "ecs_alb" {
  name               = "${var.global_name}-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_only.id, aws_security_group.http_access.id]
  subnets            = var.public_subnets_ids


  drop_invalid_header_fields = true
  idle_timeout               = 60

  enable_deletion_protection = false
  enable_http2               = true

  tags = {
    Name        = "${var.global_name}-ecs-alb"
    environment = "${var.environment}"
    module      = "ecs-cluster"
    Automation  = "Terraform"
  }
}

resource "aws_alb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn

  port     = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ecs_web_target_group.arn
    type             = "forward"
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_alb_target_group" "ecs_web_target_group" {
  name     = "${var.global_name}-ecs-web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name        = "${var.global_name}-ecs-web-target-group"
    environment = "${var.environment}"
    module      = "ecs-cluster"
    Automation  = "Terraform"
  }
}

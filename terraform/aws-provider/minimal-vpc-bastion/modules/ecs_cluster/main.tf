locals {
  cluster_name = "${var.global_name}-${var.environment}"
}

#
# ECS
#

resource "aws_ecs_cluster" "main" {
  name = local.cluster_name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.global_name}-ecs"
    environment = "${var.environment}"
    module      = "ecs"
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

data "aws_iam_policy_document" "ec2_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_instance_assume_role" {
  name               = "ec2_instance_assume_role-${local.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_assume_role_policy.json

  tags = {
    Name        = "${var.global_name}-ec2_instance_assume_role"
    environment = "${var.environment}"
    module      = "ecs"
    Automation  = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_instance_assume_role_policy_attachment" {
  role       = aws_iam_role.ec2_instance_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_instance_assume_role.name
}

#
# Security Group
#

resource "aws_security_group" "internal_only_docker" {
  name        = "${var.global_name}-internal_only_docker"
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
    Name        = "${var.global_name}-internal-only-docker-sg"
    environment = "${var.environment}"
    module      = "ecs"
    Automation  = "Terraform"
  }
}

resource "aws_security_group" "outbound_internet_access" {
  name        = "${var.global_name}-outbound_internet_access"
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
    Name        = "${var.global_name}-external-web-sg"
    environment = "${var.environment}"
    module      = "ecs"
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

resource "aws_launch_configuration" "docker_launch_cfg" {
  name_prefix          = format("ecs-%s-", local.cluster_name)
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  instance_type               = "t3.micro"
  image_id                    = data.aws_ami.ecs_ami.image_id
  associate_public_ip_address = false
  security_groups             = ["${aws_security_group.internal_only_docker.id}"]

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

data "aws_vpc" "vpc" {
  id = var.vpc_id
}


resource "aws_autoscaling_group" "docker_asg" {
  name = "ecs-${local.cluster_name}"

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestLaunchConfiguration", "Default"]

  launch_configuration = aws_launch_configuration.docker_launch_cfg.id

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
      "value"               = local.cluster_name
      "propagate_at_launch" = true
    },
    {
      "key"                 = "module"
      "value"               = "ecs"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Automation"
      "value"               = "Terraform"
      "propagate_at_launch" = true
    },
  ]
}

data "aws_iam_policy_document" "ecs_service_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_service_assume_role" {
  name               = "ecs_service_assume_role-${local.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_assume_role_policy.json

  tags = {
    Name        = "${var.global_name}-ecs-instance-role"
    environment = "${var.environment}"
    module      = "ecs"
    Automation  = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service_assume_role_policy_attachment" {
  role       = aws_iam_role.ecs_service_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "template_file" "web_task_definition" {
  template = file("${path.module}/web.json")
}

resource "aws_ecs_task_definition" "web" {
  family                = "web"
  container_definitions = data.template_file.web_task_definition.rendered
}

resource "aws_ecs_service" "web" {
  name            = "web"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = "1"
  iam_role        = aws_iam_role.ecs_service_assume_role.name

  load_balancer {
    elb_name       = aws_elb.web.id
    container_name = "nginx"
    container_port = 80
  }

  tags = {
    Name        = "${var.global_name}-ecs-service-web"
    environment = "${var.environment}"
    module      = "ecs"
    Automation  = "Terraform"
  }
}

# Update subnets
resource "aws_elb" "web" {
  name            = "web"
  subnets         = var.public_subnets_ids
  security_groups = ["${aws_security_group.internal_only_docker.id}", "${aws_security_group.outbound_internet_access.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # Exercise to reader to setup 443

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing = true
  idle_timeout              = 60

  tags = {
    Name        = "${var.global_name}-web-elb"
    environment = "${var.environment}"
    module      = "ecs"
    Automation  = "Terraform"
  }
}

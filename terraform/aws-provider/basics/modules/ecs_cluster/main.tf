resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name   = "ElasticContainerServiceCluster"
    module = "ecs-cluster"
  }
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_configuration" "ecs_instance_cfg" {
  name_prefix          = "${var.project_name}-${var.environment}-ecs-cfg-"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  instance_type               = "t3.micro"
  image_id                    = data.aws_ami.ecs_ami.image_id
  associate_public_ip_address = false
  security_groups             = [aws_security_group.internal_only.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp3"
    volume_size = 40
    encrypted   = true
  }

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html  
  user_data = <<EOF
    #!/bin/bash
    sudo yum update -y
    cat << EOCAT > /etc/ecs/ecs.config
    ECS_CLUSTER=${aws_ecs_cluster.main.name}
    ECS_DATADIR=/data
    ECS_DISABLE_PRIVILEGED=true
    ECS_ENABLE_CONTAINER_METADATA=true
    ECS_ENABLE_TASK_IAM_ROLE=true
    ECS_LOGFILE=/log/ecs-agent.log
    ECS_CONTAINER_INSTANCE_PROPAGATE_TAGS_FROM=ec2_instance
    EOCAT
  EOF
  # Also available : ECS_CONTAINER_INSTANCE_TAGS={"tag_key": "tag_value"}

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_default_tags" "default" {}

resource "aws_autoscaling_group" "ecs_asg" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-asg-"

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

  dynamic "tag" {

    for_each = merge(data.aws_default_tags.default.tags, {
      Name   = "EcsInstanceFromAutoScalingGroup",
      module = "ecs-cluster"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

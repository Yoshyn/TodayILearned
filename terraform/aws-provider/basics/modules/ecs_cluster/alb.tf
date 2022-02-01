data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_lb" "ecs_alb" {
  name               = "${var.project_name}-${var.environment}-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_only.id, aws_security_group.http_access.id]
  subnets            = var.public_subnets_ids


  drop_invalid_header_fields = true
  idle_timeout               = 60

  enable_deletion_protection = false
  enable_http2               = true

  tags = {
    Name   = "AlbForEcs"
    module = "ecs-cluster"
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

resource "aws_alb_target_group" "ecs_web_target_group" {
  name     = "${var.project_name}-ecs-web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name   = "WebTargetGroupForEcs"
    module = "ecs-cluster"
  }
}


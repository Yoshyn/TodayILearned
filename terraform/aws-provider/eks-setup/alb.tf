resource "aws_lb" "eks_alb" {
  name               = "${local.cluster_name}-eks-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id, aws_security_group.http_access.id]
  subnets            = module.vpc.public_subnets


  drop_invalid_header_fields = true
  idle_timeout               = 60

  enable_deletion_protection = false
  enable_http2               = true
}

resource "aws_alb_listener" "eks_alb_listener" {
  load_balancer_arn = aws_lb.eks_alb.arn

  port     = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.eks_web_target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group" "eks_web_target_group" {
  name     = "${local.cluster_name}-eks-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/nginx-health"
  }
}

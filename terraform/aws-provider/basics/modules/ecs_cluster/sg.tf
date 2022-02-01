resource "aws_security_group" "internal_only" {
  name        = "${var.project_name}-${var.environment}-ecs-internal-only-sg"
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
    Name   = "EcsInternalOnlySecurityGroup"
    module = "ecs-cluster"
  }
}

resource "aws_security_group" "http_access" {
  name        = "${var.project_name}-${var.environment}-http-access-sg"
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
    Name   = "HttpAccessSecurityGroup"
    module = "ecs-cluster"
  }
}

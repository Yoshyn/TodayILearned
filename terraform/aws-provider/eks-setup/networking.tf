data "aws_availability_zones" "available" {}

# Terraform module which creates VPC resources on AWS
# Instead of aws_vpc by provider aws
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "${local.cluster_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# data "http" "myip" {
#   url = "https://checkip.amazonaws.com"
# }

resource "aws_security_group" "default" {
  name   = "${local.cluster_name}-Default"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  # Is it needed ? 
  # ingress {
  #   from_port   = "22"
  #   to_port     = "22"
  #   protocol    = "tcp"
  #   cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http_access" {
  name        = "${local.cluster_name}-http-access-sg"
  description = "Allow external traffic to port 80 & 443"
  vpc_id      = module.vpc.vpc_id

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
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

resource "aws_iam_role" "ssm_instance_role" {
  name        = "${local.cluster_name}-ssm_instance_role"
  description = "SSM role for EC2 resources"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "assume_role_policy_document" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_instance_role.name

  tags = {
    Name   = "SsmInstanceProfile"
    module = "networking"
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.default.id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  root_block_device {
    volume_type = "gp3"
    volume_size = 12
  }

  user_data = <<-EOL
    #!/bin/bash -xe
    sudo yum update -y
    sudo yum install -y nc
  EOL

  tags = {
    Name = "bastion-${local.cluster_name}"
  }
}

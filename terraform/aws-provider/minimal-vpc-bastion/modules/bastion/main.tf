resource "tls_private_key" "bastion_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Amazon EC2 does not accept DSA keys. Make sure your key generator is set up to create RSA keys.
resource "aws_key_pair" "bastion_key_pair" {
  key_name   = var.bastion_key_name
  public_key = tls_private_key.bastion_private_key.public_key_openssh

  tags = {
    Name   = "BastionKeyPair"
    module = "bastion"
  }
}

resource "aws_secretsmanager_secret" "bastion_private_key" {
  name                    = "/${var.project_name}/${var.environment}/bastion/private_key_pem"
  recovery_window_in_days = 0

  tags = {
    Name   = "BastionPrivateKey"
    module = "bastion"
  }
}

resource "aws_secretsmanager_secret_version" "bastion_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.bastion_private_key.id
  secret_string = tls_private_key.bastion_private_key.private_key_pem
}

/*==== VPC's Bastion Security Group ======*/
resource "aws_security_group" "allow_ssh_sg" {
  name        = "${var.project_name}-Allow-ssh"
  description = "Security group to allow ssh"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "SecureShellSecurityGroup"
    module = "bastion"
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


data "aws_security_group" "default_sg" {
  filter {
    name   = "group-name"
    values = ["${var.project_name}-Default"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  key_name                    = aws_key_pair.bastion_key_pair.key_name
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [data.aws_security_group.default_sg.id, aws_security_group.allow_ssh_sg.id]
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true

  iam_instance_profile = var.ssm_profile_for_ec2

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
    Name   = "BastionEC2"
    module = "bastion"
  }
}

resource "tls_private_key" "bastion_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Amazon EC2 does not accept DSA keys. Make sure your key generator is set up to create RSA keys.
resource "aws_key_pair" "bastion_key_pair" {
  key_name   = var.bastion_key_name
  public_key = tls_private_key.bastion_private_key.public_key_openssh

  tags = {
    Name        = "${var.global_name}-bastion-key-pair"
    environment = "${var.environment}"
    module      = "bastion"
  }
}

resource "aws_secretsmanager_secret" "bastion_private_key" {
  name                    = "/${var.global_name}/${var.environment}/bastion/private_key_pem"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.global_name}-bastion_private_key"
    environment = "${var.environment}"
    module      = "bastion"
  }
}

resource "aws_secretsmanager_secret_version" "bastion_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.bastion_private_key.id
  secret_string = tls_private_key.bastion_private_key.private_key_pem
}

/*==== VPC's Bastion Security Group ======*/
resource "aws_security_group" "allow_ssh_sg" {
  name        = "${var.global_name}-Allow-ssh"
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
    Name        = "${var.global_name}-ssh-sg"
    environment = "${var.environment}"
    module      = "bastion"
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

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  key_name                    = aws_key_pair.bastion_key_pair.key_name
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.allow_ssh_sg.id]
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true

  tags = {
    Name        = "${var.global_name}-bastion-ec2-t2-micro"
    environment = "${var.environment}"
    module      = "bastion"
  }
}

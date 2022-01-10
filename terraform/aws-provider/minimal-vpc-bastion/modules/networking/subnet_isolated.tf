resource "aws_subnet" "isolated_subnets" {
  count = length(var.isolated_subnets_cidr)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.isolated_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name   = "IsolatedSubnet${count.index}_${element(var.availability_zones, count.index)}"
    module = "networking"
  }
}

# amazonaws..ssm: The endpoint for the Systems Manager service.
# amazonaws..ec2messages: Systems Manager uses this endpoint to make calls from SSM Agent to the Systems Manager service.
# amazonaws..ssmmessages: This endpoint is required only if you are connecting to your instances through a secure data channel using Session Manager.

locals {
  service_endpoints = [
    {
      name = "ssm"
      type = "Interface"
    },
    {
      name = "ssmmessages"
      type = "Interface"
    },
    {
      name = "ec2messages"
      type = "Interface"
    },
  ]
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "endpoints" {
  count = length(local.service_endpoints)

  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.${local.service_endpoints[count.index].name}"

  vpc_endpoint_type   = local.service_endpoints[count.index].type
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.default.id]

  subnet_ids = aws_subnet.isolated_subnets[*].id

  tags = {
    Name   = "Endpoint_${local.service_endpoints[count.index].name}"
    module = "networking"
  }
}

# ## This commented part is just for test : 
# ## EC2 instance in isolated subnet to test if we can retrieve it in fleet manager.
# data "aws_ami" "amazon_linux_2" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }

#   owners = ["amazon"]
# }

# resource "aws_instance" "isolated_instance_should_be_in_fleet" {
#   ami                    = data.aws_ami.amazon_linux_2.id
#   instance_type          = "t3.micro"
#   vpc_security_group_ids = [aws_security_group.default.id]
#   subnet_id              = element(aws_subnet.isolated_subnets, 0).id

#   iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

#   root_block_device {
#     volume_type = "gp3"
#     volume_size = 8
#   }

#   user_data = <<-EOL
#     #!/bin/bash -xe
#     sudo yum update -y
#     sudo yum install -y nc
#   EOL

#   tags = {
#     Name   = "should_be_in_fleet"
#     module = "networking"
#   }
# }

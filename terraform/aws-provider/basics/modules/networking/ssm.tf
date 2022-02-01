## Profile to associate to every EC2 instance we will create.
# This will let SSM (Systems Manager Agent) perform operation on the machine and improve security.
# Example : connect to the instance without SSH (using awscli) :
# aws ssm start-session --target MY_INSTANCE_ID --region eu-west-1

resource "aws_iam_role" "ssm_instance_role" {
  name        = "${var.project_name}-${var.environment}-ssm_instance_role"
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

  tags = {
    Name   = "SsmInstanceRole"
    module = "networking"
  }
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

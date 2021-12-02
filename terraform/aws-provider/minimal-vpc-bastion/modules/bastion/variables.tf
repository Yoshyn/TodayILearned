variable "project_name" {
  type        = string
  description = "Global name use to identify what we are doing."
}

variable "environment" {
  type        = string
  description = "The Deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "The id of the vpc"
}

variable "public_subnet_id" {
  type        = string
  description = "The id of the public subnet"
}

variable "bastion_key_name" {
  type        = string
  description = "The name of the bastion key."
}

variable "ssm_profile_for_ec2" {
  type        = string
  description = "Name of the ssm profile to associate to the ec2."
}

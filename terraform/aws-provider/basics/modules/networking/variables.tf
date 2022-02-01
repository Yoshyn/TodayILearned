variable "project_name" {
  type        = string
  description = "Global name use to identify what we are doing."
}

variable "environment" {
  type        = string
  description = "The Deployment environment"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "isolated_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the isolated subnet"
}

variable "region" {
  type        = string
  description = "The region to launch the bastion host"
}

variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
}

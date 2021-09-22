variable "global_name" {
  description = "The global name of the project"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "vpc_id" {
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

variable "global_name" {
  type        = string
  description = "The global name of the project"
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

variable "global_name" {
  description = "The global name of the project"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "vpc_id" {
  description = "The id of the vpc"
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "Private subnets ids"
}

variable "database_name" {
  type = string
}

variable "database_root_username" {
  default = "postgres"
}

variable "database_root_password" {
  type = string
}

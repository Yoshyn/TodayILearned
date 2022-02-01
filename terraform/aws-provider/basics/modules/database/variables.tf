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

variable "private_subnets_ids" {
  type        = list(any)
  description = "Private subnets ids"
}

variable "database_name" {
  type = string
}

variable "database_root_username" {
  type    = string
  default = "postgres"
}

variable "database_root_password" {
  type    = string
  default = null
}

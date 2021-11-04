variable "global_name" {
  description = "The global name of the project"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "vpc_id" {
  description = "The id of the vpc"
}

variable "desired_capacity" {
  description = "ASG desired capacity"
  default     = 2
}

variable "max_size" {
  description = "ASG maximun size"
  default     = 3
}

variable "min_size" {
  description = "ASG minimun size"
  default     = 1
}

variable "public_subnets_ids" {
  type        = list(any)
  description = "The ids of the public subnets"
}

variable "private_subnets_ids" {
  type        = list(any)
  description = "The ids of the private subnets"
}

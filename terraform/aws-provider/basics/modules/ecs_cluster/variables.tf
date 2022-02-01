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

variable "desired_capacity" {
  type        = number
  description = "ASG desired capacity"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "ASG maximun size"
  default     = 3
}

variable "min_size" {
  type        = number
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

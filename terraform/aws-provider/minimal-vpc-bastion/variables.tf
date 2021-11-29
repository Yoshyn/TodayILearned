variable "region" {
  type        = string
  description = "AWS deployment region"
}

variable "project_name" {
  type        = string
  description = "Global name use to identify what we are doing."
}

variable "environment" {
  type    = string
  default = "test"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

//Networking
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the vpc"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "budget_subscriber_email_addresses" {
  type        = list(string)
  description = "List of email address to send the budget alert"
}

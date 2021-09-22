variable "region" {
  description = "AWS deployment region"
}

variable "global_name" {
  description = "Global name use to identify what we are doing."
}

variable "environment" {
  default = "test"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
  default     = ["10.0.1.0/24"]
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
  default     = ["10.0.10.0/24"]
}

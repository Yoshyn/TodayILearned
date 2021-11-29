variable "project_name" {
  type        = string
  description = "Global name use to identify what we are doing."
}

variable "environment" {
  type        = string
  description = "The Deployment environment"
}

variable "subscriber_email_addresses" {
  type        = list(string)
  description = "List of email address to send the budget alert"
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.database.address
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.database.port
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.database.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.database.hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.database.id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.database.status
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.database.name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.database.username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = aws_db_instance.database.password
  sensitive   = true
}

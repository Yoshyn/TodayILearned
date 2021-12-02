output "address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.default.address
}

output "port" {
  description = "The database port"
  value       = aws_db_instance.default.port
}

output "endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.default.endpoint
}

output "hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.default.hosted_zone_id
}

output "id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.default.id
}

output "status" {
  description = "The RDS instance status"
  value       = aws_db_instance.default.status
}

output "name" {
  description = "The database name"
  value       = aws_db_instance.default.name
}

output "username" {
  description = "The master username for the database"
  value       = aws_db_instance.default.username
  sensitive   = true
}

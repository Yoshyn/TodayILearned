output "bastion_connect_string" {
  value = "ssh -i ~/.ssh/bastion-${var.global_name}-key-pair.pem -p 22 ec2-user@${module.bastion.public_ip}"
}

output "retrieve_psql_connect_string_in_bastion" {
  value = "aws secretsmanager get-secret-value --secret-id '/${var.global_name}/${var.environment}/database/connection_string' --region ${var.region} | jq '.SecretString'"
}

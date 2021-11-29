output "bastion_connect_string" {
  value = "ssh -i ~/.ssh/bastion-${var.project_name}-key-pair.pem -p 22 ec2-user@${module.bastion.public_ip}"
}

output "retrieve_psql_connect_string_in_bastion" {
  value = "aws secretsmanager get-secret-value --secret-id '/${var.project_name}/${var.environment}/database/connection_string' --region ${var.region} | jq '.SecretString'"
}

output "ecs_load_balancer_dns" {
  value = module.ecs_cluster.load_balancer_dns
}

output "ecs_load_balancer_arn" {
  value = module.ecs_cluster.load_balancer_arn
}

output "ecs_task_exection_role_name" {
  value = module.ecs_cluster.ecs_task_exection_role_name
}

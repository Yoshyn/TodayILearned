output "load_balancer_dns" {
  value = aws_lb.ecs_alb.dns_name
}

output "load_balancer_arn" {
  value = aws_lb.ecs_alb.arn
}


output "ecs_srv_execution_role_name" {
  value = aws_iam_role.ecs_srv_execution_role.name
}

output "ecs_task_execution_role_name" {
  value = aws_iam_role.ecs_task_execution_role.name
}

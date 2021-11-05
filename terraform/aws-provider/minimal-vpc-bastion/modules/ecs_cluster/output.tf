output "load_balancer_dns" {
  value = aws_lb.ecs_alb.dns_name
}

output "load_balancer_arn" {
  value = aws_lb.ecs_alb.arn
}

output "ecs_task_exection_role_name" {
  value = aws_iam_role.ecs_task_exection_role.name
}

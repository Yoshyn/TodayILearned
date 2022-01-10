output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "isolated_subnets_ids" {
  value = aws_subnet.isolated_subnets.*.id
}

output "default_sg_id" {
  value = aws_security_group.default.id
}

output "security_groups_ids" {
  value = ["${aws_security_group.default.id}"]
}

output "public_route_table" {
  value = aws_route_table.public.id
}

output "ssm_profile_for_ec2" {
  value = aws_iam_instance_profile.ssm_instance_profile.name
}

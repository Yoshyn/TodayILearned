output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.aws_auth_configmap_yaml
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "kubeconfig" {
  description = "Get kubeconfig"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${local.cluster_name}"
  // aws eks --region (terraform output -raw region) update-kubeconfig --name (terraform output -raw cluster_name)
}

output "load_balancer_dns" {
  value = aws_lb.eks_alb.dns_name
}

# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

# Resources : kubernetes_* *=(cluster_role,cluster_role_binding,config_map,cron_job,deployment,ingress,...)
# Data Sources : kubernetes_* *=(all_namespaces,config_map,ingress,namespace,persistent_volume_claim,pod,secret,service,service_account,storage_class)
provider "kubernetes" {
  load_config_file       = "false"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

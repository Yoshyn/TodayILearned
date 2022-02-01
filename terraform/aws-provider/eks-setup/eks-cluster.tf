# Terraform module to create an Elastic Kubernetes (EKS) cluster and associated worker instances on AWS
# https://github.com/terraform-aws-modules/terraform-aws-eks
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.2.3"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.21"
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets

  self_managed_node_group_defaults = {
    update_launch_template_default_version = true
    instance_type                          = "t2.medium"
    root_volume_type                       = "gp3"
    bootstrap_extra_args                   = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

    iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
    post_bootstrap_user_data     = <<-EOT
      #!/bin/bash
      set -ex
      yum install -y ethtool tcpdump
    EOT
  }

  self_managed_node_groups = {
    worker-group-1 = {
      instance_type          = "t3.medium"
      vpc_security_group_ids = [aws_security_group.default.id, aws_security_group.http_access.id]
      min_size               = 1
      max_size               = 2
      desired_size           = 1
      target_group_arns      = [aws_alb_target_group.eks_web_target_group.arn]
    }
  }
}

################################################################################
# aws-auth configmap
# Only EKS managed node groups automatically add roles to aws-auth configmap
# so we need to ensure fargate profiles and self-managed node roles are added
################################################################################


# Maybe use kubernete provider here should be better ?

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.cluster.token
      }
    }]
  })
}

resource "local_file" "aws_auth_yaml" {
  content  = module.eks.aws_auth_configmap_yaml
  filename = "${path.root}/.terraform/tmp/aws-auth.yml"
}

resource "null_resource" "apply_aws_auth_config_map" {

  depends_on = [local_file.aws_auth_yaml]

  triggers = {
    kubeconfig = base64encode(local.kubeconfig)
    cmd_patch  = <<-EOT
      # kubectl delete configmaps aws-auth -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode) 2> /dev/null
      kubectl create configmap aws-auth -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl patch configmap/aws-auth --patch-file ${local_file.aws_auth_yaml.filename} -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_patch
  }
}

resource "null_resource" "delete_aws_auth_yaml" {
  triggers = { once = timestamp() }

  depends_on = [null_resource.apply_aws_auth_config_map]

  provisioner "local-exec" {
    command = "rm -rf ${local_file.aws_auth_yaml.filename}"
  }
}

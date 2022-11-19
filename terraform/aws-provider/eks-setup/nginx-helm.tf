# # Use helm provider to configure nginx after the creation of the cluster.
# # It's avoid to follow all the step here :
# # https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/

provider "helm" {
  kubernetes {
    config_path            = "~/.kube/config" # in case of error
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

# This replace the manuals steps here :
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
resource "helm_release" "ingress" {
  name             = "helm-release"
  namespace        = "nginx-system"
  create_namespace = true
  force_update     = true
  atomic           = true

  # https://github.com/nginxinc/helm-charts
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"

  set {
    name  = "controller.kind"
    value = "daemonset"
  }

  set {
    name  = "controller.logLevel"
    value = 1
  }

  set {
    name  = "controller.image.tag"
    value = "2.1.0"
  }

  # This will create by default a load balancer that we do not want.
  set {
    name  = "controller.service.create"
    value = false
  }

  # https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/configmap-resource/
  set {
    name  = "controller.config.entries.log-format"
    value = "$remote_addr - $remote_user [$time_iso8601] \"$request\" ($host) $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" \"$http_x_forwarded_for\""
  }

  set {
    name  = "controller.setAsDefaultIngress"
    value = true
  }

  set {
    name  = "controller.healthStatus"
    value = true
  }
  # In case of production, set all the TLS certificate !
}

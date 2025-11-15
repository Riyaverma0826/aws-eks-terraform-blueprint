locals {
  configmap_roles = [
    {
      rolearn  = var.eks_nodegroup_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:nodes"]
    },
    {
      rolearn  = var.eks_admin_role_arn
      username = "eks-admin"
      groups   = ["system:masters"]
    }
  ]
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth-2"
    namespace = "kube-system"
  }
  data = { mapRoles = yamlencode(local.configmap_roles) }
}

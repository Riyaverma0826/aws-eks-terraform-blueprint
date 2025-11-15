terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      configuration_aliases = [ kubernetes.eks ]
    }
    helm = {
      source = "hashicorp/helm"
      configuration_aliases = [ helm.eks ]
    }
  }
}


resource "aws_iam_policy" "efs_csi_policy" {
  name        = "${var.project_name}-AmazonEKS_EFS_CSI_Driver_Policy-v2"
  description = "IAM policy for EFS CSI driver"
  path        = "/"
  policy      = data.http.efs_csi_iam_policy.response_body
  tags        = var.tags
}


resource "aws_iam_role" "efs_csi_role" {
  name = "${var.project_name}-efs-csi-role-v3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = var.eks_oidc_provider_arn
        },
        Condition = {
          StringEquals = {
            "${var.eks_oidc_provider_url}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "efs_csi_policy_attach" {
  policy_arn = aws_iam_policy.efs_csi_policy.arn
  role       = aws_iam_role.efs_csi_role.name
}


resource "helm_release" "efs_csi_driver" {
  provider = helm.eks

  depends_on = [aws_iam_role.efs_csi_role]

  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"

  values = [
    yamlencode({
      image = {
        repository = var.efs_image_repo
      }
      controller = {
        serviceAccount = {
          create = true
          name   = "efs-csi-controller-sa"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.efs_csi_role.arn
          }
        }
      }
    })
  ]

  timeout          = 600
  cleanup_on_fail  = true
}

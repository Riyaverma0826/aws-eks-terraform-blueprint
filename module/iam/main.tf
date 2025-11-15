####################################
# data source
####################################

data "aws_caller_identity" "current" {}


data "aws_partition" "current" {}

####################################
# EKS MASTER ROLE (Control Plane)
####################################

resource "aws_iam_role" "eks_master_role" {
  name = "${var.project_prefix}-master-role-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}


# 📜 Attach required managed policies for EKS master role

resource "aws_iam_role_policy_attachment" "eks_master_role_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])

  policy_arn = each.key
  role       = aws_iam_role.eks_master_role.name
}

########################################################
# 🔹 EKS NODEGROUP ROLE (Worker Nodes)
########################################################

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.project_prefix}-nodegroup-role-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# 📜 Attach required managed policies for EKS node group

resource "aws_iam_role_policy_attachment" "eks_nodegroup_role_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.key
  role       = aws_iam_role.eks_nodegroup_role.name
}

##########################################################
# 🔹 EKS OIDC PROVIDER (Required for IRSA)
##########################################################

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  
  url = "https://oidc.eks.${var.region}.amazonaws.com/id/${var.cluster_name}-2"

  tags = merge(
    var.tags,
    { Name = "${var.cluster_name}-eks-oidc-provider" }
  )
}


##########################################################
# 🔹 EKS ADMIN ROLE
##########################################################

resource "aws_iam_role" "eks_admin_role" {
  name = "${var.project_prefix}-admin-role-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "eks-admin-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["eks:*", "ssm:GetParameter", "iam:ListRoles"]
        Resource = "*"
      }]
    })
  }

  tags = var.tags
}

##########################################################
# 🔹 EKS READONLY ROLE
##########################################################

resource "aws_iam_role" "eks_readonly_role" {
  name = "${var.project_prefix}-readonly-role-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "eks-readonly-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["eks:Describe*", "eks:List*", "ssm:GetParameter"]
        Resource = "*"
      }]
    })
  }

  tags = var.tags
}

##########################################################
# 🔹 EKS DEVELOPER ROLE
##########################################################

resource "aws_iam_role" "eks_developer_role" {
  name = "${var.project_prefix}-developer-role-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "eks-developer-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["eks:Get*", "eks:List*", "ssm:GetParameter"]
        Resource = "*"
      }]
    })
  }

  tags = var.tags
}

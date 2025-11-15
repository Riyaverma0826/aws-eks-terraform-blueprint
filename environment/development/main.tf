#############################################
# 🔹 LOCALS
#############################################

# locals {
#   project_name = "eks-dev"
#   common_tags = {
#     Environment = "dev"
#     Project     = "EKS-INFRA"
#     ManagedBy   = "Terraform"
#   }
# }

locals {
  project_name      = "eks"
  aws_region        = var.aws_region
  environment       = var.environment
  business_division = var.business_division

  prefix = "${local.business_division}-${local.environment}-${local.project_name}"

  common_tags = {
    Environment      = local.environment
    BusinessDivision = local.business_division
    Project          = local.project_name
    ManagedBy        = "Terraform"
  }
}



#############################################
# 🌐 VPC MODULE
#############################################

module "vpc" {
  source = "../../module/vpc"

  vpc_name               = "${local.prefix}-vpc"
  vpc_cidr_block         = var.vpc_cidr_block
  vpc_public_subnets     = var.vpc_public_subnets
  vpc_private_subnets    = var.vpc_private_subnets
  vpc_enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = local.common_tags
}

#############################################
# 🔐 IAM MODULE
#############################################

module "iam" {
  source                      = "../../module/iam"
  project_prefix              = local.prefix
  region                      = var.aws_region
  cluster_name                = module.eks.cluster_name
  eks_oidc_root_ca_thumbprint = var.eks_oidc_root_ca_thumbprint
  tags                        = local.common_tags
}

#############################################
# ☸️ EKS MODULE
#############################################

module "eks" {
  source = "../../module/eks"

  vpc_id                      = module.vpc.vpc_id
  public_subnets              = module.vpc.public_subnets
  private_subnets             = module.vpc.private_subnets
  cluster_name                = "${local.prefix}-cluster"
  cluster_version             = var.cluster_version
  cluster_role_arn            = module.iam.eks_master_role_arn
  node_role_arn               = module.iam.eks_nodegroup_role_arn
  eks_oidc_root_ca_thumbprint = var.eks_oidc_root_ca_thumbprint
  tags                        = local.common_tags
}

#############################################
# ☸️ DYNAMIC PROVIDERS (AFTER EKS CREATION)
#############################################

# These wait for the cluster to exist before connecting
data "aws_eks_cluster" "this" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  alias = "eks"
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

#############################################
# 🧩 KUBERNETES MODULE
#############################################

module "kubernetes" {
  source = "../../module/kubernetes"

  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_data        = module.eks.cluster_certificate_authority_data
  cluster_name           = module.eks.cluster_name
  eks_admin_role_arn     = module.iam.eks_admin_role_arn
  eks_readonly_role_arn  = module.iam.eks_readonly_role_arn
  eks_developer_role_arn = module.iam.eks_developer_role_arn
  eks_nodegroup_role_arn = module.iam.eks_nodegroup_role_arn
  namespace              = var.namespace
  project_name           = local.prefix

  tags                   = local.common_tags
}

#############################################
# 💻 EC2 BASTION
#############################################

module "ec2_bastion" {
  source = "../../module/ec2"

  instance_type    = var.instance_type
  instance_keypair = var.instance_keypair
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnets
  bastion_sg_name  = "${local.prefix}-public-bastion-sg"
  bastion_name     = "${local.prefix}-bastion"
  project_name     = local.project_name
  tags             = local.common_tags
}

# #############################################
# # 📦 EFS CSI DRIVER
# #############################################

module "efs_csi" {
  source = "../../module/efs-static/efs_csi"
  # depends_on = [module.eks]

  project_name          = local.project_name
  tags                  = local.common_tags
  eks_oidc_provider_arn = module.eks.eks_oidc_provider_arn
  eks_oidc_provider_url = module.eks.eks_oidc_provider_url
  eks_cluster_name      = module.eks.cluster_name
  eks_cluster_endpoint  = module.eks.cluster_endpoint
  eks_cluster_ca_data   = module.eks.cluster_certificate_authority_data
  efs_image_repo        = var.efs_image_repo

  providers = {
    kubernetes.eks = kubernetes.eks
    helm.eks       = helm.eks
  }
}


#############################################
# 🗂️ EFS APP
#############################################

module "efs_app" {
  source = "../../module/efs-static/efs_app"
  # depends_on = [module.efs_csi]

  project_name    = local.project_name
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr_block
  private_subnets = module.vpc.private_subnets
  tags            = local.common_tags
  providers = {
    kubernetes.eks = kubernetes.eks
  }
}

#############################################
# 👥 IAM USERS MODULE
#############################################

module "iam_users" {
  source = "../../module/iam_users"

  project_name = local.project_name
  common_tags  = local.common_tags

  eks_admin_role_arn     = module.iam_roles.eks_admin_role_arn
  eks_readonly_role_arn  = module.iam_roles.eks_readonly_role_arn
  eks_developer_role_arn = module.iam_roles.eks_developer_role_arn
}

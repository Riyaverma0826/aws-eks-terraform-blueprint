variable "project_prefix" {
  description = "Prefix for naming IAM resources"
  type        = string
  default     = "dev-eks"
}

variable "tags" {
  description = "Common tags applied to IAM resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "EKS-INFRA"
    ManagedBy   = "Terraform"
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "eks_oidc_root_ca_thumbprint" {
  description = "Thumbprint for EKS OIDC Root CA"
  type        = string
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "cluster_name" {
  description = "EKS cluster name for OIDC provider URL"
  type        = string
  default     = "eksdemo1"
}

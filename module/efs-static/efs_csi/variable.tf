variable "project_name" {
  description = "Project name prefix for tagging resources"
  type        = string
}


variable "tags" {
  description = "Common resource tags to apply to all created resources"
  type        = map(string)
}


variable "eks_oidc_provider_arn" {
  description = "OIDC provider ARN from the EKS module"
  type        = string
}


variable "eks_oidc_provider_url" {
  description = "OIDC provider URL (used for IAM trust relationship condition)"
  type        = string
}

variable "efs_image_repo" {
  description = "EFS CSI Driver image repository for the AWS region"
  type        = string
}


variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
}


variable "eks_cluster_endpoint" {
  description = "EKS Cluster API endpoint"
  type        = string
}

variable "eks_cluster_ca_data" {
  description = "EKS Cluster certificate authority (CA) data in base64 format"
  type        = string
}

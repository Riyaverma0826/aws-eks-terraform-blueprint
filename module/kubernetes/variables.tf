variable "namespace" {  
  description = "Kubernetes namespace for developer workloads"
  type        = string 
}

variable "eks_admin_role_arn" {}

variable "eks_readonly_role_arn" {}

variable "eks_developer_role_arn" {}

variable "eks_nodegroup_role_arn" {}

variable "tags" { type = map(string) }

variable "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  type        = string
}

variable "cluster_ca_data" {
  description = "EKS cluster certificate authority data"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}


data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}


provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


variable "project_name" {
  description = "Project name or prefix"
  type        = string
}


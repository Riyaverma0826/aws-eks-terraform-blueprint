variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "cluster_name" {}
variable "cluster_version" {}
variable "cluster_role_arn" {}
variable "node_role_arn" {}
variable "tags" { type = map(string) }
variable "eks_oidc_root_ca_thumbprint" {}
variable "cluster_service_ipv4_cidr" {
  type        = string
  description = "Service CIDR for Kubernetes services"
  default     = "172.20.0.0/16"
}

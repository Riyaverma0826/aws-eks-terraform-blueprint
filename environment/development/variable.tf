variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr_block" {
  type = string
}
variable "vpc_public_subnets" {
  type = list(string)
}
variable "vpc_private_subnets" {
  type = list(string)
}
variable "vpc_enable_nat_gateway" {
  type    = bool
  default = false
}

variable "cluster_version" {
  type = string
}


variable "eks_oidc_root_ca_thumbprint" {
  type = string
}

# ec2
variable "instance_type" {
  type = string
}


variable "instance_keypair" {
  type = string
}

# kubernetes
variable "namespace" {
  type = string
}

# efs csi
variable "efs_image_repo" {
  description = "EFS CSI Driver image repository"
  type        = string
}


variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "business_division" {
  type = string
}

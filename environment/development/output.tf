output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_name" {
  value = "${local.prefix}-vpc"
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "bastion_public_ip" {
  value = module.ec2_bastion.ec2_bastion_public_ip
}

output "efs_csi_role_arn" {
  value = module.efs_csi.efs_csi_role_arn
}

output "efs_helm_metadata" {
  value = module.efs_csi.efs_helm_metadata
}

output "eks_master_role_arn" {
  description = "ARN of EKS master role (control plane)"
  value       = aws_iam_role.eks_master_role.arn
}

output "eks_nodegroup_role_arn" {
  description = "ARN of EKS nodegroup role (worker nodes)"
  value       = aws_iam_role.eks_nodegroup_role.arn
}

output "eks_admin_role_arn" {
  description = "ARN of EKS admin role"
  value       = aws_iam_role.eks_admin_role.arn
}

output "eks_readonly_role_arn" {
  description = "ARN of EKS readonly role"
  value       = aws_iam_role.eks_readonly_role.arn
}

output "eks_developer_role_arn" {
  description = "ARN of EKS developer role"
  value       = aws_iam_role.eks_developer_role.arn
}

output "eks_oidc_provider_arn" {
  description = "ARN of the created OIDC provider"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}

output "eks_oidc_provider_url" {
  description = "OIDC issuer URL for the cluster"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.url
}

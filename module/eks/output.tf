output "cluster_name" { value = aws_eks_cluster.eks_cluster.name }
output "cluster_endpoint" { value = aws_eks_cluster.eks_cluster.endpoint }
output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}





output "eks_oidc_provider_arn" {
  description = "The ARN of the IAM OIDC provider associated with the EKS cluster"
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}

output "eks_oidc_provider_url" {
  description = "The OIDC provider URL associated with the EKS cluster"
  value       = aws_iam_openid_connect_provider.oidc_provider.url
}

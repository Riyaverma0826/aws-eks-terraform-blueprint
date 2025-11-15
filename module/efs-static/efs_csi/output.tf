output "efs_csi_role_arn" {
  description = "IAM role ARN for EFS CSI driver"
  value       = aws_iam_role.efs_csi_role.arn
}

output "efs_helm_metadata" {
  description = "Metadata of deployed EFS CSI Helm chart"
  value       = helm_release.efs_csi_driver.metadata  
}

output "efs_csi_helm_status" {
  description = "Wait until EFS CSI driver Helm release is deployed"
  value       = helm_release.efs_csi_driver.status
}

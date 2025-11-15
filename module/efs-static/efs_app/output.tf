output "efs_id" {
  description = "EFS File System ID"
  value       = aws_efs_file_system.efs.id
}

output "efs_dns_name" {
  description = "EFS DNS Name"
  value       = aws_efs_file_system.efs.dns_name
}

output "app_service_name" {
  description = "Kubernetes LoadBalancer Service Name"
  value       = kubernetes_service_v1.app_service.metadata[0].name
}

output "efs_write_app_pod_name" {
  description = "Name of the EFS write test pod"
  value       = kubernetes_pod_v1.efs_write_app_pod.metadata[0].name
}

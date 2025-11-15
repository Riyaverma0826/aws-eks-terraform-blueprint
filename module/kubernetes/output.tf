output "namespace_name" { value = kubernetes_namespace_v1.namespace.metadata[0].name }

output "developer_role_name" {
  value = kubernetes_role_v1.eksdeveloper_role.metadata[0].name
}

output "developer_clusterrole_name" {
  value = kubernetes_cluster_role_v1.eksdeveloper_clusterrole.metadata[0].name
}

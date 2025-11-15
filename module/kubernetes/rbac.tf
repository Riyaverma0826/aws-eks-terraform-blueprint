resource "kubernetes_cluster_role_v1" "developer" {
  metadata { name = "developer-role-1" }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps"]
    verbs      = ["get", "list", "watch", "create", "delete", "update"]
  }
}

resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = "${var.project_name}-namespace-${var.namespace}"
  }
}


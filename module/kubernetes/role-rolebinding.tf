resource "kubernetes_role_v1" "eksdeveloper_role" {
  metadata {
    name      = "${var.project_name}-eksdeveloper-role-1"
    namespace = var.namespace
  }

  rule {
    api_groups = ["", "extensions", "apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}


resource "kubernetes_role_binding_v1" "eksdeveloper_rolebinding" {
  metadata {
    name      = "${var.project_name}-eksdeveloper-rolebinding-1"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.eksdeveloper_role.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "eks-developer-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

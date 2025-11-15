terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      configuration_aliases = [ kubernetes.eks ]
    }
  }
}


#############################################
# ⏳ Wait for LoadBalancer Readiness
#############################################

resource "null_resource" "wait_for_lb" {
  provisioner "local-exec" {
    command = "echo '⏳ Waiting 60 seconds for LoadBalancer...' && sleep 120"
  }
}

#############################################
# ⏳ Wait for EFS CSI Driver Pods to be Ready
#############################################

resource "null_resource" "wait_for_efs_csi_driver" {
  provisioner "local-exec" {
    command = "echo 'Waiting 60s for EFS CSI driver...' && sleep 120"
  }
}

#############################################
# 🔐 EFS Security Group
#############################################

resource "aws_security_group" "efs_allow_access" {
  name        = "${var.project_name}-efs-nfs-sg"
  description = "Allow NFS traffic from EKS VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}


#############################################
# ☸️ Kubernetes StorageClass for EFS
#############################################
resource "kubernetes_storage_class_v1" "efs_sc" {
    provider = kubernetes.eks
  depends_on = [
    null_resource.wait_for_efs_csi_driver,
    aws_efs_file_system.efs,
  ]

  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
}


#############################################
# 💾 Persistent Volume (PV) & Claim (PVC)
#############################################

# Persistent Volume
resource "kubernetes_persistent_volume_v1" "efs_pv" {
    provider = kubernetes.eks
  metadata {
    name = "efs-pv"
  }
  spec {
    capacity                         = { storage = "5Gi" }
    volume_mode                      = "Filesystem"
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = kubernetes_storage_class_v1.efs_sc.metadata[0].name
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = aws_efs_file_system.efs.id
      }
    }
  }
}

# Persistent Volume Claim
resource "kubernetes_persistent_volume_claim_v1" "efs_pvc" {
    provider = kubernetes.eks
  metadata {
    name = "efs-claim"
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class_v1.efs_sc.metadata[0].name
    resources {
      requests = { storage = "5Gi" }
    }
  }
}


#############################################
# 🚀 Application Deployment (EFS Integrated)
#############################################

resource "kubernetes_deployment_v1" "app" {
    provider = kubernetes.eks
  metadata {
    name = "myapp1"
  }

  spec {
    replicas = 2
    selector {
      match_labels = { app = "myapp1" }
    }

    template {
      metadata {
        labels = { app = "myapp1" }
      }

      spec {
        container {
          name  = "myapp1-container"
          image = "stacksimplify/kubenginx:1.0.0"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "persistent-storage"
            mount_path = "/usr/share/nginx/html/efs"
          }
        }

        volume {
          name = "persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.efs_pvc.metadata[0].name
          }
        }
      }
    }
  }
}


#############################################
# 🌐 LoadBalancer Service
#############################################

resource "kubernetes_service_v1" "app_service" {
    provider = kubernetes.eks
    depends_on = [
    null_resource.wait_for_lb,
    kubernetes_deployment_v1.app
  ]
  metadata {
    name = "myapp1-lb-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.app.spec[0].selector[0].match_labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}


#############################################
# 📡 EFS Mount Targets
#############################################

resource "aws_efs_mount_target" "efs_mt" {
  count           = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs_allow_access.id]
}


#############################################
# 🧠 Kubernetes Pod - Write to EFS Pod
#############################################

resource "kubernetes_pod_v1" "efs_write_app_pod" {
    provider = kubernetes.eks
  depends_on = [
    aws_efs_mount_target.efs_mt
  ]

  metadata {
    name = "efs-write-app"
    labels = {
      app = "efs-test"
    }
  }

  spec {
    container {
      name    = "efs-write-app"
      image   = "busybox"
      command = ["/bin/sh"]
      args = [
        "-c",
        "while true; do echo EFS Kubernetes Static Provisioning Test $(date -u) >> /data/efs-static.txt; sleep 5; done"
      ]
      volume_mount {
        name       = "persistent-storage"
        mount_path = "/data"
      }
    }

    volume {
      name = "persistent-storage"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim_v1.efs_pvc.metadata[0].name
      }
    }
  }
}


#############################################
# 📁 EFS File System
#############################################

resource "aws_efs_file_system" "efs" {
  creation_token   = "${var.project_name}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"

  tags = var.tags
}

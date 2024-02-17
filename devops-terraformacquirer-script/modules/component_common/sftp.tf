#####################################################################
# CRIA O SERVIDOR DE SFTP PARA TESTE
#####################################################################

# configurar um volume para os dados não se perderem
locals {
  enabled_sftp = try(var.environmentConfig["sftp"], false)

  sftp_image        = "atmoz/sftp:latest"
  sftp_user         = "dock"
  sftp_password     = "dock@1234"
  sftp_service_name = "tools-sftp"
  sftp_path         = "CERC,CIP,POSTILION,CHARGEBACK"
  sftp_port         = 22
  sftp_cpu          = "100m"
  sftp_memory       = "256M"
  sftp_cpu_r        = "20m"
  sftp_memory_r     = "50M"
}

resource "kubernetes_service_v1" "tools_sftp" {
  count = local.enabled_sftp ? 1 : 0
  metadata {
    name      = local.sftp_service_name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = local.sftp_service_name
    }
    #session_affinity = "ClientIP"
    port {
      name        = local.sftp_service_name
      port        = local.sftp_port
      target_port = local.sftp_port
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_deployment_v1" "tools_sftp" {
  count = local.enabled_sftp ? 1 : 0
  metadata {
    name      = local.sftp_service_name
    namespace = var.namespace
    labels = {
      app = local.sftp_service_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.sftp_service_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.sftp_service_name
        }
      }

      spec {
        container {
          image             = local.sftp_image
          name              = local.sftp_service_name
          image_pull_policy = "Always"
          env {
            name  = "SFTP_USERS"
            value = "${local.sftp_user}:${local.sftp_password}:::${local.sftp_path}"
          }

          port {
            container_port = local.sftp_port
            name           = local.sftp_service_name
          }
          resources {
            limits = {
              cpu    = local.sftp_cpu
              memory = local.sftp_memory
            }
            requests = {
              cpu = local.sftp_cpu_r
              memory = local.sftp_memory_r
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_namespace.namespace
  ]
}
#####################################################################
# CRIA REDIS PARA TESTE
#####################################################################

# configurar um volume para os dados não se perderem
locals {
  enabled_redis = try(var.environmentConfig["redis"], false)
}

resource "kubernetes_config_map_v1" "config_redis" {
  count = local.enabled_redis ? 1 : 0
  metadata {
    name      = "redis-config"
    namespace = var.namespace
  }

  data = {
    "redis.conf" = <<-EOT
      requirepass redispwd
    EOT
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_service_v1" "tools_redis" {
  count = local.enabled_redis ? 1 : 0
  metadata {
    name      = "tools-redis"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "tools-redis"
    }

    port {
      name       = "tools-redis"
      port       = 6379
      protocol   = "TCP"
      target_port = 6379
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_deployment_v1" "tools_redis_deployment" {
  count = local.enabled_redis ? 1 : 0
  metadata {
    name      = "tools-redis"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tools-redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "tools-redis"
          cpu_min: "10M"
          cpu_max: "1000m"
          memory_min: "128M"
          memory_max: "448M"
        }
      }

      spec {
#        service_account_name = "redis"

        container {
          name  = "redis"
          image = "redis:latest"
          command = [
            "redis-server"
          ]
          args = [
            "../../etc/redis/redis.conf"
          ]
          resources {
            limits = {
              memory = "448M"
              cpu    = "1000m"
            }
            requests = {
              memory = "128M"
              cpu    = "10m"
            }
          }

          port {
            container_port = 6379
            name           = "container-port"
          }

          volume_mount {
            name      = "config"
            read_only = true
            mount_path = "/etc/redis"
          }
        }

        volume {
          name = "config"

          config_map {
            name = "redis-config"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

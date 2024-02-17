#####################################################################
# CRIA elasticsearch
#####################################################################

locals {
  enabled_elasticsearch = try(var.environmentConfig["elasticsearch"], false)
  port_elasticsearch    = 9200
}

resource "kubernetes_service_v1" "tools_elasticsearch" {
  count = local.enabled_elasticsearch ? 1 : 0
  metadata {
    name      = "tools-elasticsearch"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "tools-elasticsearch"
    }

    port {
      name        = "kibana"
      port        = 5601
      target_port = 5601
    }

    port {
      name        = "elasticsearch"
      port        = local.port_elasticsearch
      target_port = local.port_elasticsearch
    }

    port {
      name        = "es-internode"
      port        = 9300
      target_port = 9300
    }

    type = "ClusterIP"
  }
  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_deployment_v1" "tools_elasticsearch" {
  count = local.enabled_elasticsearch ? 1 : 0
  metadata {
    name      = "tools-elasticsearch"
    namespace = var.namespace
    labels = {
      app = "tools-elasticsearch"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tools-elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "tools-elasticsearch"
        }
      }

      spec {

        volume {
          name = "elasticsearch"
          config_map {
            name = "tools-elasticsearch-config"
            items {
              key  = "muxipay_index_template.json"
              path = "muxipay_index_template.json"
            }
          }
        }

        container {
          image = "elasticsearch:7.17.4"
          name  = "tools-elasticsearch"

          env {
            name  = "discovery.type"
            value = "single-node"
          }
          port {
            container_port = local.port_elasticsearch
            name           = "elasticsearch"
            protocol       = "TCP"
          }

          port {
            container_port = "9300"
            name           = "es-internode"
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "2048M"
            }
          }

          volume_mount {
            name       = "elasticsearch"
            mount_path = "/home/dock/elasticsearch"
          }

          startup_probe {
            exec {
              command = [
                "sh",
                "-c",
                "curl --request PUT --header 'Content-Type: application/json' --data '@/home/dock/elasticsearch/muxipay_index_template.json' http://127.0.0.1:${local.port_elasticsearch}/_template/muxiapi"
              ]
            }
            initial_delay_seconds = 180
            period_seconds        = 5
          }
        }

        container {
          image = "kibana:7.17.4"
          name  = "kibana"
          env {
            name  = "ELASTICSEARCH_HOSTS"
            value = "[\"http://tools-elasticsearch:${local.port_elasticsearch}\"]"
          }

          port {
            container_port = "5601"
            name           = "kibana"
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "2048M"
            }
            requests = {
              cpu    = "25m"
              memory = "1664M"
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

resource "kubernetes_config_map_v1" "tools_elasticsearch" {
  count = local.enabled_elasticsearch ? 1 : 0
  metadata {
    name      = "tools-elasticsearch-config"
    namespace = var.namespace
  }

  data = {
    "muxipay_index_template.json" = "${file("${var.path}/muxipay_index_template.json")}"
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}
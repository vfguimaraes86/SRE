#####################################################################
# CRIA O INGRESS BY VPN
#####################################################################
locals {
  enabled_ingress_internal = try(var.environmentConfig["elasticsearch"], false)
}

resource "kubernetes_ingress_v1" "ingress_internal" {
  count                  = local.enabled_ingress_internal ? 1 : 0
  wait_for_load_balancer = true
  metadata {
    name      = "${var.namespace}-ingress-alb-internal"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" : "alb"
      "alb.ingress.kubernetes.io/load-balancer-name" : "eks-internal-alb-${var.namespace}"
      "alb.ingress.kubernetes.io/tags" : "Environment=${var.environment},Namespace=${var.namespace},Billing=infrastructure,Provisioner=Terraform,ResourceGroup=${var.namespace}-eks"
      "alb.ingress.kubernetes.io/scheme" : "internal"
      "alb.ingress.kubernetes.io/target-type" : "ip"
#      "alb.ingress.kubernetes.io/target-type" : "instance"
      #"alb.ingress.kubernetes.io/healthcheck-path": "/manage/info"
      "alb.ingress.kubernetes.io/target-group-attributes" : "deregistration_delay.timeout_seconds=5"
      "alb.ingress.kubernetes.io/certificate-arn" : "${data.aws_acm_certificate.certificate_manager.arn}"
      "alb.ingress.kubernetes.io/listen-ports" : "[{\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-policy" : "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
      "alb.ingress.kubernetes.io/wafv2-acl-arn" : "${data.aws_wafv2_web_acl.waf_regional.arn}"
      "alb.ingress.kubernetes.io/inbound-cidrs" : "10.255.128.0/19"
      "alb.ingress.kubernetes.io/subnets": join(",", var.private_subnets_ids)
    }
  }

  spec {
    dynamic "rule" {
      for_each = try(var.environmentConfig["elasticsearch"], false) ? [""] : []
      content {
        host = "kibana${local.route53_domain}"
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "tools-elasticsearch"
                port {
                  number = 5601
                }
              }
            }
          }
        }
      }
    }
    dynamic "rule" {
      for_each = try(var.environmentConfig["elasticsearch"], false) ? [""] : []
      content {
        host = "elasticsearch${local.route53_domain}"
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "tools-elasticsearch"
                port {
                  number = local.port_elasticsearch
                }
              }
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
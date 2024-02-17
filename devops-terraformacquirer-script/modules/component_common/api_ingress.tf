#####################################################################
# CRIA O INGRESS PARA OS COMPONTENTES DE API
#####################################################################
locals {
  enabled_api_ingress = length(var.api_components) > 0
}

resource "kubernetes_ingress_v1" "api_ingress" {
  count                  = local.enabled_api_ingress ? 1 : 0
  wait_for_load_balancer = true
  metadata {
    name      = "${var.namespace}-api-ingress-alb"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" : "alb"
      "alb.ingress.kubernetes.io/load-balancer-name" : "eks-api-alb-${var.namespace}"
      "alb.ingress.kubernetes.io/tags" : "Environment=${var.environment},Namespace=${var.namespace},Billing=infrastructure,Provisioner=Terraform,ResourceGroup=${var.namespace}-eks,Service=api-ingress,Component=common"
      "alb.ingress.kubernetes.io/scheme" : "internet-facing"
      "alb.ingress.kubernetes.io/target-type" : "ip"
#      "alb.ingress.kubernetes.io/target-type" : "instance"
      "alb.ingress.kubernetes.io/healthcheck-path" : "/manage/info"
      "alb.ingress.kubernetes.io/target-group-attributes" : "deregistration_delay.timeout_seconds=5"
      "alb.ingress.kubernetes.io/certificate-arn" : "${data.aws_acm_certificate.certificate_manager.arn}"
      "alb.ingress.kubernetes.io/listen-ports" : "[{\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-policy" : "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
      "alb.ingress.kubernetes.io/wafv2-acl-arn" : "${data.aws_wafv2_web_acl.waf_regional.arn}"
      "alb.ingress.kubernetes.io/inbound-cidrs": "${var.inbound_cidrs}"
      "alb.ingress.kubernetes.io/subnets": join(",", var.public_subnets_ids)
      #"alb.ingress.kubernetes.io/security-groups" : aws_security_group.alb_sg.id
    }
  }

  spec {
    dynamic "rule" {
      for_each = var.api_components
      content {
        host = "${rule.value["sub_domain"]}${local.route53_domain}"
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = rule.value["name"]
                port {
                  number = 8080
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
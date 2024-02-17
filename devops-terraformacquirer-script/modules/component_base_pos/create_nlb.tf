locals {
  enabled_create_nlb = try(var.componentConfig["create_nlb"], false) && try(var.environmentConfig["nlb"], false)
  nlb_muxipay_port = try(var.componentConfig["muxipay_port"], 8031)
  nlb_ferpas_port = try(var.componentConfig["ferpas_port"], 8032)
  adjusted_namespace = replace(var.namespace, "muxipay-", "")
}

resource "kubernetes_service_v1" "create_nlb" {
  count = local.enabled_create_nlb ? 1 : 0
  #wait_for_load_balancer = true
  metadata {
    name      = "${var.componentConfig.name}-nlb"
    namespace = var.namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "ip"
#      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "instance"
      "service.beta.kubernetes.io/aws-load-balancer-name" : "${local.adjusted_namespace}-${var.componentConfig.sub_domain}"
      "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" : "ipv4"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "TCP"
#      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "SSL"
#      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "8031, 8032"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internet-facing"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" : "Environment=${var.environment},Namespace=${var.namespace},Billing=infrastructure,Provisioner=Terraform,ResourceGroup=${var.namespace}-eks"
#      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : "${data.aws_acm_certificate.certificate_manager.arn}"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
#      "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" : "ELBSecurityPolicy-TLS13-1-2-2021-06"
#      "service.beta.kubernetes.io/wafv2-acl-arn" : "${data.aws_wafv2_web_acl.waf_regional.arn}"
      "service.beta.kubernetes.io/inbound-cidrs" : "${var.inbound_cidrs}"

      #"service.beta.kubernetes.io/aws-load-balancer-target-node-labels": "gitpod.io/workload_workspace_services=true"
      #"alb.ingress.kubernetes.io/target-group-attributes": "deregistration_delay.timeout_seconds=5"
      #"service.beta.kubernetes.io/aws-load-balancer-target-group-attributes": "stickiness.enabled=true,stickiness.type=source_ip,preserve_client_ip.enabled=true"
    }
  }

  spec {
    #load_balancer_source_ranges = ["0.0.0.0/0"]
    #external_name = "${var.componentConfig.sub_domain}.${local.route53_domain}"
    selector = {
      app = "${var.componentConfig.name}"
    }

    port {
      name        = "muxipay"
      protocol    = "TCP"
      port        = local.nlb_muxipay_port
      target_port = 8031
    }

    port {
      name        = "ferpas"
      protocol    = "TCP"
      port        = local.nlb_ferpas_port
      target_port = 8032
    }

    type = "LoadBalancer"
  }
}

# Read information about the load balancer using the AWS provider.
data "aws_lb" "create_nlb" {
  count = local.enabled_create_nlb ? 1 : 0
  name  = kubernetes_service_v1.create_nlb[0].metadata[0].annotations["service.beta.kubernetes.io/aws-load-balancer-name"]
  #name  = substr("a${replace(kubernetes_service_v1.create_nlb[0].metadata[0].uid, "-", "")}", 0, 32) #OLD CLUSTER VERSION muxipay-hml
}

resource "aws_route53_record" "create_nlb" {
  count   = local.enabled_create_nlb ? 1 : 0
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "iso.${var.componentConfig.sub_domain}${local.route53_domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.create_nlb[0].dns_name
    zone_id                = data.aws_lb.create_nlb[0].zone_id
    evaluate_target_health = true
  }
}

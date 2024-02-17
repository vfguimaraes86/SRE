#####################################################################
# CRIA O NLB EXTERNO COM IP FIXO PARA A SOFTWARE EXPRESS
#####################################################################
locals {
  enabled_nlb_software_express = try(var.environmentConfig["nlb_software_express"], false)
}

resource "kubernetes_service_v1" "create_nlb_se" {
  count = local.enabled_nlb_software_express ? 1 : 0
  metadata {
    name      = "nlb-${var.namespace}-se"
    namespace = var.namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "ip"
#      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "instance"
      "service.beta.kubernetes.io/aws-load-balancer-name" : "nlb-${var.namespace}-se"
      "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" : "ipv4"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "TCP"
#      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "SSL"
#      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "2020, 2021, 2022"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internet-facing"
      "service.beta.kubernetes.io/aws-load-balancer-eip-allocations": "${data.aws_eip.eip_allocation[0].id}"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" : "Environment=${var.environment},Namespace=${var.namespace},Billing=infrastructure,Provisioner=Terraform,ResourceGroup=${var.namespace}-eks"
#      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : "${data.aws_acm_certificate.certificate_manager.arn}"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
#      "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" : "ELBSecurityPolicy-TLS13-1-2-2021-06"
      "service.beta.kubernetes.io/inbound-cidrs" : "${var.inbound_cidrs}"
      "service.beta.kubernetes.io/aws-load-balancer-subnets": "${var.public_subnets_ids[0]}"
      "service.beta.kubernetes.io/aws-load-balancer-security-groups" = "${aws_security_group.nlb_software_express[0].id}"
#      "service.beta.kubernetes.io/wafv2-acl-arn" : "${data.aws_wafv2_web_acl.waf_regional.arn}"
    }
  }

  spec {
    #load_balancer_source_ranges = ["0.0.0.0/0"]
    #external_name = "${var.componentConfig.sub_domain}.${local.route53_domain}"
    selector = {
      app = "software-express"
    }

    port {
      name        = "switcher"
      protocol    = "TCP"
      port        = 2020
      target_port = 2020
    }

    port {
      name        = "postilion"
      protocol    = "TCP"
      port        = 2021
      target_port = 2021
    }

    port {
      name        = "svc-initialization"
      protocol    = "TCP"
      port        = 2022
      target_port = 2022
    }

    type = "LoadBalancer"
  }
}

# Read information about the load balancer using the AWS provider.
data "aws_lb" "create_nlb_se" {
  count = local.enabled_nlb_software_express ? 1 : 0
  name  = kubernetes_service_v1.create_nlb_se[0].metadata[0].annotations["service.beta.kubernetes.io/aws-load-balancer-name"]
  #name  = substr("a${replace(kubernetes_service_v1.create_nlb_se[0].metadata[0].uid, "-", "")}", 0, 32) #OLD CLUSTER VERSION muxipay-hml
}

resource "aws_route53_record" "create_nlb" {
  count   = local.enabled_nlb_software_express ? 1 : 0
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "iso.software-express${local.route53_domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.create_nlb_se[0].dns_name
    zone_id                = data.aws_lb.create_nlb_se[0].zone_id
    evaluate_target_health = true
  }
}

#####################################################################
# CRIACAO SECURITY GROUP DO NLB SOFTWARE EXPRESS
#####################################################################
resource "aws_security_group" "nlb_software_express" {
  count   = local.enabled_nlb_software_express ? 1 : 0
  name        = "nlb-se-${var.namespace}-sg"
  description = "Controla trafego para o nlb-se"
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite trafego indo para qualquer lugar"
  }

  tags = {
    Service   = "security-group-nlb-se"
    Component = "common"
  }
}

resource "aws_security_group_rule" "nlb_software_express_switcher" {
  count   = local.enabled_nlb_software_express ? 1 : 0
  type              = "ingress"
  from_port         = 2020
  to_port           = 2020
  protocol          = "tcp"
  security_group_id = aws_security_group.nlb_software_express[0].id
  #prefix_list_ids   = [data.aws_prefix_list.cloudfront_muxipay-dev_ohio.prefix_list_id]
  cidr_blocks       = ["${var.inbound_cidrs}"]
  description       = "Permite acesso TCP iso para o nlb-se"
}

resource "aws_security_group_rule" "nlb_software_express_postilion" {
  count   = local.enabled_nlb_software_express ? 1 : 0
  type              = "ingress"
  from_port         = 2021
  to_port           = 2021
  protocol          = "tcp"
  security_group_id = aws_security_group.nlb_software_express[0].id
  cidr_blocks       = ["${var.inbound_cidrs}"]
  description       = "Permite acesso TCP iso para o nlb-se"
}

resource "aws_security_group_rule" "nlb_software_express_svc-initialization" {
  count   = local.enabled_nlb_software_express ? 1 : 0
  type              = "ingress"
  from_port         = 2022
  to_port           = 2022
  protocol          = "tcp"
  security_group_id = aws_security_group.nlb_software_express[0].id
  cidr_blocks       = ["${var.inbound_cidrs}"]
  description       = "Permite acesso TCP iso para o nlb-se"
}
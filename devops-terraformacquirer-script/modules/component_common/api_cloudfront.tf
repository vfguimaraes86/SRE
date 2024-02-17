#####################################################################
# CRIA CLOUDFRONT PARA AS APIS
#####################################################################
locals {
  enabled_api_cloudfront = length(var.api_components) > 0
}

resource "aws_cloudfront_distribution" "api_cloudfront" {
  count = local.enabled_api_cloudfront ? 1 : 0
  origin {
    domain_name = data.aws_lb.eks_api_alb[0].dns_name
    origin_id   = "${var.namespace}-api-ingress-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      origin_read_timeout    = var.cloudfront_timeout
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront Distribuition for APIs on ${var.namespace}"
  default_root_object = "index.html"

  aliases = [for r in var.api_components : "${r.sub_domain}${local.route53_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.namespace}-api-ingress-alb"

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = data.aws_acm_certificate.certificate_manager_us.arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"

  }

  web_acl_id = data.aws_wafv2_web_acl.waf_global.arn

  tags = {
    Service   = "api_cloudfront"
    Component = "common"
  }
}

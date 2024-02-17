#####################################################################
# CRIA S3 COMO SITE ESTÁTICO
#####################################################################
locals {
  static_bucket_components_map = {for comp in var.create_static_bucket : comp.name => comp}
}

resource "aws_s3_bucket" "static_bucket" {
  for_each      = local.static_bucket_components_map
  bucket        = "${each.value.name}${local.route53_domain}"
  force_destroy = var.force_destroy

  tags = {
    Service   = "static_bucket"
    Component = "common"
  }
}

resource "aws_s3_bucket_public_access_block" "static_bucket" {
  for_each = local.static_bucket_components_map
  bucket   = aws_s3_bucket.static_bucket[each.key].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "static_bucket" {
  for_each = local.static_bucket_components_map
  bucket = aws_s3_bucket.static_bucket[each.key].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "static_bucket" {
  for_each = local.static_bucket_components_map
  bucket = aws_s3_bucket.static_bucket[each.key].bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_bucket" {
  for_each = local.static_bucket_components_map
  bucket = aws_s3_bucket.static_bucket[each.key].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "static_bucket_policy" {
  for_each = local.static_bucket_components_map
  bucket = aws_s3_bucket.static_bucket[each.key].id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity_static[each.key].id}"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.static_bucket[each.key].bucket}/*"
      }
    ]
  })
}

#####################################################################
# CLOUDFRONT
#####################################################################
resource "aws_cloudfront_distribution" "s3_distribution_static" {
  for_each = local.static_bucket_components_map

  origin {
    domain_name = aws_s3_bucket.static_bucket[each.key].bucket_regional_domain_name
    origin_id   = "S3-Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity_static[each.key].cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront Distribution for ${each.value.name} Static Bucket on ${var.namespace}"
  default_root_object = "index.html"

  aliases = [for r in var.create_static_bucket : "${each.value.name}${local.route53_domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Origin"


    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
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
    Service   = "static_bucket"
    Component = "common"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity_static" {
  for_each = local.static_bucket_components_map
  comment = "Origin Access Identity for Static Bucket on ${var.namespace}"
}

#####################################################################
# ROUTE53
#####################################################################
resource "aws_route53_record" "subdomain" {
  for_each = local.static_bucket_components_map
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "${each.value.name}${local.route53_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution_static[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution_static[each.key].hosted_zone_id
    evaluate_target_health = false
  }
}
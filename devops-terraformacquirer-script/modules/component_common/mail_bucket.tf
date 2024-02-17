locals {
  enabled_mail_bucket = try(var.environmentConfig["mail_bucket"], false)
}

resource "aws_s3_bucket" "mail_bucket" {
  count         = local.enabled_mail_bucket ? 1 : 0
  bucket        = "mail${local.route53_domain}"
  force_destroy = var.force_destroy

  tags = {
    Service   = "mail_bucket"
    Component = "common"
  }
}

resource "aws_s3_bucket_public_access_block" "mail_bucket" {
  count  = local.enabled_mail_bucket ? 1 : 0
  bucket = aws_s3_bucket.mail_bucket[0].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "mail_bucket" {
  count  = local.enabled_mail_bucket ? 1 : 0
  bucket = aws_s3_bucket.mail_bucket[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "mail_bucket" {
  count  = local.enabled_mail_bucket ? 1 : 0
  bucket = aws_s3_bucket.mail_bucket[0].bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mail_bucket" {
  count  = local.enabled_mail_bucket ? 1 : 0
  bucket = aws_s3_bucket.mail_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_route53_record" "route53_mail" {
  count   = local.enabled_mail_bucket ? 1 : 0
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "mail${local.route53_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution[0].domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_iam_policy" "mail_bucket_rw" {
  count       = local.enabled_mail_bucket ? 1 : 0
  name        = "${var.namespace}-mail_bucket-rw-policy"
  path        = "/"
  description = "Política que permite escrita e leitura no bucket de imagens de email"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.mail_bucket[0].bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.mail_bucket[0].bucket}"
        ]
      }
    ]
  })

  tags = {
    Service   = "mail_bucket"
    Component = "common"
  }
}

resource "aws_iam_policy" "mail_bucket_ro" {
  count       = local.enabled_mail_bucket ? 1 : 0
  name        = "${var.namespace}-mail_bucket-ro-policy"
  path        = "/"
  description = "Política que permite leitura no bucket de imagens de email"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.mail_bucket[0].bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.mail_bucket[0].bucket}"
        ]
      }
    ]
  })

  tags = {
    Service   = "mail_bucket"
    Component = "common"
  }
}

#####################################################################
# CLOUDFRONT
#####################################################################

resource "aws_cloudfront_distribution" "s3_distribution" {
  count = local.enabled_mail_bucket ? 1 : 0

  origin {
    domain_name = aws_s3_bucket.mail_bucket[0].bucket_regional_domain_name
    origin_id   = "S3-Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity[0].cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront Distribution for Mail Bucket on ${var.namespace}"
  default_root_object = "index.html"

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
    cloudfront_default_certificate = true
  }

  web_acl_id = data.aws_wafv2_web_acl.waf_global.arn

  tags = {
    Service   = "mail_bucket"
    Component = "common"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count   = local.enabled_mail_bucket ? 1 : 0
  comment = "Origin Access Identity for Mail Bucket on ${var.namespace}"
}

resource "aws_s3_bucket_policy" "mail_bucket_policy" {
  count  = local.enabled_mail_bucket ? 1 : 0
  bucket = aws_s3_bucket.mail_bucket[0].id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity[0].id}"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.mail_bucket[0].bucket}/*"
      }
    ]
  })
}

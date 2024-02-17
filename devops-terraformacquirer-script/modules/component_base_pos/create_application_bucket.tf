#####################################################################
# CRIA O BUCKET POR APLICAÇÃO
#####################################################################

locals {
  enabled_create_application_bucket = try(var.componentConfig["create_application_bucket"], false) && try(var.environmentConfig["application_bucket"], false)
}

resource "aws_s3_bucket" "create_application_bucket" {
  count         = local.enabled_create_application_bucket?1:0
  bucket        = "${var.namespace}-${var.componentConfig.name}-storage"
  force_destroy = var.force_destroy

  tags = {
    Service = "application_bucket"
    Component = "${var.componentConfig.name}"
  }
}

#resource "aws_s3_bucket_acl" "create_application_bucket" {
#  count  = local.enabled_create_application_bucket?1:0
#  bucket = aws_s3_bucket.create_application_bucket[0].id
#  acl    = "private"
#}

resource "aws_s3_bucket_public_access_block" "create_application_bucket" {
  count                   = local.enabled_create_application_bucket?1:0
  bucket                  = aws_s3_bucket.create_application_bucket[0].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "create_application_bucket" {
  count   = local.enabled_create_application_bucket?1:0
  bucket  = aws_s3_bucket.create_application_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_policy" "create_application_bucket" {
  count   = local.enabled_create_application_bucket?1:0
  name        = "${var.namespace}-${var.componentConfig.name}-application_bucket-rw-policy"
  path        = "/"
  description = "Política que permite escrita e leitura no bucket ${var.namespace}-${var.componentConfig.name}-storage"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.create_application_bucket[0].bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.create_application_bucket[0].bucket}"
        ]
      }
    ]
  })

  tags = {
    Service = "application_bucket"
    Component = "${var.componentConfig.name}"
  }
}

resource "aws_iam_role_policy_attachment" "create_application_bucket" {
  count      = local.enabled_create_application_bucket?1:0
  role       = local.service_account_role_name
  policy_arn = aws_iam_policy.create_application_bucket[0].arn
}
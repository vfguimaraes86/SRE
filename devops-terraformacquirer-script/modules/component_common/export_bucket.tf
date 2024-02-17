#####################################################################
# CRIA O BUCKET PARA EXPORTAÇÂO DE ARQUIVOS
#####################################################################
locals {
  enabled_export_bucket = try(var.environmentConfig["export_bucket"], false)
}

resource "aws_s3_bucket" "export_bucket" {
  count         = local.enabled_export_bucket ? 1 : 0
  bucket        = "${var.namespace}-export-storage"
  force_destroy = var.force_destroy

  tags = {
    Service   = "export_bucket"
    Component = "common"
  }
}

#resource "aws_s3_bucket_acl" "export_bucket" {
#  count = local.enabled_export_bucket?1:0
#  bucket = aws_s3_bucket.export_bucket.id
#  acl    = "private"
#}

resource "aws_s3_bucket_public_access_block" "export_bucket" {
  count  = local.enabled_export_bucket ? 1 : 0
  bucket = aws_s3_bucket.export_bucket[0].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "export_bucket" {
  count  = local.enabled_export_bucket ? 1 : 0
  bucket = aws_s3_bucket.export_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_policy" "export_bucket_write" {
  count       = local.enabled_export_bucket ? 1 : 0
  name        = "${var.namespace}-export_bucket-rw-policy"
  path        = "/"
  description = "Política que permite escrita e leitura no bucket ${var.namespace}-export-storage"

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
          "arn:aws:s3:::${var.namespace}-export-storage/*",
          "arn:aws:s3:::${var.namespace}-export-storage"
        ]
      }
    ]
  })

  tags = {
    Service   = "export_bucket"
    Component = "common"
  }
}

resource "aws_iam_policy" "export_bucket_read" {
  count       = local.enabled_export_bucket ? 1 : 0
  name        = "${var.namespace}-export_bucket-ro-policy"
  path        = "/"
  description = "Política que permite apenas leitura no bucket ${var.namespace}-export-storage"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.namespace}-export-storage/*",
          "arn:aws:s3:::${var.namespace}-export-storage"
        ]
      }
    ]
  })

  tags = {
    Service   = "export_bucket"
    Component = "common"
  }
}
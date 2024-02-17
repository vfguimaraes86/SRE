#####################################################################
# CRIA O BUCKET PARA ARQUIVOS do FILE REGISTRY
#####################################################################
locals {
  enabled_file_bucket = try(var.environmentConfig["file_bucket"], false)
}

resource "aws_s3_bucket" "file_bucket" {
  count         = local.enabled_file_bucket ? 1 : 0
  bucket        = "${var.namespace}-file-storage"
  force_destroy = var.force_destroy

  tags = {
    Service   = "file_bucket"
    Component = "common"
  }
}

#resource "aws_s3_bucket_acl" "file_bucket" {
#  count = local.enabled_file_bucket?1:0
#  bucket = aws_s3_bucket.file_bucket.id
#  acl    = "private"
#}

resource "aws_s3_bucket_public_access_block" "file_bucket" {
  count  = local.enabled_file_bucket ? 1 : 0
  bucket = aws_s3_bucket.file_bucket[0].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "file_bucket" {
  count  = local.enabled_file_bucket ? 1 : 0
  bucket = aws_s3_bucket.file_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_policy" "file_bucket_rw" {
  count       = local.enabled_file_bucket ? 1 : 0
  name        = "${var.namespace}-file_bucket-rw-policy"
  path        = "/"
  description = "Política que permite escrita e leitura no bucket file-storage"

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
          "arn:aws:s3:::${var.namespace}-file-storage/*",
          "arn:aws:s3:::${var.namespace}-file-storage",
          "arn:aws:s3:::${var.namespace}-file-copy-storage/*",
          "arn:aws:s3:::${var.namespace}-file-copy-storage"
        ]
      }
    ]
  })

  tags = {
    Service   = "file_bucket"
    Component = "common"
  }
}

resource "aws_iam_policy" "file_bucket_ro" {
  count       = local.enabled_file_bucket ? 1 : 0
  name        = "${var.namespace}-file_bucket-ro-policy"
  path        = "/"
  description = "Política que permite leitura no bucket file-storage"

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
          "arn:aws:s3:::${var.namespace}-file-storage/*",
          "arn:aws:s3:::${var.namespace}-file-storage",
          "arn:aws:s3:::${var.namespace}-file-copy-storage/*",
          "arn:aws:s3:::${var.namespace}-file-copy-storage"
        ]
      }
    ]
  })

  tags = {
    Service   = "file_bucket"
    Component = "common"
  }
}

##### BACKUP 

resource "aws_s3_bucket" "file_bucket_copy" {
  count         = local.enabled_file_bucket ? 1 : 0
  bucket        = "${var.namespace}-file-copy-storage"
  force_destroy = var.force_destroy

  tags = {
    Service   = "file_bucket"
    Component = "common"
  }
}

#resource "aws_s3_bucket_acl" "file_bucket_copy" {
#  count = local.enabled_file_bucket?1:0
#  bucket = aws_s3_bucket.file_bucket_copy.id
#  acl    = "private"
#}

resource "aws_s3_bucket_public_access_block" "file_bucket_copy" {
  count  = local.enabled_file_bucket ? 1 : 0
  bucket = aws_s3_bucket.file_bucket_copy[0].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "file_bucket_copy" {
  count  = local.enabled_file_bucket ? 1 : 0
  bucket = aws_s3_bucket.file_bucket_copy[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
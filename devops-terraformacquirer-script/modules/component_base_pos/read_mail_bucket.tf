#####################################################################
# ASSOCIA PERMISSÃO DE LEITURA PARA O BUCKET DE IMAGENS DE EMAIL
#####################################################################

locals {
    enabled_read_mail_bucket = try(var.componentConfig["read_mail_bucket"], false) && try(var.environmentConfig["mail_bucket"], false) && !try(var.componentConfig["write_mail_bucket"], false)
}

resource "aws_iam_role_policy_attachment" "read_mail_bucket" {
  count      = local.enabled_read_mail_bucket?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-mail_bucket-ro-policy"
}
#####################################################################
# ASSOCIA PERMISSÃO DE LEITURA PARA O BUCKET PARA EXPORTAÇÂO DE ARQUIVOS
#####################################################################

locals {
  enabled_read_export_bucket = try(var.componentConfig["read_export_bucket"], false) && try(var.environmentConfig["export_bucket"], false) && !try(var.componentConfig["write_export_bucket"], false)
}

resource "aws_iam_role_policy_attachment" "read_export_bucket" {
  count      = local.enabled_read_export_bucket?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-export_bucket-ro-policy"

  lifecycle {
    ignore_changes = [
      policy_arn
    ]
  }
}
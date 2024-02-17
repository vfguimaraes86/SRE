#####################################################################
# ASSOCIA O POLICY DE ESCRITA PARA O BUCKET DE ARQUIVOS DO SISTEMA
#####################################################################

locals {
  enabled_write_file_bucket = try(var.componentConfig["write_file_bucket"], false) && try(var.environmentConfig["file_bucket"], false)
}

resource "aws_iam_role_policy_attachment" "write_file_bucket" {
  count      = local.enabled_write_file_bucket?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-file_bucket-rw-policy"

  lifecycle {
    ignore_changes = [
      policy_arn
    ]
  }
}
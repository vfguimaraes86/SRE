#####################################################################
# ASSOCIA A POLICY DE PERMISSÃO FULL EM TODOS OS SECRETMAGENS DE TOKENS
#####################################################################

locals {
  enabled_write_tokens_secretmanager = try(var.componentConfig["write_tokens_secretmanager"], false) && try(var.environmentConfig["tokens_secretmanager"], false)
}
resource "aws_iam_role_policy_attachment" "write_tokens_secretmanager" {
  count      = local.enabled_write_tokens_secretmanager?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-tokens_secretmanager-rw-policy"

  lifecycle {
    ignore_changes = [
      policy_arn
    ]
  }
}
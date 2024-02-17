#####################################################################
# ASSOCIA A POLICY QUE PERMITE LER OS DADOS SENSIVEIS DAS OUTRAS APLICAÇÔES
#####################################################################

locals {
  enabled_read_application_data_secretmanager = try(var.componentConfig["read_application_data_secretmanager"], false) && try(var.environmentConfig["application_data_secretmanager"], false) && !try(var.componentConfig["write_application_data_secretmanager"], false)
}

resource "aws_iam_role_policy_attachment" "read_application_data_secretmanager" {
  count      = local.enabled_read_application_data_secretmanager?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-application_data_secretmanager-ro-policy"
}
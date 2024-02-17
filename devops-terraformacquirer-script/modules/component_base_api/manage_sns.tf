#####################################################################
# ASSOCIA A POLICY PARA GERENCIAR TOPICOS NO SNS
#####################################################################

locals {
  enabled_manage_sns = try(var.componentConfig["manage_sns"], false) && try(var.environmentConfig["sns"], false)
}

resource "aws_iam_role_policy_attachment" "manage_sns" {
  count      = local.enabled_manage_sns?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-sns-manage-policy"

  lifecycle {
    ignore_changes = [
      policy_arn
    ]
  }
}
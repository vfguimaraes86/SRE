#####################################################################
# ASSOCIA A POLICY PARA ENVIO DO EMAIL
#####################################################################

locals {
  enabled_send_mail = try(var.componentConfig["send_mail"], false) && try(var.environmentConfig["mail_service"], false)
}

resource "aws_iam_role_policy_attachment" "send_mail" {
  count      = local.enabled_send_mail?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-mail_service-send-policy"

  lifecycle {
    ignore_changes = [
      policy_arn
    ]
  }
}
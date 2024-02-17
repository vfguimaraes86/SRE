#####################################################################
# ASSOCIA A POLICY PARA PUBLICAR NO SQS
#####################################################################

locals {
  enabled_consume_transaction_sqs = try(var.componentConfig["consume_transaction_sqs"], false) && try(var.environmentConfig["transaction_sqs"], false)
}

resource "aws_iam_role_policy_attachment" "consume_transaction_sqs" {
  count      = local.enabled_consume_transaction_sqs?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-transaction_sqs-consume-policy"
}
#####################################################################
# CRIA A POLICY DE PERMISSÃO FULL EM TODOS OS SECRETMAGENS DE TOKENS
#####################################################################

locals {
  enabled_tokens_secretmanager = try(var.environmentConfig["tokens_secretmanager"], false)
}

resource "aws_iam_policy" "tokens_secretmanager" {
  count       = local.enabled_tokens_secretmanager ? 1 : 0
  name        = "${var.namespace}-tokens_secretmanager-rw-policy"
  path        = "/"
  description = "Política que permite gravar os tokens no secret"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : ["secretsmanager:*"],
      "Resource" : ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:/${var.namespace}/tokens/*"]
    }]
  })

  tags = {
    Service   = "tokens_secretmanager"
    Component = "common"
  }
}
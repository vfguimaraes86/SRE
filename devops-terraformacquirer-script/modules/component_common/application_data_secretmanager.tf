#####################################################################
# CRIA O POLICY QUE PERMITE LER OS DADOS SENSIVEIS DAS OUTRAS APLICAÇÔES
#####################################################################
locals {
  enabled_application_data_secretmanager = try(var.environmentConfig["application_data_secretmanager"], false)
}

resource "aws_iam_policy" "application_data_secretmanager" {
  count       = local.enabled_application_data_secretmanager ? 1 : 0
  name        = "${var.namespace}-application_data_secretmanager-ro-policy"
  path        = "/"
  description = "Política que permite leitura de secrets de outras aplicações"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource" : [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:/${var.namespace}/secrets/*",
      ]
    }]
  })

  tags = {
    Service   = "application_data_secretmanager"
    Component = "common"
  }
}
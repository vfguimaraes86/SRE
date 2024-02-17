#####################################################################
# CRIA E ASSOCIA O POLICY QUE PERMITE GUARDAR OS DADOS SENSIVEIS
#####################################################################

locals {
   enabled_write_application_data_secretmanager = try(var.componentConfig["write_application_data_secretmanager"], false) && try(var.environmentConfig["application_data_secretmanager"], false)
}

resource "aws_iam_policy" "write_application_data_secretmanager" {
  count       = local.enabled_write_application_data_secretmanager?1:0
  name        = "${var.namespace}-${var.componentConfig.name}-application_data_secretmanager-rw-policy"
  path        = "/"
  description = "Política que permite acesso full ao secretmanager para guardar dados sensiveis"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "secretsmanager:*"
      ],
      "Resource" : [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:/${var.namespace}/secrets/${var.componentConfig.name}/*",
      ]
    },{
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
    Service = "application_data_secretmanager"
    Component = "${var.componentConfig.name}"
  }
}

resource "aws_iam_role_policy_attachment" "write_application_data_secretmanager" {
  count      = local.enabled_write_application_data_secretmanager?1:0
  role       = local.service_account_role_name
  policy_arn = aws_iam_policy.write_application_data_secretmanager[0].arn
}

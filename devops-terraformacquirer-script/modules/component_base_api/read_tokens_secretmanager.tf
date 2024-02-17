#####################################################################
# CRIA O SECRET MANAGER QUE ARMAZENA OS TOKENS DE INTEGRAÇÃO
#####################################################################

locals {
  enabled_read_tokens_secretmanager = try(var.componentConfig["read_tokens_secretmanager"], false) && try(var.environmentConfig["tokens_secretmanager"], false)
  policy_read_tokens_secretmanager = local.enabled_read_tokens_secretmanager && !try(var.componentConfig["write_tokens_secretmanager"], false)
  create_only_policy_for_secretsmanager = try(var.componentConfig["only_policy_for_secretsmanager"], false)
}

resource "aws_secretsmanager_secret" "read_tokens_secretmanager" {
  count                   = local.enabled_read_tokens_secretmanager && !local.create_only_policy_for_secretsmanager ? 1 : 0
  name                    = "/${var.namespace}/tokens/${var.componentConfig.name}"
  recovery_window_in_days = var.force_destroy?0:7
  description             = "Tokens para integração do ${var.componentConfig.name}"

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Service = "tokens_secretmanager"
    Component = "${var.componentConfig.name}"
  }
}

resource "aws_secretsmanager_secret_version" "read_tokens_secretmanager" {
  count         = local.enabled_read_tokens_secretmanager && !local.create_only_policy_for_secretsmanager ? 1 : 0
  secret_id     = aws_secretsmanager_secret.read_tokens_secretmanager[0].id
  secret_string = "{}"
  
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_policy" "read_tokens_secretmanager" {
  count       = local.policy_read_tokens_secretmanager?1:0
  name        = "${var.namespace}-${var.componentConfig.name}-tokens_secretmanager-ro-policy"
  path        = "/"
  description = "Política que permite leitura do tokens pela ${var.componentConfig.name}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
      "Resource" : ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:/${var.namespace}/tokens/${var.componentConfig.name}*"]
    }]
  })

  tags = {
    Service = "tokens_secretmanager"
    Component = "${var.componentConfig.name}"
  }
}

resource "aws_iam_role_policy_attachment" "read_tokens_secretmanager" {
  count      = local.policy_read_tokens_secretmanager?1:0
  role       = local.service_account_role_name
  policy_arn = aws_iam_policy.read_tokens_secretmanager[0].arn
}
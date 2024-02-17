#####################################################################
# CRIA O SECRET MANAGER QUE ARMAZENA OS DADOS SENSÍVEIS DA APLICAÇÃO
#####################################################################

locals {
  enabled_create_application_env_secretmanager = try(var.componentConfig["create_application_env_secretmanager"], false) && try(var.environmentConfig["application_env_secretmanager"], false)
}

resource "aws_secretsmanager_secret" "create_application_env_secretmanager" {
  count                   = local.enabled_create_application_env_secretmanager && !local.create_only_policy_for_secretsmanager ? 1 : 0
  name                    = "/${var.namespace}/${var.componentConfig.name}"
  recovery_window_in_days = var.force_destroy?0:7
  description             = "Conteúdo sensível da aplicação ${var.componentConfig.name}"

  tags = {
    Service = "application_env_secretmanager"
    Component = "${var.componentConfig.name}"
  }
}

resource "aws_secretsmanager_secret_version" "create_application_env_secretmanager" {
  count         = local.enabled_create_application_env_secretmanager && !local.create_only_policy_for_secretsmanager ? 1 : 0
  secret_id     = aws_secretsmanager_secret.create_application_env_secretmanager[0].id
  secret_string = "{}"
}

resource "aws_iam_policy" "create_application_env_secretmanager" {
  count       = local.enabled_create_application_env_secretmanager?1:0
  name        = "${var.namespace}-${var.componentConfig.name}-application_env_secretmanager-ro-policy"
  path        = "/"
  description = "Política que permite leitura secret environment pela ${var.componentConfig.name}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
      "Resource" : ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:/${var.namespace}/${var.componentConfig.name}*"]
    }]
  })

  tags = {
    Service = "application_env_secretmanager"
    Component = "${var.componentConfig.name}"
  }
}

resource "aws_iam_role_policy_attachment" "create_application_env_secretmanager" {
  count      = local.enabled_create_application_env_secretmanager?1:0
  role       = local.service_account_role_name
  policy_arn = aws_iam_policy.create_application_env_secretmanager[0].arn
}
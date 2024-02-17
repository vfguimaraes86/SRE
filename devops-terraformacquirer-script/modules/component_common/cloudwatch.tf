#####################################################################
# CRIA O LOG PARA O EKS
#####################################################################
locals {
  enabled_cloudwatch = try(var.environmentConfig["cloudwatch"], false)
}

resource "aws_cloudwatch_log_group" "cloudwatch" {
  count = local.enabled_cloudwatch ? 1 : 0
  name  = "/dock/applications/${var.namespace}"

  retention_in_days = var.cloudwatch_retention

  tags = {
    Service   = "cloudwatch"
    Component = "common"
  }
}

#resource "aws_cloudwatch_log_group" "applications_stdout_log_group" {
#  count = local.enabled_cloudwatch ? 1 : 0
#  name  = "/dock/applications/${var.namespace}/stdout"
#
#  retention_in_days = 30
#
#  tags = {
#    Service   = "cloudwatch"
#    Component = "common"
#  }
#}


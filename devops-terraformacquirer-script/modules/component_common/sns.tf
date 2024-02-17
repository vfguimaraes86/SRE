#####################################################################
# CRIA POLICY PARA O SNS
#####################################################################

locals {
  enabled_sns = try(var.environmentConfig["sns"], false)
}

resource "aws_iam_policy" "sns_publish" {
  count       = local.enabled_sns ? 1 : 0
  name        = "${var.namespace}-sns-publish-policy"
  path        = "/"
  description = "Política que permite publicar no SNS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish"
        ],
        "Resource" : "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })

  tags = {
    Service   = "sns"
    Component = "common"
  }
}

resource "aws_iam_policy" "sns_manage" {
  count       = local.enabled_sns ? 1 : 0
  name        = "${var.namespace}-sns-manage-policy"
  path        = "/"
  description = "Política que permite gerenciar tópicos SNS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "sns:CreateTopic",
          "sns:DeleteTopic",
          "sns:Subscribe",
          "sns:ListSubscriptionsByTopic",
          "sns:Unsubscribe",
          "sns:Publish"
        ],
        "Resource" : [
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:*",
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:*:*"
        ]
      }
    ]
  })

  tags = {
    Service   = "sns"
    Component = "common"
  }
}
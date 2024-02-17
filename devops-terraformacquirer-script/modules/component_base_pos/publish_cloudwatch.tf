
locals {
  enabled_publish_cloudwatch = try(var.componentConfig["publish_cloudwatch"], false) && try(var.environmentConfig["cloudwatch"], false)
}

resource "aws_iam_policy" "publish_cloudwatch" {
  count   = local.enabled_publish_cloudwatch?1:0
  name        = "${var.namespace}-${var.componentConfig.name}-cloudwatch-policy"
  path        = "/"
  description = "Política que permite escrita de log no cloudwatch ${var.namespace}-${var.componentConfig.name}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/dock/applications/${var.namespace}:log-stream:${var.componentConfig.name}"
        ]
      }
    ]
  })

  tags = {
    Service = "cloudwatch"
    Component = "${var.componentConfig.name}"
  }
}

resource "aws_iam_role_policy_attachment" "publish_cloudwatch" {
  count      = local.enabled_publish_cloudwatch?1:0
  role       = local.service_account_role_name
  policy_arn = aws_iam_policy.publish_cloudwatch[0].arn
}
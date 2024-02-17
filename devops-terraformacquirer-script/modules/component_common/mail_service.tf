#####################################################################
# CRIA A POLICY PARA ENVIO DO EMAIL
#####################################################################
locals {
  enabled_mail_service = try(var.environmentConfig["mail_service"], false)
}

resource "aws_iam_policy" "send_mail" {
  count       = local.enabled_mail_service ? 1 : 0
  name        = "${var.namespace}-mail_service-send-policy"
  path        = "/"
  description = "Política que permite envio de e-mails pela API da AWS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Service   = "mail_service"
    Component = "common"
  }
}
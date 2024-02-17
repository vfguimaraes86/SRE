########################################################################
# CRIA A POLICY DE PERMISSÃO PARA FAZER LIMPEZA DE CACHE DO CLOUDFRONT
########################################################################

resource "aws_iam_policy" "create_invalidation_policy" {
  name        = "${var.namespace}-${var.componentConfig.name}-invalidation"
  path        = "/"
  description = "Política que permite limpar chache do cloudfront"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations"
      ],
      "Resource" : ["${data.aws_cloudfront_distribution.portal_cloudfront.arn}"]
    }]
  })

  tags = {
    Service   = "invalidation_policy"
    Component = "${var.componentConfig.name}"
  }
}


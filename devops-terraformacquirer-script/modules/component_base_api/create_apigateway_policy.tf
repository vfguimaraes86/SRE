#####################################################################
# CRIA A POLICY DE PERMISSÃO PARA FAZER CHAMADA NO APIGATEWAY
#####################################################################

locals {
  enabled_policy_apigateway = try(var.componentConfig["create_apigateway_policy"], false)
}

resource "aws_iam_policy" "create_apigateway_policy" {
  count       = local.enabled_policy_apigateway ? 1 : 0
  name        = "${var.namespace}-apigateway"
  path        = "/"
  description = "Política que permite chamar o ApiGateway"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action": [
        "apigateway:POST",
        "apigateway:GET"
      ],
      "Resource" : ["*"]
    }]
  })

  tags = {
    Service   = "apigateway_policy"
    Component = "${var.componentConfig.name}"
  }
}
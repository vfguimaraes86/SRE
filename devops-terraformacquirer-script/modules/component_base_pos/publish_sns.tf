#####################################################################
# ASSOCIA A POLICY PARA PUBLICAR NO SNS
#####################################################################

locals {
  enabled_publish_sns = try(var.componentConfig["publish_sns"], false) && try(var.environmentConfig["sns"], false) && !try(var.componentConfig["manage_sns"], false)
}

resource "aws_iam_role_policy_attachment" "publish_sns" {
  count      = local.enabled_publish_sns?1:0
  role       = local.service_account_role_name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.namespace}-sns-publish-policy"
}
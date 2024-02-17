#####################################################################
# CRIA A ROLE A SER USADA PELO POD
#####################################################################

resource "aws_iam_role" "service_account_role" {
  name = "${var.namespace}-${var.componentConfig.name}-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.issuer}:aud" : "sts.amazonaws.com",
            "${local.issuer}:sub" : "system:serviceaccount:${var.namespace}:${var.componentConfig.name}"
          }
        }
      }
    ]
  })

#  lifecycle {
#    ignore_changes = [assume_role_policy]
#  }

tags = {
    Service = "service_account_role"
    Component = "${var.componentConfig.name}"
  }
}

locals {
  issuer                      = replace("${data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer}", "https://", "")
  service_account_role_name   =  aws_iam_role.service_account_role.name
}


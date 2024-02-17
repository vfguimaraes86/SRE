#####################################################################
# CRIA O RESOURCE GROUPS
#####################################################################

locals {
  enabled_resourcegroups = try(var.environmentConfig["resourcegroups"], false)
}

resource "aws_resourcegroups_group" "resourcegroups" {
  count = local.enabled_resourcegroups ? 1 : 0
  name  = "${var.namespace}-eks"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "ResourceGroup",
      "Values": ["${var.namespace}-eks"]
    }
  ]
}
JSON
  }

  tags = {
    Service   = "resourcegroups"
    Component = "common"
  }
}
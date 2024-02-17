locals {
  eks_cluster_name = coalesce(var.eks_cluster_name,var.environment)
}

provider "aws" {
  region                   = coalesce(var.region,local.default_values["region"])
  profile                  = var.environment
  shared_credentials_files = ["~/.aws/credentials"]

  default_tags {
    tags = {
      Environment   = var.environment
      Namespace     = var.namespace
      Billing       = "infrastructure"
      Provisioner   = "Terraform"
      ResourceGroup = "${var.namespace}-eks"
    }
  }
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:${coalesce(var.region,local.default_values["region"])}:${data.aws_caller_identity.current.account_id}:cluster/${local.eks_cluster_name}"
}

module "component_common" {
  source                          = "../component_common"
  environment                     = var.environment 
  namespace                       = var.namespace
  region                          = coalesce(var.region,local.default_values["region"])
  hosted_zone_id                  = coalesce(var.hosted_zone_id,local.default_values["hosted_zone_id"])
  force_destroy                   = var.force_destroy
  domain                          = var.domain
  environmentConfig               = var.environmentConfig
  api_components                  = var.api_components
  pos_components                  = var.pos_components
  portal_components               = var.portal_components
  inbound_cidrs                   = local.default_values["inbound_cidrs"]
  path                            = path.module
  vpc                             = local.default_values["vpc"]
  restricted_subnets_ids          = local.default_values["restricted_subnets_ids"]
  public_subnets_ids              = local.default_values["public_subnets_ids"]
  private_subnets_ids             = local.default_values["private_subnets_ids"]
  cloudfront_timeout              = coalesce(var.cloudfront_timeout,local.default_values["cloudfront_timeout"])
  cloudwatch_retention            = coalesce(var.cloudwatch_retention,local.default_values["cloudwatch_retention"])
  waf_global                      = local.default_values["waf_global"]
  waf_regional                    = local.default_values["waf_regional"]
  eip_allocation                  = local.default_values["eip_allocation"]
  eks_cluster_name                = local.eks_cluster_name
  create_static_bucket            = var.create_static_bucket
}

locals {
  api_components_map = { for comp in var.api_components : comp.name => comp }
}
module "component" {
  for_each                        = local.api_components_map
  source                          = "../component_base_api"
  environment                     = var.environment  
  namespace                       = var.namespace
  region                          = coalesce(var.region,local.default_values["region"])
  hosted_zone_id                  = coalesce(var.hosted_zone_id,local.default_values["hosted_zone_id"])
  force_destroy                   = var.force_destroy
  domain                          = var.domain
  environmentConfig               = var.environmentConfig
  componentConfig                 = each.value
  inbound_cidrs                   = local.default_values["inbound_cidrs"]
  path                            = path.module
  cloudfront_id                   = module.component_common.api_cloudfront_id
  waf_regional                    = local.default_values["waf_regional"]
  eks_cluster_name                = local.eks_cluster_name 

  depends_on = [module.component_common]
}

locals {
  portal_components_map = { for comp in var.portal_components : comp.name => comp}
}
module "portal_component" {
  for_each                        = local.portal_components_map
  source                          = "../component_base_portal"
  environment                     = var.environment
  namespace                       = var.namespace
  region                          = coalesce(var.region,local.default_values["region"])
  hosted_zone_id                  = coalesce(var.hosted_zone_id,local.default_values["hosted_zone_id"])
  force_destroy                   = var.force_destroy
  domain                          = var.domain
  environmentConfig               = var.environmentConfig
  componentConfig                 = each.value
  inbound_cidrs                   = local.default_values["inbound_cidrs"]
  cloudfront_id                   = module.component_common.portal_cloudfront_id
  eks_cluster_name                = local.eks_cluster_name


  depends_on = [module.component_common]
}

locals {
  pos_components_map = { for comp in var.pos_components : comp.name => comp}
}
module "pos_component" {
  for_each                        = local.pos_components_map
  source                          = "../component_base_pos"
  environment                     = var.environment
  namespace                       = var.namespace
  region                          = coalesce(var.region,local.default_values["region"])
  hosted_zone_id                  = coalesce(var.hosted_zone_id,local.default_values["hosted_zone_id"])
  force_destroy                   = var.force_destroy
  domain                          = var.domain
  environmentConfig               = var.environmentConfig
  componentConfig                 = each.value
  inbound_cidrs                   = local.default_values["inbound_cidrs"]
  path                            = path.module
  waf_regional                    = local.default_values["waf_regional"]
  eks_cluster_name                = local.eks_cluster_name

  depends_on = [module.component_common]
}
#####################################################################
# CARREGA PREFIX LIST CLOUDFRONT
#####################################################################

data "aws_prefix_list" "cloudfront_muxipay-dev_ohio" {
  prefix_list_id = "pl-b6a144df"
}
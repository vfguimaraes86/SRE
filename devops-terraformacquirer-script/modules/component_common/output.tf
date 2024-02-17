output "portal_cloudfront_id" {
  value = local.enabled_portal_cloudfront ? aws_cloudfront_distribution.portal_cloudfront[0].id : null
}

output "api_cloudfront_id" {
  value = local.enabled_api_cloudfront ? aws_cloudfront_distribution.api_cloudfront[0].id : null
}
######################################################################
## CARREGA OS DADOS DO APIGATEWAY
######################################################################
#
#locals {
#  enabled_apigateway_lambda = try(var.environmentConfig["apigateway_lambda"], false)
#  adjusted_env_name_multiacq = replace(var.namespace, "muxipay-", "")
#  lambda_invoke_url_no_https = replace(aws_api_gateway_deployment.apigw_multiacq_deploy[0].invoke_url, "https://", "")
#  apigateway_endpoint_prefix = element(split("/", local.lambda_invoke_url_no_https), 0)
#  apigateway_endpoint_sufix  = element(split("/", local.lambda_invoke_url_no_https), 1)
#}
#
######################################################################
## CRIA O APIGATEWAY
######################################################################
#resource "aws_api_gateway_rest_api" "apigw_multiacq_rest" {
#  count       = local.enabled_apigateway_lambda ? 1 : 0
#  name        = "${var.namespace}-ecommerce-multiacq"
#  description = "ApiGateway ecommerce-multiacq with lambda"
#  endpoint_configuration {
#    types = ["REGIONAL"]  # Defina o endpoint_type como REGIONAL
#  }
#
#  body = file("${path.module}/apigateway_lambda/swagger/ecommerce-multiacq-paymentlink-${local.adjusted_env_name_multiacq}.yaml")
#}
#
#resource "aws_api_gateway_resource" "apigw_multiacq_res_v1" {
#  count       = local.enabled_apigateway_lambda ? 1 : 0
#  rest_api_id = aws_api_gateway_rest_api.apigw_multiacq_rest[0].id
#  parent_id   = aws_api_gateway_rest_api.apigw_multiacq_rest[0].root_resource_id
#  path_part   = "acquirer"
#}
#
#resource "aws_api_gateway_method" "apigw_multiacq_rest_method_v1" {
#  count         = local.enabled_apigateway_lambda ? 1 : 0
#  rest_api_id   = aws_api_gateway_rest_api.apigw_multiacq_rest[0].id
#  resource_id   = aws_api_gateway_resource.apigw_multiacq_res_v1[0].id
#  http_method   = "POST"
#  authorization = "NONE"
#}
#
#resource "aws_api_gateway_integration" "apigw_multiacq_integr" {
#  count         = local.enabled_apigateway_lambda ? 1 : 0
#  rest_api_id   = aws_api_gateway_rest_api.apigw_multiacq_rest[0].id
#  resource_id   = aws_api_gateway_resource.apigw_multiacq_res_v1[0].id
#  http_method   = aws_api_gateway_method.apigw_multiacq_rest_method_v1[0].http_method
#
#  integration_http_method = "POST"
#  type                    = "AWS_PROXY"
#  uri                     = aws_lambda_function.lambda_ecommerce-multiacq[0].invoke_arn
#}
#
#resource "aws_api_gateway_deployment" "apigw_multiacq_deploy" {
#  count       = local.enabled_apigateway_lambda ? 1 : 0
#  depends_on  = [aws_api_gateway_integration.apigw_multiacq_integr]
#
#  rest_api_id = aws_api_gateway_rest_api.apigw_multiacq_rest[0].id
#  stage_name  = "prod"
#}
#
#######################################################################
## CRIA O LAMBDA ECOMMERCE MULTIACQUIRER
#######################################################################
#
#resource "aws_lambda_function" "lambda_ecommerce-multiacq" {
#  count         = local.enabled_apigateway_lambda ? 1 : 0
#  filename      = "${path.module}/apigateway_lambda/lambda_files/multiacq.zip"
#  function_name = "${var.namespace}-ecommerce-multiacq"
#  description   = "Lambda do ecommerce-multiacq ${var.namespace}"
#  role          = aws_iam_role.ecommerce_multiacq[0].arn
#  handler       = "lambda_function.lambda_handler"
#  runtime       = "python3.9"
#  source_code_hash = filebase64sha256("${path.module}/apigateway_lambda/lambda_files/multiacq.zip")
#  architectures = ["arm64"]
#  memory_size  = 512
#  timeout      = 5
#
#  environment {
#    variables = {
#      CARDBRAND_URL = "https://cardbrand${local.route53_domain}/v1/card_products/bin"
#      GW_GLOBAL_URL   = "https://gw-global-ecommerce${local.route53_domain}"
#      GW_POSTILION_URL   = "https://gw-postilion-ecommerce${local.route53_domain}"
#    }
#  }
#
#  vpc_config {
#    subnet_ids         = var.private_subnets_ids
#    security_group_ids = [aws_security_group.ecommerce_multiacq[0].id]
#  }
#
#  layers = [
#    aws_lambda_layer_version.lambda_multiacq[0].arn,
#    aws_lambda_layer_version.request_multiacq[0].arn,
#    aws_lambda_layer_version.urllib_multiacq[0].arn
#  ]
#
#  tags = {
#    Service = "lambda-ecommerce-multiacq"
#    Component = "common"
#  }
#}
#
#resource "aws_lambda_layer_version" "lambda_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  filename            = "${path.module}/apigateway_lambda/lambda_files/multiacq.zip"
#  layer_name          = "multiacq"
#  compatible_runtimes = ["python3.9"]
#  compatible_architectures = ["x86_64", "arm64"]
#}
#
#resource "aws_lambda_layer_version" "request_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  filename            = "${path.module}/apigateway_lambda/lambda_files/requests.zip"
#  layer_name          = "request"
#  compatible_runtimes = ["python3.9"]
#  compatible_architectures = ["arm64"]
#}
#
#resource "aws_lambda_layer_version" "urllib_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  filename            = "${path.module}/apigateway_lambda/lambda_files/urllib3.zip"
#  layer_name          = "urllib"
#  compatible_runtimes = ["python3.9"]
#  compatible_architectures = ["arm64"]
#}
#
#######################################################################
### CRIA O SECURITY GROUP DO LAMBDA ECOMMERCE MULTIACQUIRER
#######################################################################
#resource "aws_security_group" "ecommerce_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  name = "${var.namespace}-ecommerce-multiacq"
#  description = "Security Group for Lambda function"
#  vpc_id = var.vpc
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#    description = "Permite trafego indo para qualquer lugar"
#  }
#
#  tags = {
#    Service = "security-group-ecommerce-multiacq"
#    Component = "common"
#  }
#}
#
#resource "aws_security_group_rule" "https_own_vpc_lambda_multiacq_443" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  type              = "ingress"
#  from_port         = 443
#  to_port           = 443
#  protocol          = "tcp"
#  security_group_id = aws_security_group.ecommerce_multiacq[0].id
#  cidr_blocks       = ["${data.aws_vpc.vpc.cidr_block}"]
#  description       = "Permite entrada 443 da propria vpc"
#}
#
#resource "aws_security_group_rule" "https_own_vpc_lambda_multiacq_80" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  type              = "ingress"
#  from_port         = 80
#  to_port           = 80
#  protocol          = "tcp"
#  security_group_id = aws_security_group.ecommerce_multiacq[0].id
#  cidr_blocks       = ["${data.aws_vpc.vpc.cidr_block}"]
#  description       = "Permite entrada 80 da propria vpc"
#}
#
#resource "aws_security_group_rule" "https_vpn_lambda_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  type              = "ingress"
#  from_port         = 443
#  to_port           = 443
#  protocol          = "tcp"
#  security_group_id = aws_security_group.ecommerce_multiacq[0].id
#  cidr_blocks       = ["10.255.128.0/19"]
#  description       = "Permite entrada 443 da VPN"
#}
#
#######################################################################
## CRIA O ROUTE 53 ECOMMERCE MULTIACQUIRER
#######################################################################
#
#resource "aws_route53_record" "dns-multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  zone_id = var.hosted_zone_id
#  name    = var.domain != "" ? "ecommerce-multiacq.${var.domain}" : "ecommerce-multiacq"
#  type    = "A"
#
#  alias {
#    name                   = aws_cloudfront_distribution.multiacq_cloudfront[0].domain_name
#    zone_id                = aws_cloudfront_distribution.multiacq_cloudfront[0].hosted_zone_id
#    evaluate_target_health = true
#  }
#}
#
######################################################################
## CRIA CLOUDFRONT PARA AS MULTIACQ
######################################################################
#resource "aws_cloudfront_distribution" "multiacq_cloudfront" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  origin {
#    domain_name = local.apigateway_endpoint_prefix
#    origin_id   = "${aws_api_gateway_rest_api.apigw_multiacq_rest[0].name}"
#    origin_path = "/${local.apigateway_endpoint_sufix}"
#
#    custom_origin_config {
#      http_port              = 80
#      https_port             = 443
#      origin_protocol_policy = "https-only"
#      origin_ssl_protocols   = ["TLSv1.2"]
#      origin_read_timeout    = 60
#    }
#  }
#
#  enabled             = true
#  is_ipv6_enabled     = false
#  comment             = "CloudFront Distribuition for APIs on ${var.namespace}"
#  default_root_object = "index.html"
#
#  aliases = ["ecommerce-multiacq${local.route53_domain}"]
#
#  default_cache_behavior {
#    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#    cached_methods   = ["GET", "HEAD", "OPTIONS"]
#    target_origin_id = "${aws_api_gateway_rest_api.apigw_multiacq_rest[0].name}"
#
#    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
#    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
#
#    viewer_protocol_policy = "redirect-to-https"
#  }
#
#  restrictions {
#    geo_restriction {
#      restriction_type = "none"
#    }
#  }
#
#  viewer_certificate {
#    cloudfront_default_certificate = false
#    acm_certificate_arn            = data.aws_acm_certificate.certificate_manager_us.arn
#    minimum_protocol_version       = "TLSv1.2_2021"
#    ssl_support_method             = "sni-only"
#
#  }
#
#  web_acl_id = data.aws_wafv2_web_acl.waf_global.arn
#
#  tags = {
#    Service   = "api-cloudfront-ecommerce-multiacq"
#    Component = "common"
#  }
#}
#
#######################################################################
## CRIA A ROLE DO LAMBDA MULTIACQUIRER
#######################################################################
#resource "aws_iam_role" "ecommerce_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  name = "${var.namespace}-role-ecommerce-multiacq"
#  assume_role_policy = data.aws_iam_policy_document.ecommerce_multiacq[0].json
#
#  tags = {
#    Service = "iam-role-ecommerce-multiacq"
#    Component = "common"
#  }
#}
#
#data "aws_iam_policy_document" "ecommerce_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  statement {
#    actions = ["sts:AssumeRole"]
#    principals {
#      type        = "Service"
#      identifiers = ["lambda.amazonaws.com"]
#    }
#  }
#}
#
#resource "aws_iam_policy" "ecommerce_multiacq_basic" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  name        = "${var.namespace}_AWSLambdaBasicExecutionRole"
#
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": "logs:CreateLogGroup",
#      "Resource": "arn:aws:logs:us-east-2:266241576141:*"
#    },
#    {
#      "Effect": "Allow",
#      "Action": [
#        "logs:CreateLogStream",
#        "logs:PutLogEvents"
#      ],
#      "Resource": [
#        "arn:aws:logs:us-east-2:266241576141:log-group:/aws/lambda/ecommerce_multiacq:*"
#      ]
#    }
#  ]
#}
#EOF
#
#  tags = {
#    Service = "policy-ecommerce-multiacq"
#    Component = "common"
#  }
#}
#
#resource "aws_iam_policy" "ecommerce_multiacq_urllib" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  name        = "${var.namespace}-ecommerce-multiacq-urllib"
#
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Sid": "Statement1",
#      "Effect": "Allow",
#      "Action": [
#        "secretsmanager:DescribeSecret",
#        "secretsmanager:GetSecretValue",
#        "secretsmanager:PutSecretValue",
#        "ec2:DescribeNetworkInterfaces",
#        "ec2:CreateNetworkInterface",
#        "ec2:DeleteNetworkInterface",
#        "ec2:DescribeInstances",
#        "ec2:AttachNetworkInterface",
#        "secretsmanager:ListSecretVersionIds",
#        "secretsmanager:UpdateSecretVersionStage",
#        "secretsmanager:UpdateSecret"
#      ],
#      "Resource": [
#        "*"
#      ]
#    }
#  ]
#}
#EOF
#
#  tags = {
#    Service = "policy-ecommerce-multiacq"
#    Component = "common"
#  }
#}
#
#resource "aws_iam_role_policy_attachment" "attach_policy_one_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  role       = aws_iam_role.ecommerce_multiacq[0].name
#  policy_arn = aws_iam_policy.ecommerce_multiacq_basic[0].arn
#}
#
#resource "aws_iam_role_policy_attachment" "attach_policy_two_multiacq" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  role       = aws_iam_role.ecommerce_multiacq[0].name
#  policy_arn = aws_iam_policy.ecommerce_multiacq_urllib[0].arn
#}
#
#######################################################################
## CRIA NLB INTERNO PARA GW-ECOMMERCE
#######################################################################
#
#resource "kubernetes_service_v1" "create_nlb_ecoomerce-int" {
#  count = local.enabled_apigateway_lambda ? 1 : 0
#  metadata {
#    name      = "nlb-${var.namespace}-ecommerce-int"
#    namespace = var.namespace
#    annotations = {
#      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb"
#      #"service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "ip"
#      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "instance"
#      "service.beta.kubernetes.io/aws-load-balancer-name" : "nlb-${var.namespace}-ecommerce-int"
#      "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" : "ipv4"
#      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "TCP"
#      #      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "SSL"
#      #      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "2020, 2021, 2022"
#      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal"
#      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" : "Environment=${var.environment},Namespace=${var.namespace},Billing=infrastructure,Provisioner=Terraform,ResourceGroup=${var.namespace}-eks"
#      #      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : "${data.aws_acm_certificate.certificate_manager.arn}"
#      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
#      #      "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" : "ELBSecurityPolicy-TLS13-1-2-2021-06"
#      "service.beta.kubernetes.io/inbound-cidrs" : "${var.inbound_cidrs}"
#      "service.beta.kubernetes.io/aws-load-balancer-subnets": "${var.private_subnets_ids[0]}"
#      #      "service.beta.kubernetes.io/wafv2-acl-arn" : "${data.aws_wafv2_web_acl.waf_regional.arn}"
#    }
#  }
#
#  spec {
#    #load_balancer_source_ranges = ["0.0.0.0/0"]
#    #external_name = "${var.componentConfig.sub_domain}.${local.route53_domain}"
#    selector = {
#      app = "ecommerce-internal"
#    }
#
#    port {
#      name        = "global-ecommerce"
#      protocol    = "TCP"
#      port        = 4443
#      target_port = 4443
#    }
#
#    port {
#      name        = "postilion-ecommerce"
#      protocol    = "TCP"
#      port        = 4444
#      target_port = 4444
#    }
#    type = "LoadBalancer"
#  }
#}
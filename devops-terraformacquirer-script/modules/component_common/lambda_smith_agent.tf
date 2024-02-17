#####################################################################
# CRIA O ALB E LAMBDA FUNCTION
#####################################################################
locals {
  enabled_lambda_smith_agent = try(var.environmentConfig["lambda_smith_agent"], false)
  adjusted_env_name = replace(var.environment, "muxipay-", "")
}


resource "aws_lb" "alb_lambda_smith_agent" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  name               = "${var.namespace}-smith-agent"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lambda_smith_agent[0].id]
  subnets            = var.private_subnets_ids

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

resource "aws_lb_listener" "listener_lambda_smith_agent" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  load_balancer_arn = aws_lb.alb_lambda_smith_agent[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.certificate_manager.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_lambda_smith_agent[0].arn
  }

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

resource "aws_lb_listener" "listener_lambda_smith_agent_80" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  load_balancer_arn = aws_lb.alb_lambda_smith_agent[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_lambda_smith_agent[0].arn
  }

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

resource "aws_lb_target_group" "tg_lambda_smith_agent" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  name     = "${var.namespace}-smith-agent"
  vpc_id   = data.aws_vpc.vpc.id
  target_type = "lambda"

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

resource "aws_lambda_permission" "with_lb" {
  count         = local.enabled_lambda_smith_agent ? 1 : 0
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_smith_agent[0].function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.tg_lambda_smith_agent[0].arn
}

resource "aws_lb_target_group_attachment" "lambda_attachment" {
  count            = local.enabled_lambda_smith_agent ? 1 : 0
  target_group_arn = aws_lb_target_group.tg_lambda_smith_agent[0].arn
  target_id        = aws_lambda_function.lambda_smith_agent[0].arn
  depends_on       = [aws_lambda_permission.with_lb[0]]
}

resource "aws_lambda_function" "lambda_smith_agent" {
  count         = local.enabled_lambda_smith_agent ? 1 : 0
  filename      = "${path.module}/lambda_files/acqprocessing-pycrypto-lambda-noarch.zip"
  function_name = "${var.namespace}-smith-agent"
  description   = "Faz as crypto e decrypto do ambiente ${var.namespace}"
  role          = aws_iam_role.lambda_smith_agent[0].arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/lambda_files/acqprocessing-pycrypto-lambda-noarch.zip")
  architectures = ["arm64"]
  memory_size  = 512
  timeout      = 5

  environment {
    variables = {
      HOST_SECRET   = "jae-host-${local.adjusted_env_name}"
      SERVER_ENV    = "${local.adjusted_env_name}"
      PYCRYPTO_DB   = "smith-agent-db-${local.adjusted_env_name}"
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnets_ids
    security_group_ids = [aws_security_group.lambda_smith_agent[0].id]
  }

  layers = [
    aws_lambda_layer_version.acqprocessing_pycrypto[0].arn,
    aws_lambda_layer_version.cryptography[0].arn,
    aws_lambda_layer_version.requests[0].arn,
    aws_lambda_layer_version.urllib3[0].arn
  ]

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

resource "aws_lambda_layer_version" "acqprocessing_pycrypto" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  filename            = "${path.module}/lambda_files/acqprocessing-pycrypto-layer-noarch.zip"
  layer_name          = "acqprocessing-pycrypto"
  compatible_runtimes = ["python3.9"]
  compatible_architectures = ["x86_64", "arm64"]
}

resource "aws_lambda_layer_version" "cryptography" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  filename            = "${path.module}/lambda_files/cryptography-aarch64.zip"
  layer_name          = "cryptography"
  compatible_runtimes = ["python3.9"]
  compatible_architectures = ["arm64"]
}

resource "aws_lambda_layer_version" "requests" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  filename            = "${path.module}/lambda_files/requests.zip"
  layer_name          = "requests"
  compatible_runtimes = ["python3.9"]
  compatible_architectures = ["arm64"]
}

resource "aws_lambda_layer_version" "urllib3" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  filename            = "${path.module}/lambda_files/urllib3.zip"
  layer_name          = "urllib3"
  compatible_runtimes = ["python3.9"]
  compatible_architectures = ["arm64"]
}

#####################################################################
# CRIA O SECURITY GROUP DO LAMBDA SMITH AGENT
#####################################################################
resource "aws_security_group" "lambda_smith_agent" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  name = "${var.namespace}-smith-agent"
  description = "Security Group for Lambda function"
  vpc_id = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite trafego indo para qualquer lugar"
  }

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

resource "aws_security_group_rule" "https_own_vpc_lambda_443" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_smith_agent[0].id
  cidr_blocks       = ["${data.aws_vpc.vpc.cidr_block}"]
  description       = "Permite entrada 443 da propria vpc"
}

resource "aws_security_group_rule" "https_own_vpc_lambda_80" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_smith_agent[0].id
  cidr_blocks       = ["${data.aws_vpc.vpc.cidr_block}"]
  description       = "Permite entrada 80 da propria vpc"
}

resource "aws_security_group_rule" "https_vpn_lambda" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_smith_agent[0].id
  cidr_blocks       = ["10.255.128.0/19"]
  description       = "Permite entrada 443 da VPN"
}

resource "aws_route53_record" "alb_dns" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.domain != "" ? "smith-agent.${var.domain}" : "smith-agent"
  type    = "A"

  alias {
    name                   = aws_lb.alb_lambda_smith_agent[0].dns_name
    zone_id                = aws_lb.alb_lambda_smith_agent[0].zone_id
    evaluate_target_health = false
  }
}

#####################################################################
# CRIA A ROLE DO LAMBDA SMITH AGENT
#####################################################################
resource "aws_iam_role" "lambda_smith_agent" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  name = "${var.namespace}-role-smith-agent"
  assume_role_policy = data.aws_iam_policy_document.lambda_smith_agent[0].json

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

data "aws_iam_policy_document" "lambda_smith_agent" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_smith_agent_basic" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  name        = "${var.namespace}_AWSLambdaBasicExecutionRole"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:us-east-2:266241576141:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:us-east-2:266241576141:log-group:/aws/lambda/smith-agent:*"
      ]
    }
  ]
}
EOF

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

resource "aws_iam_policy" "lambda_smith_agent_crypto" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  name        = "${var.namespace}-smith-agent-crypto"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Statement1",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:UpdateSecretVersionStage",
        "secretsmanager:UpdateSecret",
        "dynamodb:Query",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

  tags = {
    Service   = "${var.namespace}-smith-agent"
    Component = "common"
  }
}

resource "aws_iam_role_policy_attachment" "attach_policy_one" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  role       = aws_iam_role.lambda_smith_agent[0].name
  policy_arn = aws_iam_policy.lambda_smith_agent_basic[0].arn
}

resource "aws_iam_role_policy_attachment" "attach_policy_two" {
  count = local.enabled_lambda_smith_agent ? 1 : 0
  role       = aws_iam_role.lambda_smith_agent[0].name
  policy_arn = aws_iam_policy.lambda_smith_agent_crypto[0].arn
}



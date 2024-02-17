#####################################################################
# CRIA O RDS PARA O AMBIENTE NÃO PRODUTIVO
#####################################################################
locals {
  enabled_rds_common = try(var.environmentConfig["rds_common"], false)
  rds_username       = "administrator"
}

resource "aws_db_subnet_group" "rds_common" {
  count      = local.enabled_rds_common ? 1 : 0
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.restricted_subnets_ids

  tags = {
    Service   = "${var.namespace}_rds_common"
    Component = "common"
  }
}

resource "aws_db_parameter_group" "rds_common" {
  count  = local.enabled_rds_common ? 1 : 0
  name   = "${var.environment}-mysql8-0"
  family = "mysql8.0"

  parameter {
    name         = "log_bin_trust_function_creators"
    value        = 1
    apply_method = "immediate"
  }

  parameter {
    name         = "performance_schema"
    value        = 1
    apply_method = "pending-reboot"
  }

  tags = {
    Service   = "${var.namespace}_rds_common"
    Component = "common"
  }
}

resource "aws_db_instance" "rds_common" {
  count                      = local.enabled_rds_common ? 1 : 0
  allocated_storage          = 100
  apply_immediately          = true
  auto_minor_version_upgrade = true
  backup_retention_period    = 0
  db_subnet_group_name       = aws_db_subnet_group.rds_common[0].name
  engine                     = "mysql"
  engine_version             = "8.0.32"
  identifier                 = "${var.namespace}-rds-common"
  instance_class             = "db.t4g.medium"
  max_allocated_storage      = 1000
  multi_az                   = false
  parameter_group_name       = aws_db_parameter_group.rds_common[0].name
  skip_final_snapshot        = true
  storage_encrypted          = true
  storage_type               = "gp2"
  username                   = local.rds_username
  password                   = random_password.password[0].result
  vpc_security_group_ids     = [aws_security_group.rds[0].id]

  tags = {
    Service   = "${var.namespace}_rds_common"
    Component = "common"
  }
}

#####################################################################
# RATACIONAR SENHA RDS
#####################################################################
resource "aws_secretsmanager_secret" "rds_password" {
  count                   = local.enabled_rds_common ? 1 : 0
  name                    = "rds-password"
  recovery_window_in_days = 0

  tags = {
    Service   = "${var.namespace}_rds_password"
    Component = "common"
  }
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  count         = local.enabled_rds_common ? 1 : 0
  secret_id     = aws_secretsmanager_secret.rds_password[0].id
  secret_string = random_password.password[0].result
}

resource "random_password" "password" {
  count            = local.enabled_rds_common ? 1 : 0
  length           = 16
  special          = true
  override_special = "/@"
}

resource "aws_lambda_function" "rds_rotation_passwd" {
  count         = local.enabled_rds_common ? 1 : 0
  filename      = "${path.module}/rds_rotation_passwd.zip"
  function_name = "rds_rotation_passwd_function"
  role          = aws_iam_role.rds_passwd[0].arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  environment {
    variables = {
      IDENTIFIER = var.namespace
      ACCOUNTID  = data.aws_caller_identity.current.account_id
      REGION     = var.region
    }
  }

  tags = {
    Service   = "${var.namespace}_rds_password"
    Component = "common"
  }
}

resource "aws_lambda_permission" "rds_lambda_permission_allow_secretsmanager" {
  count         = local.enabled_rds_common ? 1 : 0
  function_name = aws_lambda_function.rds_rotation_passwd[0].function_name
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}

resource "aws_lambda_permission" "rds_password" {
  count         = local.enabled_rds_common ? 1 : 0
  statement_id  = "AllowExecutionFromRDS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_rotation_passwd[0].function_name
  principal     = "rds.amazonaws.com"
  source_arn    = aws_db_instance.rds_common[0].arn
}

#####################################################################
# METRICAS RDS ROTATION PASSWD
#####################################################################
resource "aws_secretsmanager_secret_rotation" "rds_password" {
  count               = local.enabled_rds_common ? 1 : 0
  secret_id           = aws_secretsmanager_secret.rds_password[0].id
  rotation_lambda_arn = aws_lambda_function.rds_rotation_passwd[0].arn

  rotation_rules {
    automatically_after_days = 7
  }

}

#####################################################################
# IAM POLICY PASSWORD RDS ROTATION
#####################################################################
resource "aws_iam_role" "rds_passwd" {
  count = local.enabled_rds_common ? 1 : 0
  name  = "role_rds_password_rotation"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Service   = "${var.namespace}_rds_password"
    Component = "common"
  }
}

resource "aws_iam_policy" "policy_rds_password_rotation" {
  count  = local.enabled_rds_common ? 1 : 0
  name   = "policy_rds_password_rds_rotation"
  policy = data.aws_iam_policy_document.iam_policy_rds_passwd[0].json

  tags = {
    Service   = "${var.namespace}_rds_password"
    Component = "common"
  }
}

resource "aws_iam_role_policy_attachment" "attachment_rds_passwd" {
  count      = local.enabled_rds_common ? 1 : 0
  policy_arn = aws_iam_policy.policy_rds_password_rotation[0].arn
  role       = aws_iam_role.rds_passwd[0].name
}

data "aws_iam_policy_document" "iam_policy_rds_passwd" {
  count      = local.enabled_rds_common ? 1 : 0
  statement {
    actions = [
      "rds-db:rotate-password",
      "lambda:InvokeFunction",
    ]

    resources = [
      aws_db_instance.rds_common[0].arn,
      aws_secretsmanager_secret.rds_password[0].arn,
      aws_lambda_function.rds_rotation_passwd[0].arn,
    ]
  }
}

#####################################################################
# CRIACAO SECURITY GROUP DO PRISMA
#####################################################################
resource "aws_security_group" "prisma-vpn" {
  count      = local.enabled_rds_common ? 1 : 0
  name        = "prisma-vpn-${var.namespace}"
  description = "Controla trafego da VPN prisma"
  vpc_id      = var.vpc

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.255.128.0/19"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite trafego indo para qualquer lugar"
  }

  tags = {
    Service   = "security_group_prisma"
    Component = "common"
  }
}

#####################################################################
# CRIACAO SECURITY GROUP DO RDS
#####################################################################
resource "aws_security_group" "rds" {
  count      = local.enabled_rds_common ? 1 : 0
  name        = "rds-${var.namespace}-sg"
  description = "Controla trafego para o RDS"
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite trafego indo para qualquer lugar"
  }

  tags = {
    Service   = "security_group_alb"
    Component = "common"
  }
}

resource "aws_security_group_rule" "rds" {
  count      = local.enabled_rds_common ? 1 : 0
  security_group_id = aws_security_group.rds[0].id

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.prisma-vpn[0].id
  description              = "Permite acesso para o rds"
}
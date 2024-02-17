#####################################################################
# CRIA o SQS PARA AS TRANSAÇÔES DO GATEWAY
#####################################################################

locals {
  enabled_transaction_sqs = try(var.environmentConfig["transaction_sqs"], false)
  adjusted_env_no_gw = replace(var.namespace, "gw-", "")
}

resource "aws_sqs_queue" "transaction_sqs" {
  count                      = local.enabled_transaction_sqs ? 1 : 0
  name                       = "${var.namespace}-transaction"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 60
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.transaction_sqs_dlq[0].arn
    maxReceiveCount     = 20
  })

  tags = {
    Service   = "transaction_sqs"
    Component = "common"
  }
}

/*resource "aws_sqs_queue_policy" "transaction_sqs" {
  queue_url = aws_sqs_queue.transaction_sqs[0].id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        "Action": [
          "SQS:SendMessage",
          "SQS:DeleteMessage",
          "SQS:ReceiveMessage"
        ],
        Resource  = aws_sqs_queue.transaction_sqs[0].arn
      }
    ]
  })
}*/

resource "aws_sqs_queue" "transaction_sqs_dlq" {
  count = local.enabled_transaction_sqs ? 1 : 0
  name  = "${var.namespace}-transaction-dlq"
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = ["arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.namespace}-transaction"]
  })

  tags = {
    Service   = "transaction_sqs"
    Component = "common"
  }
}

resource "aws_iam_policy" "transaction_sqs_publish" {
  count       = local.enabled_transaction_sqs ? 1 : 0
  name        = "${var.namespace}-transaction_sqs-publish-policy"
  path        = "/"
  description = "Política que permite enviar menssagem para o SQS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "sqs:SendMessage",
        "sqs:GetQueueUrl"
      ],
      "Resource" : ["${aws_sqs_queue.transaction_sqs[0].arn}"]
    }]
  })

  tags = {
    Service   = "transaction_sqs"
    Component = "common"
  }
}

resource "aws_iam_policy" "transaction_sqs_consume" {
  count       = local.enabled_transaction_sqs ? 1 : 0
  name        = "${var.namespace}-transaction_sqs-consume-policy"
  path        = "/"
  description = "Política que permite enviar menssagem para o SQS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "sqs:SendMessage",
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage",
        "sqs:GetQueueUrl"
      ],
      "Resource" : [
        "${aws_sqs_queue.transaction_sqs[0].arn}",
        "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.id}:${local.adjusted_env_no_gw}-transaction"
      ]
    }]
  })

  tags = {
    Service   = "transaction_sqs"
    Component = "common"
  }
}
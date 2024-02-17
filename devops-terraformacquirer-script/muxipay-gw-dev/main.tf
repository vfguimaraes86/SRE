#################################################################################################
######################### CONFIGURAR O BUCKET PARA GUARDAS AS ALTERAÇÔES ########################
#################################################################################################

terraform {
  required_version = ">= 1.2.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }
  }

  backend "s3" {
    bucket         = "266241576141-us-east-2-terraform-remote-backend-state"
    profile        = "muxipay-dev"
    key            = "muxipay-gw-dev/terraform.tfstate" #### TODO #### nome da pasta no buket ({NAMESPACE}/terraform.tfstate)
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-remote-backend-state"
  }
}

#################################################################################################
############################ CONFIGURAR ESSAS VARIAVEIS POR AMBIENTE ############################
#################################################################################################

module "enviroment" {
  source                          = "../modules/enviroment"
  environment                     = "muxipay-dev"          #### TODO #### nome da conta
  namespace                       = "muxipay-gw-dev"       #### TODO #### nome do namespace
  #force_destroy                   = true                   #### TODO #### se permite deletar secret e bucket instantaneamente (default false)
  domain                          = ""                     #### TODO #### dominio $http://{sub_domain}${"." + domain}.${route53.somain}
  #eks_cluster_name                = "muxipay-dev"          #### TODO #### nome do cluster EKS (opicional)
  environmentConfig = {
    #cloudwatch                       = true #### TODO ####
    mail_service                     = true #### TODO ####
    resourcegroups                   = true #### TODO ####
    #route53_kibana                   = true #### TODO ####
    tokens_secretmanager             = true #### TODO ####
    transaction_sqs                  = true #### TODO ####
    nlb_software_express             = true #### TODO #### Cria nlb para a Software Express
    application_env_secretmanager    = true #### TODO ####
    #elasticsearch                    = true #### TODO ####
    nlb                              = true
    #elasticache                      = true #### TODO #### Cria um elastiCache por namespace
  }

  # Serviços ainda não provisionados
  #sqs

  /* ################## Valores por aplicação ##################
      create_application_env_secretmanager  = true #### TODO ####
      read_tokens_secretmanager  = true #### TODO ####
      only_policy_for_secretsmanager       = true TODO ####
  */
  api_components = [
    {
      name       = "muxipay-gw-global-api"
      sub_domain = "gw-global"

      publish_transaction_sqs = true
      create_nlb              = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-gw-global-ecommerce-api"
      sub_domain = "gw-global-ecommerce"

      publish_transaction_sqs = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-gw-postilion-ecommerce-api"
      sub_domain = "gw-postilion-ecommerce"

      publish_transaction_sqs = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-gw-postilion-api"
      sub_domain = "gw-postilion"

      publish_transaction_sqs = true
      create_nlb              = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-svc-initialization-api"
      sub_domain = "svc-initialization"

      publish_transaction_sqs = true
      create_nlb              = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-worker-transaction-api"
      sub_domain = "worker-transaction"

      consume_transaction_sqs = true
      send_mail               = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-gwu-trx-api"
      sub_domain = "gwu-trx"

      publish_transaction_sqs = true
      create_nlb              = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-vpc-cybersource-batch"
      sub_domain = "vpc-cybersource-batch"

      publish_transaction_sqs = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-gw-switcher-api"
      sub_domain = "gw-switcher"

      publish_transaction_sqs = true
      create_nlb              = true
      read_tokens_secretmanager = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-vpc-postilion-batch"
      sub_domain = "vpc-postilion-batch"
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      create_apigateway_policy             = true
      #publish_cloudwatch                   = true
      only_policy_for_secretsmanager       = true
    },
    {
      name       = "muxipay-vpc-edi-batch"
      sub_domain = "vpc-edi-batch"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      #publish_cloudwatch                   = true
      only_policy_for_secretsmanager       = true
    }
  ]

  pos_components = [
    {
      name       = "muxipay-gw-caradhras-api"
      sub_domain = "gw-caradhras"

      #publish_transaction_sqs = true
      create_nlb              = true
      read_tokens_secretmanager = true
      publish_transaction_sqs = true
      #publish_cloudwatch     = true
      only_policy_for_secretsmanager       = true
    }
  ]
}
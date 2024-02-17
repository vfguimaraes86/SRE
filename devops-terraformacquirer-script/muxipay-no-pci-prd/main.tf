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
    key            = "muxipay-dev/terraform.tfstate" #### TODO #### nome da pasta no buket ({NAMESPACE}/terraform.tfstate)
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
  environment                     = "muxipay-no-pci-prd"   #### TODO #### nome da conta
  namespace                       = "muxipay-no-pci"       #### TODO #### nome do namespace
  #eks_use_namespace                = true                  #### TODO #### permite setar o nome do namespace para nome do eks (default false)
  #force_destroy                    = true                  #### TODO #### se permite deletar secret e bucket instantaneamente (default false)
  domain                          = ""                     #### TODO #### dominio $http://{sub_domain}${"." + domain}.${route53.somain}
  #eks_cluster_name                = "muxipay-no-pci-prd"   #### TODO #### nome do cluster EKS (opicional)
  environmentConfig = {
    application_data_secretmanager = true #### TODO ####
    cloudwatch                     = true #### TODO ####
    export_bucket                  = true #### TODO ####
    file_bucket                    = true #### TODO ####
    mail_bucket                    = true #### TODO ####
    mail_service                   = true #### TODO ####
    resourcegroups                 = true #### TODO ####
    route53_kibana                 = true #### TODO ####
    elasticsearch                  = true #### TODO ####
    tokens_secretmanager           = true #### TODO ####
    sftp                           = true #### TODO ####
    application_bucket             = true #### TODO ####
    sns                            = true #### TODO ####
    #application_env_secretmanager  = true #### TODO ####
    #rds_common                     = true #### TODO ####
    #elasticache                    = true #### TODO #### Cria um elastiCache por namespace
  }

  portal_components = [
    {
      name       = "muxipay-muxiapi-fe"
      sub_domain = "muxiapi"
    },
    {
      name       = "muxipay-portal-fe"
      sub_domain = "www"
    }
  ]

  /* ################## Valores por aplicação ##################

      create_application_bucket             = true #### TODO ####
      create_application_env_secretmanager  = true #### TODO ####
      read_application_data_secretmanager   = true #### TODO ####
      read_export_bucket                    = true #### TODO ####
      read_file_bucket                      = true #### TODO ####
      read_mail_bucket                      = true #### TODO ####
      read_tokens_secretmanager             = true #### TODO ####
      send_mail                             = true #### TODO ####
      write_application_data_secretmanager  = true #### TODO ####
      write_export_bucket                   = true #### TODO ####
      write_file_bucket                     = true #### TODO ####
      write_mail_bucket                     = true #### TODO ####
      write_tokens_secretmanager            = true #### TODO ####
      publish_sns                           = true #### TODO ####
      manage_sns                            = true #### TODO ####
  */

  api_components = [
    {
      name       = "muxipay-accounting-api"
      sub_domain = "accounting"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-acq-onboarding-pch-batch"
      sub_domain = "acq-onboarding-pch"

      create_application_env_secretmanager = true
      read_application_data_secretmanager  = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-authorizer-api"
      sub_domain = "authorizer"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      write_application_data_secretmanager = true
      publish_sns                          = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-cardbrand-api"
      sub_domain = "cardbrand"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-cerc-batch"
      sub_domain = "cerc"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      write_file_bucket                    = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-chargeback-api"
      sub_domain = "chargeback"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      write_export_bucket                  = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-cip-batch"
      sub_domain = "cip"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      write_file_bucket                    = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-crawler-global-batch"
      sub_domain = "crawler-global"

      create_application_env_secretmanager = true
      read_application_data_secretmanager  = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-filerepository-api"
      sub_domain = "filerepository"

      create_application_env_secretmanager = true
      read_export_bucket                   = true
      read_file_bucket                     = true
      read_tokens_secretmanager            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-ids-api"
      sub_domain = "ids"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      write_mail_bucket                    = true
      write_tokens_secretmanager           = true
      manage_sns                           = true
      publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-key-api"
      sub_domain = "key"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-merchant-api"
      sub_domain = "merchant"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      write_export_bucket                  = true
      publish_sns                          = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-muxiapi-batch"
      sub_domain = "bo-muxiapi"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      write_file_bucket                    = true
      read_application_data_secretmanager  = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-postilion-edi-batch"
      sub_domain = "postilion-edi"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-regulatory-api"
      sub_domain = "regulatory"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-scheduler-api"
      sub_domain = "scheduler"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
    },
    {
      name       = "muxipay-serviceorder-api"
      sub_domain = "serviceorder"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      send_mail                            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-terminal-api"
      sub_domain = "terminal"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      write_export_bucket                  = true
      publish_sns                          = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-transaction-api"
      sub_domain = "transaction"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      write_export_bucket                  = true
      publish_sns                          = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-transaction-integrator-batch"
      sub_domain = "transaction-integrator"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-wallet-api"
      sub_domain = "wallet"

      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      #publish_cloudwatch                   = true
    },
    {
      name       = "muxipay-settlement-api"
      sub_domain = "settlement"

      create_application_bucket            = true
      create_application_env_secretmanager = true
      read_tokens_secretmanager            = true
      write_export_bucket                  = true
      publish_sns                          = true
      #publish_cloudwatch                   = true
    },
  ]
  
  pos_components = [
    {
      name       = "muxipay-gw-caradhras-api"
      sub_domain = "gw-caradhras-api"

      #publish_transaction_sqs = true
      create_nlb              = true
      read_tokens_secretmanager = true
      publish_transaction_sqs = true
      #publish_cloudwatch     = true
    }
  ]
}
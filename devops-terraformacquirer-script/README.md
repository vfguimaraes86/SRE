# terraformAcquirer

# muxipay-terraform

###### *Infra as code for muxipay.*

### Requirements
------------
- terraform
- AWS account

### Dependencies
------------

- EKS created through the service catalog
- Infra helm script executed
- Structural helm script executed (NLB, ingress...)

### Features

------------

- Create and configure the AWS according to the needs of each environment

### How to usage

------------

```
terraform init -backend-config="key={{environment name}}/terraform.tfstate"  -backend-config="profile={environment name}"
terraform apply -var-file="env/{{environment name}}.tfvars"
```

### Example

------------

```
terraform init -backend-config="key=muxipay-dev/terraform.tfstate"  -backend-config="profile=muxipay-dev"
terraform apply -var-file="env/muxipay-dev.tfvars"
```

###### Minimal configuration example of your `muxipay-dev.tfvars` file:

```        
  region      = "us-east-2"
  environment = "muxipay-dev"
  namespace = "muxipay-sqa"
  hosted_zone_id = "Z0389058DR6U7K9DF6T0"
  environmentConfig = {
  }
  components = [
    {
        name                                    = "muxipay-ids-api"
        sub_domain                              = "ids"
    }
]
```


### Properties configuration

------------
###### - Todas as configurações do `environmentConfig` tem o valor default como `true`
###### - Todas as configurações do `components` tem o valor default como `false` apenas é criado o ServiceAccountRole
```
  region        = "us-east-2" # região que hospedará os serviços
  environment   = "muxipay-dev" # nome da conta AWS que será usada
  namespace     = "muxipay-dev" # nome do ambiente que será criado
  hosted_zone_id = "Z0389058DR6U7K9DF6T0" # id do route53 que será usado
  force_destroy = false (opcional; default false) #Quando true, deleta o bucket e o secretmanager na hora 
  environmentConfig = { # Todos tem o default como `true
    # application_bucket              = false # Cria um bucket default por aplicação
    # application_env_secretmanager   = false # Cria um secretsmanager de properties por aplicação
    # application_data_secretmanager  = false # Permite a criação de secrets pela aplicação, para guardar dados do cliente informados no portal
    # cloudwatch                      = false # Configura o cloudwatch para as aplicações
    # export_bucket                   = false # Cria apenas um bucket para as aplicações guardarem os relatórios exportados
    # file_bucket                     = false # Cria apenas um backet para todas as aplicações guardarem arquivos trocados com terceiros (CIP,CERC...)
    # mail_bucket                     = false # Cria um bucket publico para guardar as imagens do layout de email enviados pelo muxipay
    # mail_service                    = false # habilita o serviço SES
    # resourcegroups                  = false # Cria o resource group
    # route53_kibana                  = false # Cria o subdominio para acessar o kibana
    # tokens_secretmanager            = false # Cria um bucket por aplicação para guardar os tokens de integração com outras aplicações do muxipay
    # sftp                            = false # Cria um servidor de SFTP para teste
    # sns                             = false # Habilita o serviço de SNS (EBUS)
    # transaction_sqs                 = false # cria o sqs para as transações
  }

  components = [
    {
        name                                    = "muxipay-ids-api" # nome da aplicação (usar o mesmo nome do projeto no git) 
        sub_domain                              = "ids" # nome que será criado o subdomínio para chegar na aplicação (ex: https://ids.muxipay.dev.dock.tech)

        # create_application_bucket             = false # Cria o bucket com permissão de leitura e escrita no bucket default
        # create_application_env_secretmanager  = false # Cria o scretmanager com permissão de leitura dos properties
        # send_mail                            = false # Habilita a permissão para envio de email para esta aplicação
        
        # read_application_data_secretmanager   = false # Habilita a permissão de leitura de TODOS os dados guardados por TODAS as aplicações
        # write_application_data_secretmanager  = false # Habilita a permissão para guardar os dados no secretsmanager desta aplicação

        # read_export_bucket                    = false # Habilita permissão de escrita de arquivos no bucket de exportação 
        # write_export_bucket                   = false # Habilita permissão de leitura de arquivos no bucket de exportação

        # read_file_bucket                      = false # Habilita a permissão de escrita de arquivos
        # write_file_bucket                     = false # Habilita a permissão de apenas leitura de arquivos

        # read_mail_bucket                      = false # Habilita a permissão de ler as imagens do bucket
        # write_mail_bucket                     = false # Habilita a permissão de guardar as imagens no bucket

        # read_tokens_secretmanager             = false # Habilita a permissão para ler os secrets de tokens desta aplicação
        # write_tokens_secretmanager            = false # Habilita a permissão para guardar os secrets de tokens de TODAS as aplicações

        # publish_sns                           = false # Habilita a permissão para publicar no sns
        # manage_sns                            = false # Habilita a permissão para gerenciar topicos no SNS
      
        # publish_transaction_sqs               = false # Habilita a permissão para publicar no sqs
        # consume_transaction_sqs               = false # Habilita a permissão para consumir mensagens no sqs
    },
    {
        name                                    = "muxipay-merchant-api"
        sub_domain                              = "merchant"
    }
]
```

#####################################################################
# CARREGA PROVIDER US-EAST-1
#####################################################################

provider "aws" {
  alias                    = "n-virginia"
  region                   = "us-east-1"
  profile                  = var.environment
  shared_credentials_files = ["~/.aws/credentials"]
}
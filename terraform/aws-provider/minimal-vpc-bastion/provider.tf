#################################111###########################
### Get some customs informations before the tag generation ###
####################################111########################

data "external" "get_tag_user_name" {
  program = ["sh", "${path.module}/scripts/get_tag_user_name.sh"]
  query   = { aws_profile = var.aws_profile }
}
data "external" "get_tag_version" {
  program = ["sh", "${path.module}/scripts/get_tag_version.sh"]
}


##################################################################
###                Setup default Tags                          ###
### Check Tag best practices :                                 ###
# https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html #
##################################################################

locals {
  default_tags = {
    Project      = var.project_name
    Env          = var.environment
    OwnerXX      = "TF-Providers" # XX -> Hack to bypass company tag policies restriction (testing purpose)
    DeployerName = data.external.get_tag_user_name.result.username
    Version      = data.external.get_tag_version.result.version
  }
}

#############################################################
###               Setup AWS Provider                      ###
#############################################################

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = local.default_tags
  }
}

# /!\ ALL the following has not been tested !

# Need to have a S3 bucket to store the state on AWS : 
# cd backend && terraform init && terraform apply -auto-approve

# Then you can use this snippet :
# terraform {
#   backend "s3" {

#     bucket  = "terraform-stuff"
#     key     = "MY_PROJECT/terraform.tfstate"
#     region  = var.region
#     encrypt = true
#   }
# }

# /!\ Variables are not allowed in backend section.
# You can try this : https://github.com/hashicorp/terraform/issues/13022#issuecomment-294262392

# You can also configure it like the following (it will replace the value in backend :
# terraform init -reconfigure -backend-config="key=MY_PROJECT/terraform.tfstate"

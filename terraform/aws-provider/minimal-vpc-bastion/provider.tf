# Check Tag best practice https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html (Not apply here)
# XX -> Bypass tag policies restriction for testing
locals {
  default_tags = {
    Project = var.project_name
    Env     = var.environment
    OwnerXX = "TF-Providers"
  }
}

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

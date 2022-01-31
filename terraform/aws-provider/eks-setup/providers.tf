
terraform {
  required_version = ">= 0.12"
}

# Search here : https://registry.terraform.io for more infos

# Provide allow use of randomness
# Resources : random_* *=(id,integer,password,pet,shuffle,string,uuid)
provider "random" {}

# Provide read/write on file
# Resources    : local_file
# Data Sources : local_file
provider "local" {}

# Provide null_sources, null_data-sources
provider "null" {}

# Deprecated
# Resources    : template_dir
# Data Sources : template_cloudinit_config, template_file
provider "template" {}

resource "random_string" "suffix" {
  length  = 5
  special = false
}

locals {
  cluster_name = "${replace(basename(path.cwd), "_", "-")}-${random_string.suffix.result}"
  default_tags = {
    Project = "test-eks"
    OwnerXX = "TF-Providers"
  }
}

#############################################################
###               Setup AWS Provider                      ###
#############################################################

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "region" {
  default     = "eu-west-1"
  description = "AWS region"
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = local.default_tags
  }
}

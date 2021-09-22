
terraform {
  required_version = ">= 0.12"
}

# Search here : https://registry.terraform.io for more infos

# Provide allow use of randomness
# Resources : random_* *=(id,integer,password,pet,shuffle,string,uuid)
provider "random" {
  version = "~> 2.1"
}

# Provide read/write on file
# Resources    : local_file
# Data Sources : local_file
provider "local" {
  version = "~> 1.2"
}

# Provide null_sources, null_data-sources
provider "null" {
  version = "~> 2.1"
}

# Deprecated
# Resources    : template_dir
# Data Sources : template_cloudinit_config, template_file
provider "template" {
  version = "~> 2.1"
}

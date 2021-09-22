/* Get the list of usable availability zones */
data "aws_availability_zones" "available" {
  state = "available"
}

module "networking" {
  source               = "./modules/networking"
  region               = var.region
  global_name          = var.global_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = data.aws_availability_zones.available.names
}

module "bastion" {
  source           = "./modules/bastion"
  global_name      = var.global_name
  environment      = var.environment
  depends_on       = [module.networking]
  vpc_id           = module.networking.vpc_id
  public_subnet_id = one(module.networking.public_subnets_id)
  bastion_key_name = "bastion-${var.global_name}-key-pair"
}

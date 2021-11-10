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
  public_subnet_id = element(module.networking.public_subnets_ids, 0)
  bastion_key_name = "bastion-${var.global_name}-key-pair"
}

module "database" {
  source      = "./modules/database"
  global_name = var.global_name
  environment = var.environment

  database_name = "${lower(var.global_name)}_${lower(var.environment)}"

  vpc_id              = module.networking.vpc_id
  private_subnets_ids = module.networking.private_subnets_ids
  depends_on          = [module.networking, module.bastion]
}

module "ecs_cluster" {
  source              = "./modules/ecs_cluster"
  global_name         = var.global_name
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  private_subnets_ids = module.networking.private_subnets_ids
  public_subnets_ids  = module.networking.public_subnets_ids
  depends_on          = [module.networking]
}

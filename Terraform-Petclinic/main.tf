module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
}

module "ecr" {
  source      = "./modules/ecr"
  environment = var.environment
}

module "eks" {
  source      = "./modules/eks"
  environment = var.environment
  subnet_ids  = module.vpc.private_subnet_ids
}

module "rds" {
  source             = "./modules/rds"
  environment        = var.environment
  db_password        = var.db_password
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "secretsmanager" {
  source      = "./modules/secretsmanager"
  environment = var.environment
  db_password = var.db_password
}
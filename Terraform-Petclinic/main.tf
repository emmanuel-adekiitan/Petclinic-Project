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
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  # Pass legacy subnet ID to retain active RDS ENI during migration
  legacy_subnet_ids  = ["subnet-0e50f88afc7f206d1"]
}

module "secretsmanager" {
  source      = "./modules/secretsmanager"
  environment = var.environment
  db_password = var.db_password
}
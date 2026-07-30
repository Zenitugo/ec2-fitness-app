#################### VPC Modules ####################
module "vpc" {
  source                              = "../modules/vpc"
  vpc_cidr_block                      = var.vpc_cidr_block
  environment_name                    = var.environment_name
}



module "sg" {
  source                              = "../modules/sg"
  vpc_id                              = module.vpc.vpc_id
  environment_name                    = var.environment_name
}

module "ecr" {
  source                              = "../modules/ecr"
  environment_name                    = var.environment_name
}

module "iam" {
  source                              = "../modules/iam"
  Instance_profile_name               = var.Instance_profile_name
  role_name                           = var.role_name
  custom_policy_name                  = var.custom_policy_name
  bucket_arn                          = module.s3.bucket_arn
  frontend_bucket_arn                 = module.s3.frontend_bucket_arn
  frontend_bucket_name                = module.s3.frontend_bucket_name
  db_secret_arn                       = module.rds.db_secret_arn
}


module "s3" {
  source                              = "../modules/s3"
  bucket_prefix                       = var.bucket_prefix
}

# module "cloudfront" {
#   source                              = "../modules/cloudfront"
#   cloudfront_oac_name                 = var.cloudfront_oac_name
#   bucket_regional_domain_name         = module.s3.bucket_regional_domain_name
# }

module "rds" {
  source                              = "../modules/rds"
  project_name                        = var.project_name
  private_subnet_1_id                 = module.vpc.private_subnet_1_id
  private_subnet_2_id                 = module.vpc.private_subnet_2_id
  db_username                         = var.db_username
  database_sg                         = module.sg.database_sg
}


module "alb" {
  source                              = "../modules/alb"
  alb_sg                              = module.sg.alb_sg
  public_subnet_1_id                  = module.vpc.private_subnet_1_id
  public_subnet_2_id                  = module.vpc.public_subnet_2_id
  environment_name                    = var.environment_name
  vpc_id                              = module.vpc.vpc_id
}

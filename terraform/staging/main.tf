#################### VPC Modules ####################
module "vpc" {
  source                              = "../modules/vpc"
  vpc_cidr_block                      = var.vpc_cidr_block
  environment_name                    = var.environment_name
}

module "ec2_template" {
  source                              = "../modules/ec2-template"
  image_id                            = var.image_id
  instance_type                       = var.instance_type
  ec2_sg                              = module.sg.ec2_sg
  Instance_profile_name               = module.iam.Instance_profile_name 
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
}

module "s3" {
  source                              = "../modules/s3"
  bucket_prefix                       = var.bucket_prefix
  region                              = var.region
}

module "cloudfront" {
  source                              = "../modules/cloudfront"
  cloudfront_oac_name                 = var.cloudfront_oac_name
  bucket_regional_domain_name         = module.s3.bucket_regional_domain_name
}

module "rds" {
  source                              = "../modules/rds"
  project_name                        = var.project_name
  private_subnet_1_id                 = module.vpc.private_subnet_1_id
  private_subnet_2_id                 = module.vpc.private_subnet_2_id
  db_username                         = var.db_username
  database_sg                         = module.sg.database_sg
}


module "autoscaling" {
  source                              = "../modules/autoscaling"
  environment_name                    = var.environment_name
  fitness_app_launch_template_id      = module.ec2_template.fitness_app_launch_template_id
  private_subnet_1_id                 = module.vpc.private_subnet_1_id
  private_subnet_2_id                 = module.vpc.private_subnet_2_id
  ec2_sg                               = module.sg.ec2_sg
  min_size                            = var.min_size
  max_size                            = var.max_size
  desired_capacity                    = var.desired_capacity
}


module "cloudwatch" {
  source                              = "../modules/cloudwatch"
  environment_name                    = var.environment_name
  fitness_app_autoscaling_group_name  = module.autoscaling.fitness_app_autoscaling_group_name
  scale_up_policy_arn                 = module.autoscaling.scale_up_policy_arn
  scale_down_policy_arn               = module.autoscaling.scale_down_policy_arn
  autoscaling_group_name             = module.autoscaling.autoscaling_group_name
}

module "alb" {
  source                              = "../modules/alb"
  alb_sg                              = module.sg.alb_sg
  public_subnet_1_id                  = module.vpc.public_subnet_1_id
  public_subnet_2_id                  = module.vpc.public_subnet_2_id
  environment_name                    = var.environment_name
  vpc_id                              = module.vpc.vpc_id
}
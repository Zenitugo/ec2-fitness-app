#################### VPC Modules ####################
module "vpc" {
  source                              = "../modules/vpc"
  vpc_cidr_block                      = var.vpc_cidr_block
  environment_name                    = var.environment_name
}
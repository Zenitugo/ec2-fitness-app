#################### VPC Modules ####################
module "vpc" {
  source                              = "../modules/vpc"
  cidr_block                          = var.cidr_block
  environment_name                    = var.environment_name
}
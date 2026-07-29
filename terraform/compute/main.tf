module "ec2_template" {
  source                              = "../modules/ec2-template"
  image_id                            = var.image_id
  instance_type                       = var.instance_type
  backend_sg                          = data.terraform_remote_state.foundation.outputs.backend_sg
  instance_profile_name               = data.terraform_remote_state.foundation.outputs.instance_profile_name
  environment_name                    = var.environment_name
}



module "alb" {
  source                              = "../modules/alb"
  alb_sg                              = data.terraform_remote_state.foundation.outputs.alb_sg
  public_subnet_1_id                  = data.terraform_remote_state.foundation.outputs.public_subnet_1_id
  public_subnet_2_id                  = data.terraform_remote_state.foundation.outputs.public_subnet_2_id
  environment_name                    = var.environment_name
  vpc_id                              = data.terraform_remote_state.foundation.outputs.vpc_id
}



module "autoscaling" {
  source                              = "../modules/autoscaling"
  environment_name                    = var.environment_name
  launch_template                     = module.ec2_template.launch_template
  private_subnet_1_id                 = data.terraform_remote_state.foundation.outputs.private_subnet_1_id
  private_subnet_2_id                 = data.terraform_remote_state.foundation.outputs.private_subnet_2_id
  min_size                            = var.min_size
  max_size                            = var.max_size
  desired_capacity                    = var.desired_capacity
  target_group_arn                    = module.alb.target_group_arn
}


module "cloudwatch" {
  source                              = "../modules/cloudwatch"
  scale_up_policy_arn                 = module.autoscaling.scale_up_policy_arn
  scale_down_policy_arn               = module.autoscaling.scale_down_policy_arn
  autoscaling_group_name              = module.autoscaling.autoscaling_group_name
  cpu_high_threshold                  = var.cpu_high_threshold
  cpu_low_threshold                   = var.cpu_low_threshold
}

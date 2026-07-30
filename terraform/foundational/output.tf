#################### Export ECR Repository ID ####################

output "backend_repository_url" {
    value = module.ecr.backend_repository_url
}

###################### Export the Bucket Name holding the Frontend Assets ##################
output "frontend_bucket_name" {
  value = module.s3.frontend_bucket_name
}


##############   Export the RDS ENdpoint #########################
output "db_endpoint" {
  value = module.rds.db_endpoint
}


################ Export Secret ARN ###########################
output "db_secret_arn" {
  value = module.rds.db_secret_arn
  sensitive = true
}


############### Export Media Bucket ######################

output "media_bucket_id" {
  value = module.s3.media_bucket_id
}


####################### Export Backend Sg ####################
output "backend_sg" {
  value = module.sg.backend_sg
}


################## Export Alb Sg #####################
output "alb_sg" {
  value = module.sg.alb_sg
}

############## Export Instance Profile Name ##################
output "instance_profile_name" {
  value = module.iam.instance_profile_name

}

############### Export Private subnet 1 ID ###############
output "private_subnet_1_id" {
  value = module.vpc.private_subnet_1_id
}

############### Export Private subnet 2 ID ###############
output "private_subnet_2_id" {
  value = module.vpc.private_subnet_2_id
}


###################### Export ALB DNS NAME #######################

output "alb_dns_name" {
    value = module.alb.alb_dns_name
}
#################### Export ECR Repository ID ####################

output "backend_repository_url" {
    value = module.ecr.backend_repository_url
}

######################## Output DNS Name ################################
output "alb_dns_name" {
  value   = module.alb.alb_dns_name
}

###################### Export the Bucket Name holding the Frontend Assets ##################
output "frontend_bucket_name" {
  value = module.s3.frontend_bucket_name
}
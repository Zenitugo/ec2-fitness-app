#################### Export ECR Repository ID ####################

output "backend_repository_url" {
    value = module.ecr.backend_repository_url
}
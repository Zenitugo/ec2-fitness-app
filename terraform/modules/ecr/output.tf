#################### Export ECR Repository ID ####################

output "backend_repository_url" {
    value = aws_ecr_repository.backend_repository.repository_url
}
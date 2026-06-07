#################### Export ECR Repository ID ####################

output "frontend_repository_id" {
    value = aws_ecr_repository.frontend_repository.id
}

output "backend_repository_id" {
    value = aws_ecr_repository.backend_repository.id
}
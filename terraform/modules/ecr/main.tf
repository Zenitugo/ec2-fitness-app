############################ ECR Repository Template #########################
resource "aws_ecr_repository" "frontend_repository" {
    name = "${var.environment_name}-frontend-repo"
    image_tag_mutability = "MUTABLE"
    force_delete = true
    image_scanning_configuration {
        scan_on_push = true
    }
}

resource "aws_ecr_repository" "backend_repository" {
    name = "${var.environment_name}-backend-repo"
    image_tag_mutability = "MUTABLE"
    force_delete = true
    
    image_scanning_configuration {
        scan_on_push = true
    }
}
# ============================================================
# SSM Parameter Store
# Stores config values for EC2 user data script to fetch at boot
# ============================================================

resource "aws_ssm_parameter" "db_host" {
  name        = "/${var.project_name}/${var.environment_name}/db_host"
  type        = "String"
  value       = module.rds.db_endpoint
  tags = {
    Environment = var.environment_name
  }
}

resource "aws_ssm_parameter" "db_secret_arn" {
  name        = "/${var.project_name}/${var.environment_name}/db_secret_arn"
  type        = "SecureString"
  value       = module.rds.db_secret_arn

  tags = {
    Environment = var.environment_name
  }
}

resource "aws_ssm_parameter" "media_bucket" {
  name        = "/${var.project_name}/${var.environment_name}/media_bucket"
  type        = "String"
  value       = module.s3.media_bucket_id


  tags = {
    Environment = var.environment_name
  }
}

resource "aws_ssm_parameter" "frontend_bucket" {
  name        = "/${var.project_name}/${var.environment_name}/frontend_bucket"
  type        = "String"
  value       = module.s3.frontend_bucket_name
  
  tags = {
    Environment = var.environment_name
  }
}

resource "aws_ssm_parameter" "ecr_registry" {
  name        = "/${var.project_name}/${var.environment_name}/ecr_registry"
  type        = "String"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"


  tags = {
    Environment = var.environment_name
  }
}

resource "aws_ssm_parameter" "backend_repo_name" {
  name        = "/${var.project_name}/${var.environment_name}/backend_repo_name"
  type        = "String"
  value       = module.ecr.backend_repo_name

  tags = {
    Environment = var.environment_name
  }
}
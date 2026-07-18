data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

###################  Create Custom IAM Policy for EC2 Permissions ###################
data "aws_iam_policy_document" "ec2_permissions" {
  # ECR: Pull Docker images on startup
  statement {
    sid    = "ECRImagePull"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"] # GetAuthorizationToken requires "*"
  }
# S3: Upload and retrieve workout media
  statement {
    sid    = "S3MediaAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      var.bucket_arn, # Bucket ARN from S3 module output
      "${var.bucket_arn}/*"
    ]
  }

# Secrets Manager: Read database password
  statement {
    sid    = "SecretsManagerRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      var.db_secret_arn
    ]
  }
}




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
      "arn:aws:s3:::your-workout-media-bucket-name",
      "arn:aws:s3:::your-workout-media-bucket-name/*"
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
      "arn:aws:secretsmanager:*:*:secret:db-password-*" # Replace with your exact Secret ARN
    ]
  }
}




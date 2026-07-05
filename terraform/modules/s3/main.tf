############################## Create s3 Bucket for storing media photos ##############################

  # Media Bucket (Fully Private)
resource "aws_s3_bucket" "media_bucket" {
  bucket_prefix = var.bucket_prefix
}

resource "aws_s3_bucket_public_access_block" "media_bucket_privacy" {
  bucket = aws_s3_bucket.media_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



########################## Create S3 Bucket for Frontend Hosting (Public) ##########################
# Frontend Bucket
resource "aws_s3_bucket" "frontend_bucket" {
  bucket_prefix = "${var.bucket_prefix}-frontend"
}

# Static Website Hosting Config
resource "aws_s3_bucket_website_configuration" "frontend_hosting" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Strict Block Public Access (Frontend served via CloudFront only)
resource "aws_s3_bucket_public_access_block" "frontend_privacy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}





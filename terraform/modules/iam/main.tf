################### Create IAM Role ###################
resource "aws_iam_role" "ec2_role" {
  name               = var.role_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


################### Attach Custom Policy to Role ###################
resource "aws_iam_policy" "ec2_custom_policy" {
  name         = var.custom_policy_name
  description = "Permissions for ECR pull, S3 workout media, and Secrets Manager"
  policy      = data.aws_iam_policy_document.ec2_permissions.json
}

resource "aws_iam_role_policy_attachment" "custom_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_custom_policy.arn
}


####################  Attach Managed Policies for SSM and CloudWatch ####################
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# AWS Managed Policy for CloudWatch Agent (Logs and Metrics)
resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


##################### Create IAM Instance Profile #####################
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.Instance_profile_name
  role = aws_iam_role.ec2_role.name
}


# # S3 Bucket Policy allowing CloudFront OAC access
# resource "aws_s3_bucket_policy" "allow_cloudfront_oac" {
#   bucket = var.frontend_bucket_name # Pass the bucket name from the S3 module output

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "AllowCloudFrontServicePrincipalReadOnly"
#         Effect    = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#         Action   = "s3:GetObject"
#         Resource = "${var.frontend_bucket_arn}/*"
#         Condition = {
#           StringEquals = {
#             "AWS:SourceArn" = "${var.cloudfront_distribution_arn}"
#           }
#         }
#       }
#     ]
#   })
# }
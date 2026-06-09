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
  name = var.instance_profile_name
  role = aws_iam_role.ec2_role.name
}



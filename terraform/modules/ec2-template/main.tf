#######################  Launch an Instance Template #######################
resource "aws_launch_template" "fitness_app_launch_template" {
  name_prefix   = "${var.environment_name}-fitness-app"
  image_id           = var.image_id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [var.backend_sg]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  monitoring {
    enabled = true
  }
  
  # Enforce IMDSV2 for security
  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
    http_put_response_hop_limit = 1
    instance_metadata_tags = "disabled"
  }

  user_data = file("${path.module}/template.sh")
}
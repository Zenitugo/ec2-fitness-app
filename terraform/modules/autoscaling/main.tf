
##########################  Auto Scaling Group Configuration #########################
resource "aws_autoscaling_group" "fitness_app_autoscaling_group" {
  name                      = "${var.environment_name}-fitness-app-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  launch_template {
    id      = var.launch_template
    version = "$Latest"
  }
  vpc_zone_identifier       = [var.private_subnet_1_id, var.private_subnet_2_id] 
}




################# SCALE UP CONFIGURATION (CPU > 70%) ######################


# Policy to add 1 instance when triggered
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "cpu-scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.fitness_app_autoscaling_group.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0 # 0 means "at or anywhere above the alarm threshold"
  }
}


###################### SCALE DOWN CONFIGURATION (CPU < 30%) ########################

# Policy to remove 1 instance when triggered
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "cpu-scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.fitness_app_autoscaling_group.name
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_upper_bound = 0 # 0 means "at or anywhere below the alarm threshold"
  }
}


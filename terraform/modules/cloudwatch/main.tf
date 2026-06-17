########################### CloudWatch Configuration ###########################
# Alarm that monitors if CPU exceeds 70% for two consecutive 1-minute intervals
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "asg-cpu-high-70-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 # 60 seconds per evaluation period
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  alarm_actions = [var.scale_up_policy_arn]
}


# Alarm that monitors if CPU drops below 30% for two consecutive 1-minute intervals
resource "aws_cloudwatch_metric_alarm" "cpu_low_alarm" {
  alarm_name          = "asg-cpu-low-30-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  alarm_actions = [var.scale_down_policy_arn]
}

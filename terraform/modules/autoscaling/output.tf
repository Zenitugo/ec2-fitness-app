############## Export IDs of the Auto Scaling Group ##################
output "autoscaling_group_id" {
    value = aws_autoscaling_group.fitness_app_autoscaling_group.id
    }

output "scale_up_policy_arn" {
    value = aws_autoscaling_policy.scale_up_policy.arn
    }

output "scale_down_policy_arn" {
    value = aws_autoscaling_policy.scale_down_policy.arn
    }

output "autoscaling_group_name" {
    value = aws_autoscaling_group.fitness_app_autoscaling_group.name
    }
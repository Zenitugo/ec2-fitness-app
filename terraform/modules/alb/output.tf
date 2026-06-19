############ Export IDs of created resources ############
output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.fittrack_app_target_group.arn
}
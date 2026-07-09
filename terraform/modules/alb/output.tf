############ Export IDs of created resources ############
output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.fittrack_app_target_group.arn
}

output "alb_dns_name" {
  value   = aws_lb.fittrack_load_balancer.dns_name
}
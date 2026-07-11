# Reference the auto generated secret ARN
output "db_secret_arn" {
  value       = aws_db_instance.fittrack_rds.master_user_secret[0].secret_arn
  description = "ARN of the RDS managed secret"
}


#Export the rds endpoint
output "db_endpoint" {
  value = aws_db_instance.fittrack_rds.address
}
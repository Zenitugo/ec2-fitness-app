# Reference the auto generated secret ARN
output "db_secret_arn" {
  value       = aws_db_instance.fitness_rds.master_user_secret[0].secret_arn
  description = "ARN of the RDS managed secret"
}
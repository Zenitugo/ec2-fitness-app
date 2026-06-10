########################## Exports ##########################

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.frontend_distribution.arn
}
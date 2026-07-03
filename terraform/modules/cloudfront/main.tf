# # CloudFront Origin Access Control (OAC)
# resource "aws_cloudfront_origin_access_control" "oac" {
#   name                              = var.cloudfront_oac_name
#   description                       = "OAC for React Frontend S3 Bucket"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

# # CloudFront Distribution
# resource "aws_cloudfront_distribution" "frontend_distribution" {
#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"

#   origin {
#     domain_name              = var.bucket_regional_domain_name
#     origin_id                = "S3-Frontend"
#     origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
#   }

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "S3-Frontend"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   # SPA Routing: Redirect 403 and 404 to index.html with a 200 status
#   custom_error_response {
#     error_code            = 403
#     response_code         = 200
#     response_page_path    = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   custom_error_response {
#     error_code            = 404
#     response_code         = 200
#     response_page_path    = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# }
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.front_distribution.domain_name
  description = "The cloudfront domain name"
}
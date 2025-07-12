output "bucket_domain_name" {
  description = "The s3 bucket domain name"
  value = aws_s3_bucket.recipe_bucket.bucket_domain_name
}
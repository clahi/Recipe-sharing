resource "aws_s3_bucket" "recipe_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "recipe bucket"
    Environment = "Dev"
  }
}

# A bucket policy which only allows access from a specific cloudfront
resource "aws_s3_bucket_policy" "prive_access_policy" {
  bucket = aws_s3_bucket.recipe_bucket.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "PolicyForCloudFrontPrivateContent"
    "Statement": [
        {
            "Sid": "AllowCloudfrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
        }
    ]
  })
}
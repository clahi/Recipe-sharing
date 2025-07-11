resource "aws_s3_bucket" "recipe_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "recipe bucket"
    Environment = "Dev"
  }
}

<<<<<<< HEAD
# Setting the s3 bucket to act as a web page host
resource "aws_s3_bucket_website_configuration" "s3_web_config" {
  bucket = aws_s3_bucket.recipe_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

=======
>>>>>>> 237e49aa6fecda982217174204c4ce4f36d57cbb
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
<<<<<<< HEAD
                 "arn:aws:s3:::${var.bucket_name}/*"
=======
                "arn:aws:s3:::${var.bucket_name}/*"
>>>>>>> 237e49aa6fecda982217174204c4ce4f36d57cbb
            ]
        }
    ]
  })
}
resource "aws_s3_bucket" "react_config_bucket" {
  bucket = "react-runtime-config-mlops"
  force_destroy = true

  tags = {
    Name = "ReactRuntimeConfig"
  }
}

resource "aws_s3_bucket_public_access_block" "no_block" {
  bucket = aws_s3_bucket.react_config_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.react_config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.react_config_bucket.arn}/*"
    }]
  })
}

resource "aws_s3_object" "react_config" {
  bucket       = aws_s3_bucket.react_config_bucket.id
  key          = "config.json"
  source       = "${path.module}/files/config.json"
  content_type = "application/json"
  acl          = "public-read"

  metadata = {
    Cache-Control = "no-cache"
  }
}

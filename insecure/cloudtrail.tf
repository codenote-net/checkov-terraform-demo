resource "aws_cloudtrail" "main" {
  name                       = "demo-insecure-trail"
  s3_bucket_name             = aws_s3_bucket.data.id
  enable_log_file_validation = false
}

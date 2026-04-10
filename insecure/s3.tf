resource "aws_s3_bucket" "data" {
  bucket = "demo-insecure-bucket"
}

resource "aws_s3_bucket_acl" "data" {
  bucket = aws_s3_bucket.data.id
  acl    = "public-read"
}

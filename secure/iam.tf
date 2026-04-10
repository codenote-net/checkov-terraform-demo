resource "aws_iam_policy" "app" {
  name        = "demo-secure-policy"
  description = "Least privilege policy for application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::demo-secure-bucket",
          "arn:aws:s3:::demo-secure-bucket/*"
        ]
      }
    ]
  })
}

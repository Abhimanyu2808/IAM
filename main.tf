provider "aws" {
 region = var.region
}

resource "aws_iam_user" "abhi_user" {
 name = var.iam_user_name
}

resource "aws_iam_user_login_profile" "abhi_user_login_profile" {
 user    = aws_iam_user.abhi_user.name
}    


resource "aws_s3_bucket" "bucket" {
   bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}  

resource "aws_iam_policy" "policy" {
  name        = "my_policy"
  path        = "/"
  description = "My s3 policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:ListAllMyBuckets"
        ],
    
        Resource = [
             aws_s3_bucket.bucket.arn,
            "${aws_s3_bucket.bucket.arn}/*"
        ]
      },
    ]
  })
}  

resource "aws_iam_user_policy_attachment" "policy-attach" {
  user       = aws_iam_user.abhi_user.name
  policy_arn = aws_iam_policy.policy.arn
}
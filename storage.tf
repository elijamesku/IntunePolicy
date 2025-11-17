resource "aws_s3_bucket" "main" {
  bucket = "my-s3-bucket"
  tags = {
    Name = "my-s3-bucket"
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = "{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.main.arn}/*"
    }
  ]
}"
}

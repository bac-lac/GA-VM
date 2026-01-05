resource "aws_s3_bucket" "ssm_s3" {
  bucket = "ssm-goanywhere-${var.ENV}"
     
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "ssm_versioning" {
  bucket = aws_s3_bucket.ssm_s3.id

  versioning_configuration {
    status = "Enabled"
  }
}
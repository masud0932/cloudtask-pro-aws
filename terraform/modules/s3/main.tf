resource "aws_s3_bucket" "frontend" {
  bucket = "${var.name_prefix}-frontend-${random_string.suffix.result}"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-frontend"
  })
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.name_prefix}-artifacts-${random_string.suffix.result}"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-artifacts"
  })
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" { #block public access to the bucket to ensure it's only accessible through CloudFront
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "artifacts" { #block public access to the bucket to ensure it's only accessible through CloudFront
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

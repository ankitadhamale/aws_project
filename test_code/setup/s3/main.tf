resource "aws_s3_bucket" "terraform_state" {
    bucket        = var.bucket_name
    region        = var.region
    force_destroy = false
    tags = {
        Purpose   = "Terraform State Bucket"
        CreatedBy = "terraform"
    }
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable lifecycle configuration to manage old versions
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  depends_on = [aws_s3_bucket_versioning.terraform_state]
  bucket     = aws_s3_bucket.terraform_state.id

  rule {
    id     = "terraform_state_lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.state_file_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Purpose     = "terraform-state-locking"
    CreatedBy   = "terraform"
  }
}

# IAM policy for Terraform to access S3 and DynamoDB
data "aws_iam_policy_document" "terraform_backend_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning"
    ]
    resources = [aws_s3_bucket.terraform_state.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.terraform_state.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.terraform_state_lock.arn]
  }
}

# IAM policy resource
resource "aws_iam_policy" "terraform_backend_policy" {
  name        = "terraform-backend-access-${var.environment}"
  description = "IAM policy for Terraform backend access"
  policy      = data.aws_iam_policy_document.terraform_backend_policy.json

  tags = {
    Name        = "Terraform Backend Policy"
    CreatedBy   = "terraform"
  }
}
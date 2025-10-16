terraform {
  required_version = ">= 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  bucket_name = "${var.project}-tfstate-${var.account_id}-${var.region}"
  table_name  = "${var.project}-tf-locks-${var.account_id}-${var.region}"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name
  force_destroy = false
}

# Bloqueia acesso público
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versionamento
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}

# Criptografia SSE-S3 (troque por KMS se preferir)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle: aborta uploads incompletos
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    id     = "abort-incomplete-mpu"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Política: obriga HTTPS (SecureTransport)
data "aws_iam_policy_document" "deny_insecure_transport" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.tfstate.arn,
      "${aws_s3_bucket.tfstate.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.tfstate.id
  policy = data.aws_iam_policy_document.deny_insecure_transport.json
}

# DynamoDB para lock
resource "aws_dynamodb_table" "locks" {
  name           = local.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  point_in_time_recovery { enabled = true }

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "bucket_name" { value = aws_s3_bucket.tfstate.bucket }
output "table_name"  { value = aws_dynamodb_table.locks.name }

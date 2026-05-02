resource "aws_kms_key" "s3" {
  count               = var.enable_kms ? 1 : 0
  description         = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 30
  tags = merge({ Name = "ocean-across-s3-kms" }, var.tags)
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.enable_kms ? aws_kms_key.s3[0].arn : "alias/aws/s3"
        sse_algorithm     = var.enable_kms ? "aws:kms" : "AES256"
      }
    }
  }

  force_destroy = false

  tags = merge({ Name = "ocean-across-bucket" }, var.tags)
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

// Enforce TLS and deny public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "DenyNonTls"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "${aws_s3_bucket.this.arn}",
          "${aws_s3_bucket.this.arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = false }
        }
      }
    ]
  })
}

// Create stable prefixes as zero-byte objects to help IAM path restrictions
resource "aws_s3_object" "company_prefix" {
  bucket = aws_s3_bucket.this.id
  key    = "company/.keep"
  content = ""
}

resource "aws_s3_object" "bureau_prefix" {
  bucket = aws_s3_bucket.this.id
  key    = "bureau/.keep"
  content = ""
}

resource "aws_s3_object" "employee_prefix" {
  bucket = aws_s3_bucket.this.id
  key    = "employee/.keep"
  content = ""
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

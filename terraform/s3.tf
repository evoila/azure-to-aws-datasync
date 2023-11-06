resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    name = var.bucket_name
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.cmk_s3_alias.target_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "report_bucket" {
  bucket = "${var.bucket_name}-report"

  tags = {
    name = "${var.bucket_name}-report"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "report" {
  bucket = aws_s3_bucket.report_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.cmk_s3_alias.target_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

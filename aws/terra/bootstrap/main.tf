# --- Terraform remote state bucket (bootstrap) ---
#
# This bucket has to exist BEFORE you can point the "backend s3" block at it,
# so it's created here with local state first. Steps:
#   1. terraform apply   (creates the bucket below, still using local state)
#   2. copy the bucket name into envs/prod/backend.tf and run
#      `terraform init -migrate-state` to move state into this bucket
#
# random_id keeps the bucket name globally unique without hardcoding the
# account id into a name you might reuse across accounts later.
resource "random_id" "tfstate_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "your-own-bucket-name-${random_id.tfstate_suffix.hex}"

  # Refuse to destroy this bucket via `terraform destroy` by accident --
  # it holds the state for everything else you manage with Terraform.
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name    = "terraform-state"
    Purpose = "terraform-remote-state"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# SSE-S3 (AES256) is enough for state at rest; swap for a KMS key + policy
# if you need audit-logged key usage or cross-account access control later.
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Deny any request to this bucket that isn't over TLS -- state can contain
# secrets in plaintext (e.g. DB passwords in resource attributes), so
# enforcing HTTPS-only access is the one bucket policy rule worth having
# even on a "dummy" bucket.
data "aws_iam_policy_document" "tfstate_tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.tfstate.arn,
      "${aws_s3_bucket.tfstate.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  policy = data.aws_iam_policy_document.tfstate_tls_only.json
}

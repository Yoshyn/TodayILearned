provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-stuff"
  acl    = "private"

  versioning { enabled = true }
  lifecycle { prevent_destroy = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name       = "terraform_state"
    module     = "tf-backend"
    Automation = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

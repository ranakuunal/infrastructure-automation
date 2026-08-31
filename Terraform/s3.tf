data "aws_caller_identity" "current" {}

#---------------------------
# MongoDB Backup S3 Bucket
#---------------------------

resource "aws_s3_bucket" "mongodb_backups" {
  bucket = "${var.project_name}-mongodb-backups-${data.aws_caller_identity.current.account_id}"

  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mongodb-backups"
  })
}

#-----------------------------------------
# Making MongoDB Backup S3 Bucket Public
#-----------------------------------------

resource "aws_s3_bucket_public_access_block" "mongodb_backups" {
  bucket = aws_s3_bucket.mongodb_backups.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "mongodb_backups_public" {
  bucket = aws_s3_bucket.mongodb_backups.id

  depends_on = [
    aws_s3_bucket_public_access_block.mongodb_backups
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicListBucket"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = aws_s3_bucket.mongodb_backups.arn
      },
      {
        Sid       = "PublicReadBackups"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.mongodb_backups.arn}/*"
      }
    ]
  })
}
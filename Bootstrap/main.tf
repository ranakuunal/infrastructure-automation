data "aws_caller_identity" "current" {}

#------------------------------
# Terraform State Backend
#------------------------------

resource "aws_s3_bucket" "terraform_state" {
  bucket = "wiz-exercise-tfstate-${data.aws_caller_identity.current.account_id}"

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#------------------------------
# GitHub CI User
#------------------------------

resource "aws_iam_user" "github_ci" {
  name = "wiz-github-ci-user"

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

#-------------------------------
#GitHub CI User IAM Role
#-------------------------------

resource "aws_iam_role" "github_ci_user_role" {
  name = "wiz-deployment-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = aws_iam_user.github_ci.arn
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

#------------------------------------------------
# Allow GitHub CI User to Assume Deployment Role
#------------------------------------------------

resource "aws_iam_user_policy" "github_ci_user_assumerole" {
  name = "Wiz-exercise-AllowAssumeDeploymentRole"
  user = aws_iam_user.github_ci.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sts:AssumeRole"
        ]

        Resource = aws_iam_role.github_ci_user_role.arn
      }
    ]
  })
}

#---------------------------------------------
# Administrator Access for github_ci_user_role
# --------------------------------------------

resource "aws_iam_role_policy_attachment" "github_ci_user_role_admin" {
  role       = aws_iam_role.github_ci_user_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
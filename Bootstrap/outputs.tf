output "terraform_state_bucket" {
  description = "S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "deployment_role_arn" {
  description = "IAM role assumed by GitHub Actions"
  value       = aws_iam_role.github_ci_user_role.arn
}

output "github_ci_user_name" {
  description = "IAM user used by GitHub Actions for initial authentication"
  value       = aws_iam_user.github_ci.name
}
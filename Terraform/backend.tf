terraform {
  backend "s3" {
    bucket       = "wiz-exercise-tfstate-583067668053"
    key          = "wiz-assessment/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
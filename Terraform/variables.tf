variable "aws_region" {
  description = "AWS region for the Wiz technical exercise"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Resource naming prefix"
  type        = string
  default     = "wiz-exercise"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.30.0.0/16"
}
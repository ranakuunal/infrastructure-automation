#-----------------------
# Tasky ECR Repository
#-----------------------

resource "aws_ecr_repository" "tasky" {
  name                 = "${var.project_name}-tasky"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tasky"
  })
}
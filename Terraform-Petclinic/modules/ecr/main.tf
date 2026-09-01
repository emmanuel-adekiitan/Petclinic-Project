variable "environment" { type = string }

resource "aws_ecr_repository" "repo" {
  name                 = "ecr-petclinic-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" { value = aws_ecr_repository.repo.repository_url }
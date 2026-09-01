
variable "environment" { type = string }

resource "aws_ecr_repository" "app" {
  # checkov:skip=CKV_AWS_136: KMS encryption skipped in favor of default AES256 to minimize KMS key costs

  name                 = "ecr-petclinic-${var.environment}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" {
  value = aws_ecr_repository.app.repository_url
}
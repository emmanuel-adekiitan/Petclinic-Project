
variable "environment" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_secretsmanager_secret" "db_secret" {
  # checkov:skip=CKV2_AWS_57: Automatic secret rotation disabled to avoid Lambda execution costs
  # checkov:skip=CKV_AWS_149: AWS managed KMS key used instead of Customer Managed Key to avoid KMS key charges

  name = "petclinic-db-credentials-${var.environment}"
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "petclinicadmin"
    password = var.db_password
  })
}

output "secret_arn" { value = aws_secretsmanager_secret.db_secret.arn }
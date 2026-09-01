
variable "environment" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "petclinic-db-credentials-${var.environment}"
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "petclinicadmin"
    password = var.db_password
  })
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}
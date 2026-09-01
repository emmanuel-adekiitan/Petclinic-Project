
variable "environment" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}

variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

resource "aws_db_subnet_group" "main" {
  name       = "dbsng-petclinic-${var.environment}"
  subnet_ids = var.private_subnet_ids
}

# checkov:skip=CKV_AWS_157: Multi-AZ disabled to remain within AWS Free Tier limits
# checkov:skip=CKV_AWS_161: IAM database authentication disabled for simple app credential management
resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  max_allocated_storage  = 100
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "petclinic"
  username               = "petclinicadmin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
  auto_minor_version_upgrade = true
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
}

output "db_endpoint" {
  value = aws_db_instance.mysql.endpoint
}
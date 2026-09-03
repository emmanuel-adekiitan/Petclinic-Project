variable "environment" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}

variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

# Optional input for active migration scenarios; defaults to [] for clean deployments
variable "legacy_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Optional legacy subnet IDs retained during active infrastructure migrations"
}

resource "aws_db_subnet_group" "main" {
  name = "dbsng-petclinic-${var.environment}"

  # Merges managed subnets with any legacy subnets; dedupes and removes null/empty elements
  subnet_ids = compact(distinct(concat(
    var.public_subnet_ids,
    var.private_subnet_ids,
    var.legacy_subnet_ids
  )))
}

resource "aws_db_instance" "mysql" {
  # checkov:skip=CKV_AWS_293: Deletion protection disabled for lab destroyability
  # checkov:skip=CKV_AWS_118: Enhanced monitoring disabled to avoid extra CloudWatch costs
  # checkov:skip=CKV_AWS_161: IAM database authentication disabled for simple app auth
  # checkov:skip=CKV_AWS_157: Multi-AZ disabled to remain within AWS Free Tier limits
  # checkov:skip=CKV2_AWS_60: Copy tags to snapshot enabled below

  allocated_storage               = 20
  max_allocated_storage           = 100
  engine                          = "mysql"
  engine_version                  = "8.0"
  instance_class                  = "db.t3.micro"
  db_name                         = "petclinic"
  username                        = "petclinicadmin"
  password                        = var.db_password
  db_subnet_group_name            = aws_db_subnet_group.main.name
  skip_final_snapshot             = true
  auto_minor_version_upgrade      = true
  storage_encrypted               = true
  copy_tags_to_snapshot           = true
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  # Prevents public IP assignment while keeping NAT Gateway costs at $0
  publicly_accessible = false
}

output "db_endpoint" { value = aws_db_instance.mysql.endpoint }
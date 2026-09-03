
variable "environment" { type = string }

resource "aws_vpc" "main" {
  # checkov:skip=CKV2_AWS_11: VPC Flow Logs disabled to prevent CloudWatch Ingestion and S3 storage costs

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-petclinic-${var.environment}"
  }
}

resource "aws_default_security_group" "default" {
  # checkov:skip=CKV2_AWS_12: Default security group management skipped in lab environment
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  # checkov:skip=CKV_AWS_130: Public IP assignment required for worker node internet access and ALB ingress

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ca-central-1a"

  tags = {
    Name = "subnet-petclinic-public-${var.environment}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ca-central-1b"

  tags = {
    Name = "subnet-petclinic-private-${var.environment}"
  }
}

output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = [aws_subnet.public.id] }
output "private_subnet_ids" { value = [aws_subnet.private.id] }
variable "environment" { type = string }

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-petclinic-${var.environment}"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  # checkov:skip=CKV_AWS_130: Public subnets require public IP assignment for internet routing without a NAT gateway
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24" # 10.0.1.0/24 & 10.0.2.0/24
  map_public_ip_on_launch = true
  availability_zone       = count.index == 0 ? "ca-central-1a" : "ca-central-1b"

  tags = {
    Name                                       = "subnet-petclinic-public-${count.index + 1}-${var.environment}"
    "kubernetes.io/role/elb"                   = "1"
    "kubernetes.io/cluster/eks-petclinic-prod" = "shared"
  }
}
resource "aws_subnet" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  # Index 0 stays on active 10.0.11.0/24; Index 1 takes 10.0.20.0/24 to avoid 10.0.2.0/24 public overlap
  cidr_block        = count.index == 0 ? "10.0.11.0/24" : "10.0.20.0/24"
  availability_zone = count.index == 0 ? "ca-central-1b" : "ca-central-1a"

  tags = {
    Name                                       = "subnet-petclinic-private-${count.index + 1}-${var.environment}"
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/eks-petclinic-prod" = "shared"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
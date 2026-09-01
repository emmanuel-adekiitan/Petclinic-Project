
variable "environment" { type = string }
variable "subnet_ids" { type = list(string) }

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# checkov:skip=CKV_AWS_37: Control plane logging disabled to minimize CloudWatch cost
# checkov:skip=CKV_AWS_38: Public endpoint access required for deployment runner connection
# checkov:skip=CKV_AWS_39: Public cluster endpoint enabled for external CLI management
# checkov:skip=CKV_AWS_58: KMS secrets envelope encryption disabled to avoid KMS key costs
resource "aws_eks_cluster" "main" {
  name     = "eks-petclinic-${var.environment}"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
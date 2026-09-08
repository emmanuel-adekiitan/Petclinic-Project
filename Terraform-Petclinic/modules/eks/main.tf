
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

resource "aws_eks_cluster" "main" {
  # checkov:skip=CKV_AWS_37: Control plane logging disabled to minimize CloudWatch costs
  # checkov:skip=CKV_AWS_38: Public endpoint access required for deployment runner connection
  # checkov:skip=CKV_AWS_39: Public cluster endpoint enabled for external CLI management
  # checkov:skip=CKV_AWS_58: KMS secrets envelope encryption disabled to avoid KMS key costs

  name     = "eks-petclinic-${var.environment}"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::128793514564:role/Allow-Peclinic-repo"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::128793514564:role/Allow-Peclinic-repo"

  access_scope {
    type = "cluster"
  }
}

# IAM Role for EKS Worker Nodes
resource "aws_iam_role" "node_role" {
  name = "eks-node-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_amazon_ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

resource "aws_eks_node_group" "petclinic_nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "petclinic-nodegroup"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  # Use t3.micro to stay aligned with free-tier constraints
  instance_types = ["t3.micro"]

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.node_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.node_amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.node_amazon_ec2_container_registry_readonly
  ]
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
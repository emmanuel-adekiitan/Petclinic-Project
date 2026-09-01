variable "aws_region" {
  type        = string
  default     = "ca-central-1"
  description = "Target AWS region."
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Deployment environment name."
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Administrator password for Amazon RDS MySQL."
}

variable "cluster_name" {
  type        = string
  default     = "petclinic-eks-cluster"
  description = "Name of the EKS cluster."
}
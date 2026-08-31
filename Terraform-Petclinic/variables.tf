variable "location" {
  type        = string
  default     = "west US 2"
  description = "Primary Azure deployment region."
}

variable "resource_group_name" {
  type        = string
  default     = "rg-petclinic-prod"
  description = "Name of the target Azure Resource Group."
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Administrator password for Azure MySQL Flexible Server."
}
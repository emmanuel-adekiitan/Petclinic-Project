variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "server_name" { type = string }
variable "admin_username" { type = string }
variable "admin_password" {
  type      = string
  sensitive = true
}
variable "mysql_subnet_id" { type = string }

resource "azurerm_mysql_flexible_server" "db" {
  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = "GP_Standard_D2ds_v4"
  delegated_subnet_id    = var.mysql_subnet_id

  storage {
    size_gb = 32
  }
}

resource "azurerm_mysql_flexible_database" "databases" {
  for_each            = toset(["petclinic_customers", "petclinic_vets", "petclinic_visits"])
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.db.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

output "server_fqdn" { value = azurerm_mysql_flexible_server.db.fqdn }
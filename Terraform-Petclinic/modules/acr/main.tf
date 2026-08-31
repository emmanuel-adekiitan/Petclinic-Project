variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "acr_name" { type = string }

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

output "acr_id" { value = azurerm_container_registry.acr.id }
output "login_server" { value = azurerm_container_registry.acr.login_server }
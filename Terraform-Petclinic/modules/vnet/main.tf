variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/22"]
}

resource "azurerm_subnet" "mysql_subnet" {
  name                 = "snet-mysql"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.8.0/24"]
  delegation {
    name = "fs"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

output "aks_subnet_id" { value = azurerm_subnet.aks_subnet.id }
output "mysql_subnet_id" { value = azurerm_subnet.mysql_subnet.id }
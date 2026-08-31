resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "vnet-petclinic-prod"
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  acr_name            = "acrpetclinicprod"
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = "aks-petclinic-prod"
  aks_subnet_id       = module.vnet.aks_subnet_id
}

resource "azurerm_role_assignment" "aks_acr_attach" {
  principal_id                     = module.aks.kubelet_identity_object_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.acr_id
  skip_service_principal_aad_check = true
}

module "mysql" {
  source              = "./modules/mysql"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = "mysql-petclinic-prod"
  admin_username      = "petclinicadmin"
  admin_password      = var.db_password
  mysql_subnet_id     = module.vnet.mysql_subnet_id
}

module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  keyvault_name       = "kv-petclinic-prod"
}
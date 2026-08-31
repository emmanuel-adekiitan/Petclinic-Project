output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "mysql_server_fqdn" {
  value = module.mysql.server_fqdn
}

output "keyvault_uri" {
  value = module.keyvault.vault_uri
}
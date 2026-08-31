variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "cluster_name" { type = string }
variable "aks_subnet_id" { type = string }

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "petclinic-k8s"

  default_node_pool {
    name           = "system"
    node_count     = 2
    vm_size        = "Standard_D2s_v5"
    vnet_subnet_id = var.aks_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

output "cluster_name" { value = azurerm_kubernetes_cluster.aks.name }
output "kubelet_identity_object_id" { value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id }
resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "aks1"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "prefixaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}



provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "res_group_jenkins" {
  name     = "jenkinsNew"
  location = "France Central"
}

module "akscluster" {
  source              = "./modules/aks_cluster"
  location            = azurerm_resource_group.res_group_jenkins.location
  resource_group_name = azurerm_resource_group.res_group_jenkins.name
}

module "jenkins_vm" {
  source              = "./modules/jenkins_vm"
  location            = azurerm_resource_group.res_group_jenkins.location
  resource_group_name = azurerm_resource_group.res_group_jenkins.name
}

output "kube_config" {
  value     = module.akscluster.kube_config
  sensitive = true
}

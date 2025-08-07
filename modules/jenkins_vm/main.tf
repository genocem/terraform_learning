resource "azurerm_virtual_network" "jenkinsVN" {
  name                = "jenkins-network"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_subnet" "jenkinsSubnet" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.jenkinsVN.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_jenkins_ip" {
  name                = "jenkins_public_ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "jenkinsNetworkInterface" {
  name                = "jenkins-nic"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jenkinsSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_jenkins_ip.id
  }
}


resource "azurerm_network_security_group" "jenkins_security_group" {
  name                = "acceptanceTestSecurityGroup1"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}
resource "azurerm_network_interface_security_group_association" "jenkins_interface_securitygroup_association" {
  network_interface_id      = azurerm_network_interface.jenkinsNetworkInterface.id
  network_security_group_id = azurerm_network_security_group.jenkins_security_group.id
}

resource "azurerm_linux_virtual_machine" "jenkinsVM" {
  name                = "jenkins-machine"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ats_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.jenkinsNetworkInterface.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

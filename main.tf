provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg1"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "subnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "pub-ip" {
  name                = "my-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "my-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my-nic-configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "my-linux-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "az"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "az"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwC+frAr25kn30jSC7/W7sjtr5RLWVZlZhLiAMCavQrhaFqZLIwxKmho0SXVAY7hv/qk7hVDRpKOz4snEkWX8qm4lhsG2gY5pTICSYrux7W9J345PttN1NA9ktbt+rRWCBvIXzA5o3f9lekyOvU9PHtiX21PlVXNTCyLxFuayqc5ji02vi8RP9DfaDVzPuh6cWxSTJ0PMXp6fLCigwfCXeJQiOtRkFCVy3g5nErK1DD2Lgdppwk3HWHfGhCycpEnqgIVQyiYbhBYjekzlhhtMv21FEaiArlMa9nbSgPNMQCgSDzDH3MwydEGiEOlu27H1ofkXW8Hl5lRpgrY6ZdqZ3 rsa-key-20230718"
  }

  os_disk {
    name                 = "my-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = base64encode(<<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2 php libapache2-mod-php mysql-server php-mysql
EOF
  )

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

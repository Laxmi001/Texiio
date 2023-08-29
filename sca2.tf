provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg1"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "storage" {
  name                 = "storage1"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints = [ "Microsoft.Storage" ]
}

resource "azurerm_storage_account" "example" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids =[azurerm_subnet.storage.id] 
  }
}

# Service Endpoint Configuration
# resource "azurerm_subnet_service_endpoint_storage_policy" "storage_endpoint_policy" {
#   subnet_id           = azurerm_subnet.example.id
#   storage_account_ids = [azurerm_storage_account.example.id]
# }

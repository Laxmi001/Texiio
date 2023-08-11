provider "azurerm" {
  features {}
}
# variable "resource_group_name" {
#   description = "Name of the resource group"
#   type        = string
#   default = "rg1"
# }

# variable "resource_group_location" {
#   description = "Location of the resource group"
#   type        = string
#   default = "eastus"
# }
# variable "virtual_network_name" {
#   description = "Name of the Virtual network"
#   type = string
#   default = "vnet1" 
# }

resource "azurerm_resource_group" "example" {
  name     = "rg1"
  location = "westus"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mysql_server" "example" {
  name                = "lamp-single-server-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  ssl_enforcement_enabled      = true
}
resource "azurerm_mysql_database" "main" {
  name                = "mysqldbname"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_server.example.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_mysql_virtual_network_rule" "example" {
  name                = "mysql-vnet-rule"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_server.example.name
  subnet_id           = azurerm_subnet.internal.id
}

resource "azurerm_mysql_firewall_rule" "rule1" {
  name                = "mysql-firewall-rule1"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_server.example.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
# resource "azurerm_mysql_server_" "replica" {
#   name                = "lamp-single-server-replica-001"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name

#   administrator_login          = "mysqladminun"
#   administrator_login_password = "H@Sh1CoR3!"

#   sku_name   = "GP_Gen5_2"
#   storage_mb = 5120
#   version    = "5.7"

#   backup_retention_days        = 7
#   geo_redundant_backup_enabled = false
#   ssl_enforcement_enabled      = true

#   create_mode      = "Replica"
#   source_server_id = azurerm_mysql_server.example.id
  
# }

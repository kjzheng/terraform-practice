provider "azurerm" {
  version = 1.38
}

# Create virtual network
resource "azurerm_virtual_network" "TFNet" {
  name                = "LabVNet532"
  address_space       = ["10.0.0.0/16"]
  location            = "westus"
  resource_group_name = "155-87728378-deploy-azure-vlans-and-subnets-with-t"

  tags = {
    environment = "Terraform Networking"
  }
}

# Create subnet
resource "azurerm_subnet" "tfsubnet" {
  name                 = "LabSubnet532"
  resource_group_name  = azurerm_virtual_network.TFNet.resource_group_name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefix     = "10.0.1.0/24"
}
resource "azurerm_subnet" "tfsubnet2" {
  name                 = "LabSubnet5322"
  resource_group_name  = azurerm_virtual_network.TFNet.resource_group_name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefix     = "10.0.2.0/24"
}
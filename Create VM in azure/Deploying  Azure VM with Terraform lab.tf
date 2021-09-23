terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.76.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Create virtual network (a must for creating VM)
resource "azurerm_virtual_network" "TFNet" {
  name                = "challenge_virtual_net"
  address_space       = ["10.0.0.0/16"]
  location            = "southcentralus"
  resource_group_name = "1-16b759c0-playground-sandbox"

  tags = {
    environment = "bryan challenge Terraform VNET"
  }
}
# Create subnet
resource "azurerm_subnet" "tfsubnet" {
  name                 = "challenge_subnet"
  resource_group_name  = azurerm_virtual_network.TFNet.resource_group_name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefixes     = ["10.0.0.0/24"]
}

#Deploy Public IP
resource "azurerm_public_ip" "example" {
  name                = "challenge_public_ip"
  location            = azurerm_virtual_network.TFNet.location
  resource_group_name = azurerm_virtual_network.TFNet.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "challenge_NetworkSecurityGroup"
  location            = azurerm_virtual_network.TFNet.location
  resource_group_name = azurerm_virtual_network.TFNet.resource_group_name

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

  tags = {
    environment = "Terraform challenge"
  }
}

#Create NIC
resource "azurerm_network_interface" "example" {
  name                = "challenge_NIC"
  location            = azurerm_virtual_network.TFNet.location
  resource_group_name = azurerm_virtual_network.TFNet.resource_group_name

  ip_configuration {
    name                          = "challenge_ipconfig"
    subnet_id                     = azurerm_subnet.tfsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

#Create Boot Diagnostic Account
resource "azurerm_storage_account" "sa" {
  name                     = "challengebootacc"
  resource_group_name      = azurerm_virtual_network.TFNet.resource_group_name
  location                 = azurerm_virtual_network.TFNet.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Boot Diagnostic Storage"
    CreatedBy   = "Admin"
  }
}

#Create Virtual Machine1
resource "azurerm_virtual_machine" "example" {
  name                             = "challenge_AzureVM1"
  location                         = azurerm_virtual_network.TFNet.location
  resource_group_name              = azurerm_virtual_network.TFNet.resource_group_name
  network_interface_ids            = [azurerm_network_interface.example.id]
  vm_size                          = "Standard_B1s"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk1"
    disk_size_gb      = "128"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "ServerazureVM1"
    admin_username = "vmadmin"
    admin_password = "Password12345!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.sa.primary_blob_endpoint
  }
}

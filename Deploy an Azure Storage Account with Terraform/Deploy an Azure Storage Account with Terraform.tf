provider "azurerm" {
  version = 1.38
}
resource "azurerm_storage_account" "lab" {
  name                     = "ilikemystorage"
  resource_group_name      = "156-5faae87a-deploy-an-azure-storage-account-with"
  location                 = "West US"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Terraform Storage"
    CreatedBy   = "Admin"
  }
}
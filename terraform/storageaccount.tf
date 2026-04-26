resource "azurerm_storage_account" "abyss" {
  name                     = "abyss"
  resource_group_name      = azurerm_resource_group.abyss.name
  location                 = azurerm_resource_group.abyss.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"

  lifecycle {
    prevent_destroy = true
  }
}

output "storage_account_name" {
  value     = azurerm_storage_account.abyss.name
  sensitive = true
}

output "storage_account_key" {
  value     = azurerm_storage_account.abyss.primary_access_key
  sensitive = true
}

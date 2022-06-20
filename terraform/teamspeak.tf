resource "azurerm_managed_disk" "teamspeak" {
  name                 = "teamspeak"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4

  lifecycle {
    prevent_destroy = true
  }
}

output "teamspeak_disk_id" {
  value     = azurerm_managed_disk.teamspeak.id
  sensitive = true
}

resource "azurerm_role_assignment" "teamspeak_disk_backup_reader" {
  scope                = azurerm_managed_disk.teamspeak.id
  role_definition_name = "Disk Backup Reader"
  principal_id         = azurerm_data_protection_backup_vault.main.identity[0].principal_id
}

resource "azurerm_data_protection_backup_instance_disk" "teamspeak" {
  name                         = azurerm_managed_disk.teamspeak.name
  disk_id                      = azurerm_managed_disk.teamspeak.id
  location                     = azurerm_data_protection_backup_vault.main.location
  vault_id                     = azurerm_data_protection_backup_vault.main.id
  snapshot_resource_group_name = azurerm_resource_group.snapshots.name
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.main.id

  depends_on = [
    azurerm_role_assignment.teamspeak_disk_backup_reader
  ]
}

resource "azurerm_managed_disk" "teamspeak_alt" {
  name                 = "teamspeak-alt"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4

  lifecycle {
    prevent_destroy = true
  }
}

output "teamspeak_alt_disk_id" {
  value     = azurerm_managed_disk.teamspeak_alt.id
  sensitive = true
}

resource "azurerm_managed_disk" "sinusbot" {
  name                 = "sinusbot"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4

  lifecycle {
    prevent_destroy = true
  }
}

output "sinusbot_disk_id" {
  value     = azurerm_managed_disk.sinusbot.id
  sensitive = true
}

resource "azurerm_role_assignment" "sinusbot_disk_backup_reader" {
  scope                = azurerm_managed_disk.sinusbot.id
  role_definition_name = "Disk Backup Reader"
  principal_id         = azurerm_data_protection_backup_vault.main.identity[0].principal_id
}

resource "azurerm_data_protection_backup_instance_disk" "sinusbot" {
  name                         = azurerm_managed_disk.sinusbot.name
  disk_id                      = azurerm_managed_disk.sinusbot.id
  location                     = azurerm_data_protection_backup_vault.main.location
  vault_id                     = azurerm_data_protection_backup_vault.main.id
  snapshot_resource_group_name = azurerm_resource_group.snapshots.name
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.main.id

  depends_on = [
    azurerm_role_assignment.sinusbot_disk_backup_reader
  ]
}

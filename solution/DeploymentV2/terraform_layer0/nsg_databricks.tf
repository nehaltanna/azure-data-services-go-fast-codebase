resource "azurerm_network_security_group" "databricks_nsg" {
  count               = (var.is_vnet_isolated ? 1 : 0)
  name                = local.databricks_nsg_name
  location            = var.resource_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "db_container" {
  count                     = (var.is_vnet_isolated ? 1 : 0)
  subnet_id                 = local.databricks_container_subnet_id
  network_security_group_id = azurerm_network_security_group.databricks_nsg[0].id
}

resource "azurerm_subnet_network_security_group_association" "db_host" {
  count                     = (var.is_vnet_isolated ? 1 : 0)    
  subnet_id                 = local.databricks_host_subnet_id
  network_security_group_id = azurerm_network_security_group.databricks_nsg[0].id
}
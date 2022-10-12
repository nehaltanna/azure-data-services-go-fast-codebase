resource "azurerm_databricks_workspace" "workspace" {
  count               = var.deploy_databricks ? 1:0
  name                = local.databricks_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  sku                 = "premium"


  public_network_access_enabled = (var.is_vnet_isolated == false)
  network_security_group_rules_required = var.is_vnet_isolated ? "NoAzureDatabricksRules" : null
  
  dynamic "custom_parameters" {
    for_each = var.is_vnet_isolated ? [1] : []
    content {
        no_public_ip        = true
        public_subnet_name  = local.databricks_host_subnet_name
        private_subnet_name = local.databricks_container_subnet_name
        virtual_network_id  = local.vnet_id

        public_subnet_network_security_group_association_id  = local.databricks_host_nsg_association
        private_subnet_network_security_group_association_id = local.databricks_host_nsg_association
    }
  }
}


resource "azurerm_private_endpoint" "databricks_pe" {
  count               = var.deploy_adls && var.deploy_databricks && var.is_vnet_isolated ? 1 : 0
  name                = "${local.databricks_workspace_name}-workspace-plink"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  subnet_id           = local.plink_subnet_id
  
  private_dns_zone_group {
    name = "privatednszonegroupworkspace"
    private_dns_zone_ids = [local.private_dns_zone_databricks_workspace_id]
  }

  private_service_connection {
    name                           = "${local.databricks_workspace_name}-workspace-plink-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_databricks_workspace.workspace[0].id
    subresource_names              = ["databricks_ui_api"]
  }
}

resource "azurerm_private_endpoint" "databricks_auth_pe" {
  count               = var.deploy_adls && var.deploy_databricks && var.is_vnet_isolated ? 1 : 0
  name                = "${local.databricks_workspace_name}-auth-plink"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  subnet_id           = local.plink_subnet_id
  
  private_dns_zone_group {
    name = "privatednszonegroupworkspace"
    private_dns_zone_ids = [local.private_dns_zone_databricks_workspace_id]
  }

  private_service_connection {
    name                           = "${local.databricks_workspace_name}-auth-plink-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_databricks_workspace.workspace[0].id
    subresource_names              = ["browser_authentication"]
  }
}
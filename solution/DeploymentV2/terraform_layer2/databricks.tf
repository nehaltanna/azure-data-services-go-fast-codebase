resource "azurerm_databricks_workspace" "workspace" {
  count               = var.deploy_databricks ? 1:0
  name                = local.databricks_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  sku                 = "premium"


  public_network_access_enabled = true
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

resource "azurerm_role_assignment" "databricks_data_factory" {
  count                = var.deploy_databricks && var.deploy_data_factory ? 1 : 0
  scope                = azurerm_databricks_workspace.workspace[0].id
  role_definition_name = "Contributor"
  principal_id         = azurerm_data_factory.data_factory[0].identity[0].principal_id
}

/*
 resource "databricks_repo" "ads_repo" {
  count      = var.deploy_databricks ? 1 : 0
  provider  = databricks.created_workspace
  url       = "https://github.com/microsoft/azure-data-services-go-fast-codebase.git"
  path      = "/Repos/shared/azure-data-services-go-fast-codebase"
} 
*/

resource "databricks_workspace_conf" "this" {
  count    = var.deploy_databricks ? 1 : 0
  provider = databricks.created_workspace
  custom_config = {
    "enableIpAccessLists" : true
  }
  depends_on = [databricks_ip_access_list.allowed-list]
}

resource "databricks_ip_access_list" "allowed-list" {
  count     = var.deploy_databricks ? 1 : 0
  provider = databricks.created_workspace
  label     = "allow_in"
  list_type = "ALLOW"
  ip_addresses = [
    var.ip_address, 
    var.ip_address2
  ]
}



provider "databricks" {
  host = var.deploy_databricks ? azurerm_databricks_workspace.workspace[0].workspace_url : ""
}

resource "databricks_instance_pool" "smallest_nodes" {
  count              = var.deploy_databricks ? 1 : 0
  instance_pool_name = "Job Pool One"
  min_idle_instances = 0
  max_capacity       = 6
  node_type_id       = "Standard_E4ds_v5"
  azure_attributes {
    availability           = "ON_DEMAND_AZURE"
  }
  idle_instance_autotermination_minutes = 15
  disk_spec {
    disk_type {
      azure_disk_volume_type  = "STANDARD_LRS"
    }
    disk_size  = 10
    disk_count = 1
  }
  depends_on = [azurerm_databricks_workspace.workspace]
}


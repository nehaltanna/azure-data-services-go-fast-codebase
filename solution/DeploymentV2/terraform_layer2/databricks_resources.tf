locals {
  databricks_instance_pool_id = var.deploy_databricks && var.deploy_databricks_resources ? databricks_instance_pool.default_node[0].id : ""
  databricks_whitelist_list = var.deploy_databricks && var.deploy_databricks_resources && var.databricks_whitelist ? concat(compact([var.ip_address, var.ip_address2]),compact(var.databricks_ip_whitelist)) : []
}

resource "databricks_workspace_conf" "workspace_config" {
  count    = var.deploy_databricks && var.deploy_databricks_resources && var.databricks_whitelist ? 1 : 0
  provider = databricks.created_workspace
  custom_config = {
    "enableIpAccessLists" : true
  }
  depends_on = [databricks_ip_access_list.allowed_list]
}



resource "databricks_ip_access_list" "allowed_list" {
  count     = var.deploy_databricks && var.deploy_databricks_resources && var.databricks_whitelist ? 1 : 0
  provider = databricks.created_workspace
  label     = "allow_in"
  list_type = "ALLOW"
  ip_addresses = local.databricks_whitelist_list
  depends_on = [
    databricks_instance_pool.default_node,
    azurerm_databricks_workspace.workspace,
    time_sleep.databricks_post_deployment
  ]

}




provider "databricks" {
  host = var.deploy_databricks ? azurerm_databricks_workspace.workspace[0].workspace_url : ""
}


resource "databricks_instance_pool" "default_node" {
  count              = var.deploy_databricks && var.deploy_databricks_resources ? 1 : 0
  provider           = databricks.created_workspace
  instance_pool_name = var.databricks_instance_pool_name 
  min_idle_instances = var.databricks_instance_pool_min_idle_instances
  max_capacity       = var.databricks_instance_pool_max_capacity
  node_type_id       = var.databricks_instance_pool_size
  azure_attributes {
    availability           = "ON_DEMAND_AZURE"
  }
  idle_instance_autotermination_minutes = 10
  disk_spec {
    disk_type {
      azure_disk_volume_type  = "STANDARD_LRS"
    }
    disk_size  = 10
    disk_count = 1
  }
  depends_on = [
    azurerm_databricks_workspace.workspace,
    time_sleep.databricks_post_deployment
    ]
}

//DB access connector to allow link up to storage accounts etc
//requires datalake blob contributor

resource "azurerm_databricks_access_connector" "databricks_connector" {
  count              = var.deploy_databricks && var.deploy_adls && var.deploy_databricks_resources ? 1 : 0
  name                = local.databricks_connector_name
  resource_group_name = var.resource_group_name
  location            = var.resource_location

  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_databricks_workspace.workspace    
  ]
}

//group creation may be commented out -> leave databricks_admins list empty to not deploy any of the group related resources
resource "databricks_group" "databricks_admin_group" {
    count = var.deploy_databricks && var.deploy_databricks_resources && length(var.databricks_admins) > 0 ? 1 : 0
    provider = databricks.created_workspace
    display_name = var.databricks_admin_group_name
    allow_cluster_create = true
    allow_instance_pool_create = true
    databricks_sql_access = true
    workspace_access = true
    depends_on = [
        time_sleep.databricks_post_deployment  
    ]
}

resource "databricks_user" "databricks_admin_group_users" {
    count = var.deploy_databricks && var.deploy_databricks_resources && length(var.databricks_admins) > 0 ? length(var.databricks_admins) : 0
    provider = databricks.created_workspace
    user_name = var.databricks_admins[count.index]
    depends_on = [
        time_sleep.databricks_post_deployment 
    ]
}

resource "databricks_group_member" "databricks_admin_group_add_users" {
    count = var.deploy_databricks && var.deploy_databricks_resources && length(var.databricks_admins) > 0 ? length(var.databricks_admins) : 0
    provider = databricks.created_workspace
    group_id = databricks_group.databricks_admin_group[0].id    
    member_id = databricks_user.databricks_admin_group_users[count.index].id
    depends_on = [
        databricks_group.databricks_admin_group,
        databricks_user.databricks_admin_group_users    
    ]
}



/*

//requires metastore (not yet implemented)



resource "databricks_storage_credential" "datalake_mi" {
  count              = var.deploy_databricks && var.deploy_adls && var.deploy_databricks_resources ? 1 : 0
  name = "mi_credential-${local.adls_storage_account_name}"
  provider = databricks.created_workspace
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.databricks_connector[0].id
  }
  comment = "Managed identity credential managed by ADSGoFast TF"
  depends_on = [
    time_sleep.databricks_post_deployment,
    azurerm_databricks_access_connector.databricks_connector,
    azurerm_role_assignment.adls_databricks_access_connector
  ]
}

*/
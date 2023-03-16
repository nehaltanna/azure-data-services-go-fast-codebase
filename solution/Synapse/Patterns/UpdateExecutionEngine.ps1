Import-Module ./GatherOutputsFromTerraform_SynapseFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_SynapseFolder

$sqlserver_name=$tout.sqlserver_name
$metadatadb_name=$tout.metadatadb_name
$synapse_workspace_endpoint = "https://" + $tout.synapse_workspace_name + ".dev.azuresynapse.net"
$delta_processing_notebook = "DeltaProcessingNotebook"
$purview_account_name = $tout.purview_name
$synapse_spark_pool_name = $tout.synapse_spark_pool_name
$databricks_workspace_url = "https://" + $tout.databricks_workspace_url
$databricks_workspace_id = $tout.databricks_workspace_id
$databricks_default_instance_pool_id = $tout.databricks_instance_pool_id

#$execution_engine_json = '{"endpoint": "' + $synapse_workspace_endpoint + '", "DeltaProcessingNotebook": "' + $delta_processing_notebook + '", "PurviewAccountName": "' + $purview_account_name + '", "DefaultSparkPoolName": "' + $synapse_spark_pool_name + '"}'
$execution_engine_json = @"
{
    "endpoint": "$($synapse_workspace_endpoint)",
    "DeltaProcessingNotebook": "$($delta_processing_notebook)",
    "PurviewAccountName": "$($purview_account_name)",
    "DefaultSparkPoolName": "$($synapse_spark_pool_name)",
    "DatabricksWorkspaceURL": "$($databricks_workspace_url)",
    "DatabricksWorkspaceResourceID": "$($databricks_workspace_id)",
    "DefaultInstancePoolID": "$($databricks_default_instance_pool_id)"
}
"@
$SqlInstalled = Get-InstalledModule SqlServer
if($null -eq $SqlInstalled)
{
    Write-Verbose "Installing SqlServer Module"
    Install-Module -Name SqlServer -Scope CurrentUser -Force
}
#assuming synapse engine id = -2
$sql += @"
    BEGIN    
    UPDATE [dbo].[ExecutionEngine]
    SET EngineJson = '$($execution_engine_json)'
    WHERE EngineId = -2
    END 
"@

#----------------------------------------------------------------------------------------------------------------
#   Upload
#----------------------------------------------------------------------------------------------------------------
  
    Write-Verbose "_____________________________"
    Write-Verbose "Updating ADF Execution Engine Json: " 
    Write-Verbose "_____________________________"
    $token=$(az account get-access-token --resource=https://database.windows.net --query accessToken --output tsv)
    Invoke-Sqlcmd -ServerInstance "$sqlserver_name.database.windows.net,1433" -Database $metadatadb_name -AccessToken $token -query $sql   



Import-Module ./GatherOutputsFromTerraform_DataFactoryFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_DataFactoryFolder

$sqlserver_name=$tout.sqlserver_name
$metadatadb_name=$tout.metadatadb_name
$databricks_workspace_url = "https://" + $tout.databricks_workspace_url
$databricks_workspace_id = $tout.databricks_workspace_id
$databricks_default_instance_pool_id = $tout.databricks_instance_pool_id
$execution_engine_json = @"
{
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
#assuming adf engine id = -1
$sql += @"
    BEGIN    
    UPDATE [dbo].[ExecutionEngine]
    SET EngineJson = '$($execution_engine_json)'
    WHERE EngineId = -1
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


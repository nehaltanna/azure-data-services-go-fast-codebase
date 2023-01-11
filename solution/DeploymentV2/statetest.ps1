$oldstate = terraform state pull | ConvertFrom-Json
$base = @'
{
  "version": 4,
  "terraform_version": "1.2.2",
  "serial": 24,
  "lineage": "1b2bdcbb-d0e8-faf4-f976-81c04640eca8",
  "outputs": { 

  },
  "resources": [

  ]

}
'@

$base = $base | ConvertFrom-Json

$state1 = $base
$outputslist = @(
    "aad_funcreg_id", 
    "aad_webreg_id",
    "azuread_application_function_app_reg_object_id", 
    "azuread_service_principal_function_app_object_id", 
    "functionapp_name", 
    "naming_unique_seed",
    "naming_unique_suffix", 
    "purview_name", 
    "purview_sp_id",
    "purview_sp_name", 
    "purview_sp_object_id",
    "random_uuid_function_app_reg_role_id", 
    "resource_group_name", 
    "tenant_id",
    "webapp_name")

$resourceslist = @(
    "current", 
    "function_app_reg",
    "web_reg", 
    "function_app", 
    "web_sp", 
    "rg_deployment_unique",
    "app_reg_role_id", 
    "app_reg_role_id2", 
    "function_app_reg_role_id",
    "first_letter", 
    "main")

foreach($item in $outputslist)
{
    $state1.outputs | Add-Member -MemberType NoteProperty -Name $item -Value $oldstate.outputs.$item
}

$count = 0
foreach($item in $resourceslist)
{
    $state1.resources += $oldstate.resources | ? {$_.name -eq $item}
    $count++
}
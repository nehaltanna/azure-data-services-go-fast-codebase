
<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
This script is for deploying the customisable Terraform layer. It takes in three parameters: $deploymentFolderPath, $skipCustomTerraform, and $skipTerraformDeployment. $deploymentFolderPath is a string and is mandatory. $skipCustomTerraform and $skipTerraformDeployment are booleans and also mandatory.
The script changes the current location to $deploymentFolderPath and then to ./terraform_custom. If $skipCustomTerraform is set to true, the script skips the custom Terraform deployment. 
If it's false, it runs the terragrunt init command to initialize the Terraform deployment using the configuration file found in vars/$env:environmentName/terragrunt.hcl.
If $skipTerraformDeployment is true, the script skips running the terragrunt apply command to deploy the Terraform changes. 
If it's false, the script runs the terragrunt apply -auto-approve command to apply the Terraform changes with the -auto-approve flag, which automatically approves any prompts for confirmation.
Finally it sets the $deploymentFolderPath variable to current working directory.

#>

param (
    [Parameter(Mandatory=$true)]
    [String]$deploymentFolderPath,
    [Parameter(Mandatory=$true)]
    [bool]$skipCustomTerraform=$true,
    [Parameter(Mandatory=$true)]
    [bool]$skipTerraformDeployment=$true
)

#------------------------------------------------------------------------------------------------------------
# Deploy the customisable terraform layer
#------------------------------------------------------------------------------------------------------------
if ($skipCustomTerraform) {
    Write-Host "Skipping Custom Terraform Layer"    
}
else {
    Set-Location $deploymentFolderPath
    Set-Location "./terraform_custom"

    terragrunt init --terragrunt-config vars/$env:environmentName/terragrunt.hcl -reconfigure

    if ($skipTerraformDeployment) {
        Write-Host "Skipping Custom Terraform Deployment"
    }
    else {
        Write-Host "Starting Custom Terraform Deployment"
        terragrunt apply -auto-approve --terragrunt-config vars/$env:environmentName/terragrunt.hcl
    }
}
#------------------------------------------------------------------------------------------------------------
$deploymentFolderPath = (Get-Location).Pat
h
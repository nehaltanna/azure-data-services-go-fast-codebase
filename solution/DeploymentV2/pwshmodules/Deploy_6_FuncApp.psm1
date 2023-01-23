
<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
This function is responsible for deploying a function app to Azure using the Azure CLI. It takes in three parameters:

- tout (Mandatory): A pscustomobject that contains information about the deployment, such as the resource group name and function app name.
- deploymentFolderPath (Mandatory): The path to the deployment folder.
- PathToReturnTo (Mandatory): The path to return to after the deployment is complete.

The function first checks if the deployment of the function app should be skipped by checking if the publish_function_app and deploy_function_app properties of the tout object are set to true.
If the deployment should not be skipped, the function proceeds to build and deploy the function app by:

- Changing the current working directory to the function app folder.
- Running dotnet restore and dotnet publish commands to build the function app.
- Zipping the function app files to prepare for deployment.
- Deploying the function app using the az functionapp deployment source config-zip command and passing in the path to the zipped files and the resource group and function app name from the tout object.
- Setting the .NET framework version to v6.0 and the extension version to ~4 using the az functionapp config commands.
- Changing the current working directory back to the original path.

#>


function DeployFuncApp (
    [Parameter(Mandatory=$true)]
    [pscustomobject]$tout=$false,
    [Parameter(Mandatory=$true)]
    [string]$deploymentFolderPath="",
    [Parameter(Mandatory=$true)]
    [String]$PathToReturnTo=""
)
{
    #----------------------------------------------------------------------------------------------------------------
    #   Building & Deploy Function App
    #----------------------------------------------------------------------------------------------------------------
    $skipFunctionApp = if($tout.publish_function_app -and $tout.deploy_function_app) {$false} else {$true}
    if ($skipFunctionApp) {
        Write-Host "Skipping Building & Deploying Function Application"    
    }
    else {
        Write-Host "Building & Deploying Function Application"
        Set-Location $deploymentFolderPath
        Set-Location "..\FunctionApp\FunctionApp"
        dotnet restore
        dotnet publish --no-restore --configuration Release --output '..\..\DeploymentV2\bin\publish\unzipped\functionapp\'
        
        Set-Location $deploymentFolderPath
        Set-Location "./bin/publish"
        $Path = (Get-Location).Path + "/zipped/functionapp" 
        New-Item -ItemType Directory -Force -Path $Path
        $Path = $Path + "/Publish.zip"
        Compress-Archive -Path '.\unzipped\functionapp\*' -DestinationPath $Path -force
        
        $result = az functionapp deployment source config-zip --resource-group $tout.resource_group_name --name $tout.functionapp_name --src $Path --only-show-errors

        #Make sure we are running V6.0 --TODO: Move this to terraform if possible -- This is now done!
        $result = az functionapp config set --net-framework-version v6.0 -n $tout.functionapp_name -g $tout.resource_group_name --only-show-errors
        $result = az functionapp config appsettings set --name $tout.functionapp_name --resource-group $tout.resource_group_name --settings FUNCTIONS_EXTENSION_VERSION=~4 --only-show-errors

        Set-Location $deploymentFolderPath

        if([string]::IsNullOrEmpty($PathToReturnTo) -ne $true)
        {
            Write-Debug "Returning to $PathToReturnTo"
            Set-Location $PathToReturnTo
        }
        else {
            Write-Debug "Path to return to is null"
        }
    }
}

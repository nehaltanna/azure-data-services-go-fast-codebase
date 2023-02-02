
<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
This script is for deploying a web application. It takes in three parameters:

- $tout: A mandatory pscustomobject that contains properties used in the script.
- $deploymentFolderPath: A mandatory string that specifies the path to the deployment folder.
- $PathToReturnTo: A mandatory string that specifies the path to return to after the script finishes executing.

It first checks if the publish_web_app and deploy_web_app properties of $tout are set to true. If that's the case, it proceeds to build and deploy the web application.
It does this by first moving to the web application folder, running dotnet restore and dotnet publish commands to build the application. Then it moves to the deployment folder, creates a new directory and zips the built application.
Finally, it uses the Azure CLI command az webapp deployment source config-zip to deploy the zipped application to the web app specified in $tout and returns to the path specified in $PathToReturnTo.

#>

function DeployWebApp (
    [Parameter(Mandatory=$true)]
    [pscustomobject]$tout=$false,
    [Parameter(Mandatory=$true)]
    [string]$deploymentFolderPath="",
    [Parameter(Mandatory=$true)]
    [String]$PathToReturnTo=""
)
{
    #----------------------------------------------------------------------------------------------------------------
    #   Building & Deploy Web App
    #----------------------------------------------------------------------------------------------------------------
    $skipWebApp = if($tout.publish_web_app -and $tout.deploy_web_app) {$false} else {$true}
    if ($skipWebApp) {
        Write-Host "Skipping Building & Deploying Web Application"    
    }
    else {
        Write-Host "Building & Deploying Web Application"
        #Move From Workflows to Function App
        Set-Location $deploymentFolderPath
        Set-Location "../WebApplication"
        dotnet restore
        dotnet publish --no-restore --configuration Release --output '..\DeploymentV2\bin\publish\unzipped\webapplication\'
        #Move back to workflows 
        Set-Location $deploymentFolderPath
        Set-Location "./bin/publish"
        $Path = (Get-Location).Path + "/zipped/webapplication" 
        New-Item -ItemType Directory -Force -Path $Path
        $Path = $Path + "/Publish.zip"
        Compress-Archive -Path '.\unzipped\webapplication\*' -DestinationPath $Path -force

        $result = az webapp deployment source config-zip --resource-group $tout.resource_group_name --name $tout.webapp_name --src $Path  --only-show-errors  

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
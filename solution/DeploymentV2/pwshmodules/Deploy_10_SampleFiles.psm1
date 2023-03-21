<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
This script is for deploying sample files. It uses the Azure PowerShell module to interact with Azure Storage. 
The script takes in three parameters: $tout, $deploymentFolderPath, and $PathToReturnTo. $tout is a pscustomobject and is mandatory. 
$deploymentFolderPath and $PathToReturnTo are strings and are also mandatory. 
The script first checks if the publish_sample_files property of $tout is true or false. 
If it's false, the script skips deploying sample files. If it's true, the script changes the current location to the $deploymentFolderPath, then to the ../SampleFiles/ directory. 
It then creates containers in Azure Storage, and uploads files from the current directory to the containers. If $tout.is_vnet_isolated is true, it updates the storage account to allow access. 
Finally, it changes the current location back to $deploymentFolderPath or $PathToReturnTo if it's not null.
#>


function DeploySampleFiles (    
    [Parameter(Mandatory = $true)]
    [pscustomobject]$tout = $false,
    [Parameter(Mandatory = $true)]
    [string]$deploymentFolderPath = "",
    [Parameter(Mandatory = $true)]
    [String]$PathToReturnTo = ""
) {
    #----------------------------------------------------------------------------------------------------------------
    #   Deploy Sample Files
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    $skipSampleFiles = if ($tout.publish_sample_files) { $false } else { $true }
    if ($skipSampleFiles) {
        Write-Host "Skipping Sample Files"    
    }
    else {
        Set-Location $deploymentFolderPath
        Set-Location "../SampleFiles/"
        Write-Host "Deploying Sample files"
        if ($tout.is_vnet_isolated -eq $true) {
            $result = az storage account update --resource-group $tout.resource_group_name --name $tout.adlsstorage_name --default-action Allow --only-show-errors
        }

        $result = az storage container create --name "datalakelanding" --account-name $tout.adlsstorage_name --auth-mode login --only-show-errors
        $result = az storage container create --name "datalakeraw" --account-name $tout.adlsstorage_name --auth-mode login --only-show-errors
        $result = az storage container create --name "datalakeraw" --account-name $tout.blobstorage_name --auth-mode login --only-show-errors
        $result = az storage container create --name "transientin" --account-name $tout.blobstorage_name --auth-mode login --only-show-errors

        $result = az storage blob upload-batch --overwrite --destination "datalakeraw" --account-name $tout.adlsstorage_name --source ./ --destination-path samples/ --auth-mode login --only-show-errors
        $result = az storage blob upload-batch --overwrite --destination "datalakeraw" --account-name $tout.blobstorage_name --source ./ --destination-path samples/ --auth-mode login --only-show-errors

        if ($tout.is_vnet_isolated -eq $true) {
            $result = az storage account update --resource-group $tout.resource_group_name --name $tout.adlsstorage_name --default-action Deny --only-show-errors
        }

        Set-Location $deploymentFolderPath

        if ([string]::IsNullOrEmpty($PathToReturnTo) -ne $true) {
            Write-Debug "Returning to $PathToReturnTo"
            Set-Location $PathToReturnTo
        }
        else {
            Write-Debug "Path to return to is null"
        }

    }
}
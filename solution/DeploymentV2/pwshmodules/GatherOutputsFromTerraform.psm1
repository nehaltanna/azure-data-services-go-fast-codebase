<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
This is a PowerShell function that gathers outputs from Terraform and converts them into a PowerShell object. 
It takes one input, the path to the Terraform folder, and returns the output as a PowerShell object. 
The function first sets the current location to the Terraform folder path, then reads the outputs from Terraform in JSON format, converts them to a PowerShell object, and assigns the properties of the object to the output object. 
It then gets the resource group id from Azure and adds it to the output object. Finally, it returns the output object and sets the location back to the original location.
#>


function GatherOutputsFromTerraform($TerraformFolderPath)
{

    $currentPath = (Get-Location).Path 
    Set-Location $TerraformFolderPath 
    $environmentName = $env:TFenvironmentName
    #$environmentName = "local" # currently supports (local, staging)
    $myIp = (Invoke-WebRequest ifconfig.me/ip).Content

    #$CurrentFolderPath = $PWD
    $env:TF_VAR_ip_address = $myIp

    #------------------------------------------------------------------------------------------------------------
    # Get all the outputs from terraform so we can use them in subsequent steps
    #------------------------------------------------------------------------------------------------------------
    Write-Debug "-------------------------------------------------------------------------------------------------"
    Write-Debug "Reading Terraform Outputs - Started"

    $tout = New-Object PSObject

    $tout0 = (terraform output -json | ConvertFrom-Json -Depth 10).PSObject.Properties 
    $tout0 | Foreach-Object {                    
        $tout | Add-Member  -MemberType NoteProperty -Name $_.Name -Value $_.Value.value
    }

    $rgid = (az group show -n $tout.resource_group_name | ConvertFrom-Json -Depth 10).id
    $tout | Add-Member  -MemberType NoteProperty -Name "resource_group_id" -Value $rgid

    #Set-Location $CurrentFolderPath
    Write-Debug "Reading Terraform Outputs - Finished"
    Write-Debug "-------------------------------------------------------------------------------------------------"
    Set-Location $currentPath
    return $tout
}
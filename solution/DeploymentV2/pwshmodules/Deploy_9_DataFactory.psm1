<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
Function to deploy the Data Factory and Synapse artefacts to Azure Data Factory. 
This is a PowerShell function that deploys Data Factory pipelines and Synapse artifacts. 
The function takes three mandatory parameters: a "tout" object, a string for the deployment folder path, and a string for the path to return to after the deployment. 
The function first checks if the deployment of Data Factory pipelines is to be skipped. If it is not to be skipped, the function adds an Azure extension for data factory, sets the location to the deployment folder path, and adds IP addresses to the SQL firewall. 
The function then checks if the SqlServer module is installed and installs it if it is not. 
The function then imports a module for generating and uploading ADF pipelines, calls the GenerateAndUploadDataFactoryAndSynapseArtefacts function, and returns to the original location if specified.
#>

function DeployDataFactoryAndSynapseArtefacts (    
    [Parameter(Mandatory = $true)]
    [pscustomobject]$tout = $false,
    [Parameter(Mandatory = $true)]
    [string]$deploymentFolderPath = "",
    [Parameter(Mandatory = $true)]
    [String]$PathToReturnTo = ""
) {
    #----------------------------------------------------------------------------------------------------------------
    #   Deploy Data Factory Pipelines
    #----------------------------------------------------------------------------------------------------------------
    if ($skipDataFactoryPipelines) {
        Write-Host "Skipping DataFactory Pipelines"    
    }
    else {
        #needed for git integration
        az extension add --upgrade --name datafactory
        
        Set-Location $deploymentFolderPath    
        #Add Ip to SQL Firewall
        $myIp = $env:TF_VAR_ip_address
        $myIp2 = $env:TF_VAR_ip_address2
    
        if ($myIp -ne $null) {
            $result = az sql server firewall-rule create -g $tout.resource_group_name -s $tout.sqlserver_name -n "CICDAgent" --start-ip-address $myIp --end-ip-address $myIp --only-show-errors
        }
        if ($myIp2 -ne $null) {        
            $result = az sql server firewall-rule create -g $tout.resource_group_name -s $tout.sqlserver_name -n "CICDUser" --start-ip-address $myIp2 --end-ip-address $myIp2 --only-show-errors
        }
    
        $SqlInstalled = Get-InstalledModule SqlServer
        if ($null -eq $SqlInstalled) {
            write-host "Installing SqlServer Module"
            Install-Module -Name SqlServer -Scope CurrentUser -Force
        }

        Import-Module ./pwshmodules/GenerateAndUploadADFPipelines.psm1 -force
        GenerateAndUploadDataFactoryAndSynapseArtefacts -tout $tout  -deploymentFolderPath $deploymentFolderPath -PathToReturnTo $PathToReturnTo          

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
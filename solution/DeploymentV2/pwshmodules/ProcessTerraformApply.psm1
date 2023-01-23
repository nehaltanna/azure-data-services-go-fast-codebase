<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
This script is a PowerShell function named "ProcessTerraformApply". It takes two parameters: a boolean value for "gitDeploy" and an object for "output".

The function starts by initializing an empty array named "output_validated". 
It then loops through each element in the "output" object and checks if the element is a JSON object by checking if it starts with '{'. If it is a JSON object, it adds it to the "output_validated" array. If it is not a JSON object, it writes the element as a warning.

After the loop, the function assigns the "output_validated" array to the "output" variable. 
Then, it uses the ConvertFrom-Json cmdlet to convert the "output" variable to a JSON object and filters the object for warnings and errors.

If there are any warnings, it writes each warning message with its address and detail as a warning. 
If there are any errors, it writes each error message with its address and detail as an error.

#>

function ProcessTerraformApply (
    [Parameter(Mandatory = $true)]
    [System.Boolean]$gitDeploy = $false,
    [Parameter(Mandatory = $true)]
    [System.Object]$output
) {
    $output_validated = @()
    
    Write-Host "---------------------Terraform Non-Json Outputs-----------------------------------------------------------"
    foreach ($o in $output) 
    {
        $test = $o.ToString().StartsWith('{')
        if ($test) 
        {
            $output_validated += $o
        }
        else 
        {
            Write-Warning $o
        }
    }

    $output = $output_validated

    $warnings = ($output | ConvertFrom-Json -Depth 20) | Where-Object {$_."@level" -eq "warn"}              
    $errors = ($output | ConvertFrom-Json -Depth 20) | Where-Object {$_."@level" -eq "error"}              
    if($warnings.count -gt 0)
    {
        Write-Host "---------------------Terraform Warnings-----------------------------------------------------------"
        foreach($o in $warnings) {Write-Warning ($o."@message" + "; Address:" + $o.diagnostic.address + "; Detail:" + $o.diagnostic.detail)}
        Write-Host "--------------------------------------------------------------------------------------------------"
    }
    if($errors.count -gt 0)
    {
        Write-Host "---------------------Terraform Errors-------------------------------------------------------------"
        foreach($o in $errors) {Write-Error ($o."@message" + "; Address:" + $o.diagnostic.address + "; Detail:" + $o.diagnostic.detail)}
        Write-Host "--------------------------------------------------------------------------------------------------"
    }

}


# 
#
# $pout =  terragrunt plan --terragrunt-config vars/$env:environmentName/terragrunt.hcl -json
# (($pout | ConvertFrom-Json -Depth 20) | Where-Object {$_.type -eq "change_summary"})
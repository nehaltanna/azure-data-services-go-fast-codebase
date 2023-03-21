<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *

This script is a PowerShell script that generates and uploads the end to end functional tests for the ADS Go Fast Framework. 
The script performs the following steps: 

- It sets the current directory to the "DataFactory/Patterns" directory, and then runs four scripts in that directory: EnvVarsToFile.ps1, FuncAppTests_Generate.ps1, SqlTests_Generate.ps1, and SqlTests_Upload.ps1.
- After that, it sets the current directory to the "Synapse/Patterns" directory, and then runs the same four scripts in that directory. 
- Finally, it sets the current directory back to the original directory before the script was run.

The script is running four separate scripts for datafactory and synapse patterns. The script is running the same set of four scripts in the two different folders.
It is generating test tasks and uploading them to the Metadata Database. 

#>



$CurrDir = $PWD
Write-Host "Starting ADF Patterns" -ForegroundColor Yellow
Set-Location ../DataFactory/Patterns/
Invoke-Expression  ./EnvVarsToFile.ps1
Invoke-Expression  ./FuncAppTests_Generate.ps1
Invoke-Expression  ./SqlTests_Generate.ps1
Invoke-Expression  ./SqlTests_Upload.ps1
#Below is temporary - we want to make a parent folder for the both of these directories in the future.
#Currently there are duplicate powershell scripts. Plan is to iterate through each subfolder (datafactory / synapse) with one script
Write-Host "Starting Synapse Patterns" -ForegroundColor Yellow
Set-Location ../../Synapse/Patterns/
Invoke-Expression  ./EnvVarsToFile.ps1
Invoke-Expression  ./FuncAppTests_Generate.ps1
Invoke-Expression  ./SqlTests_Generate.ps1
Invoke-Expression  ./SqlTests_Upload.ps1
Set-Location $CurrDir
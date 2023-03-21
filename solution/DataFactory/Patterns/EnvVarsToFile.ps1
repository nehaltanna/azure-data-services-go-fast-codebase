
<# 
* Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
The first line of the provided script is using the Write-Host cmdlet to display the current working directory's path.
The second line is importing a PowerShell module named "GatherOutputsFromTerraform_DataFactoryFolder.psm1" that is located in the current working directory. The -Force parameter is used to ensure the module is imported even if it is already imported.
The third line is running the GatherOutputsFromTerraform_DataFactoryFolder command from the imported module and storing the output in a variable named $tout.
The fourth line is converting the output stored in $tout to JSON format, with a depth of 10 and then it is writing the output to a file named "secrets.libsonnet" in "./pipeline/static/partials" directory.

This script is used to gather outputs from a Terraform configuration and convert them to a JSON format that can then be used in downstream processes such as Jsonnet template generation activities.
#>


Write-Host $PWD.Path
Import-Module ./GatherOutputsFromTerraform_DataFactoryFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_DataFactoryFolder
$tout | ConvertTo-Json -Depth 10| Set-Content "./pipeline/static/partials/secrets.libsonnet"
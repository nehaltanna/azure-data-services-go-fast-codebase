<#
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT license.

* General Description *
This script performs the following setps:

* Preparation Activities* 
    1. It gets the Terraform ouptut values using the module GatherOutputsFromTerraform_DataFactoryFolder and stores them in a variable called "$tout".
    2. It checks if a folder called "output" exists in the current directory and if not, it creates one.
    3. It then removes all the previous contents of the "output" folder using the "Get-ChildItem" and "Remove-item" commands.
    4. It converts "$tout" to JSON format and saves it to a file named "tout.json" in the "output" folder.
    5. It then copies all the files with the ".json" extension from the "./pipeline/static" folder to the "output" folder.
    
* Integration Runtime SQL Script Generation *   
    1. It converts the "integration_runtimes" property of "$tout" to JSON format and saves it to a variable "$irsjson".
    2. Then it creates a set of SQL commands which is used to merge the data from the JSON file into the IntegrationRuntime & Integration Runtime mappings tables in the Metadata database. This allows automatic updating of the the mapping between integration runtimes and valid source systems. 
    3. It saves the generated SQL Script to a file called "MergeIRs.sql" in the current directory.


* ADF Pipeline & Dataset Generation * 
    1. It reads a file called "Patterns.json" and converts its contents to a JSON object called "$patterns".
    2. It then iterates over each integration runtime in "$tout.integration_runtimes" and for each runtime, it checks whether the current runtime is an Azure runtime or a self-hosted runtime that is registered.
    3. If the runtime is an Azure runtime or a registered self-hosted runtime, the script then iterates over each pattern in "$patterns".
    4. For each pattern, it checks if the current pattern is valid for the current integration runtime by checking the "valid_pipeline_patterns" property of the current runtime.
    5. If the pattern is valid, it then gets all the files with the ".libsonnet" extension in the folder specified by the pattern's "Folder" property, and then renames the files using the "CoreReplacements" function, and converts the files to json using the jsonnet command. **Jsonnet is a domain specific configuration language and command-line tool for defining and manipulating JSON data. It is similar to JSON, but offers a number of advanced features such as variables, functions, and arithmetic operators that can be used to make JSON data more expressive and easier to maintain. Jsonnet allows you to write JSON data in a more structured and readable way, making it easier to create and update complex JSON configurations. The jsonnet command-line tool can be used to evaluate Jsonnet files and output the resulting JSON data.
    6. Finally, it saves the resulting JSON files to the "output" folder in the current directory.
    7. If the pattern is not valid for the current runtime, it will print a message "Pattern Suppressed on (Integration runtime name)"

* Schema File Generation and associated SQL Script Generation*
    This part of the script generates the schema files used by the farmework to validate tasks during processing and uses by the web front end to dispay the data entry forms for task configuration. 
    1. It creates an array of unique folder names used by the patterns in the "$patterns" variable.
    2. It then iterates over each folder name and gets all the patterns in that folder, and for each pattern it:
    3. It assigns values to the variables "SourceType", "SourceFormat", "TargetType", "TargetFormat", "TaskTypeId", and "pipeline" using the properties of the current pattern.
    4. It then creates a new folder called "output" and "schemas" and "taskmasterjson" inside the folder specified by the current pattern's "Folder" property, if they do not exist.
    5. It then gets all the files with the name "Main.libsonnet" in the "jsonschema" folder inside the folder specified by the current pattern's "Folder" property.
    6. It renames the file as the value of "pipeline" and appends ".json" to it, and then uses jsonnet command to convert the libsonnet file to json and saves it to the "taskmasterjson" folder.
    7. It also creates a SQL string that uses the JSON file in the taskmasterjson folder to update the metadata database with the schema information for the current pattern.

* Copy Generated files to Terraform folders *
    The script can deploy the generated files using Terraform, the Azure Datafactory API or using GIT to Azure Data Factory integeration. This next part of the script deals with the Terraform deployment option. If the top level variable "GenerateArm" (set at the very top of the script) is true then this part of the script willl 
    opying the output pipeline files that were generated earlier in the script to specific locations in a folder structure for a Terraform deployment. 
    It uses the Get-ChildItem cmdlet to filter the files in the "./output" folder by the name, which includes the string "GPL" for self-hosted pipelines, "GPL_Az" for azure-hosted pipelines and "SPL_Az" for static hosted pipelines. 
    The script then uses the Copy-Item cmdlet to copy the selected files to their respective locations in the "../../DeploymentV2\terraform\modules" folder structure. T
    he script also uses the Write-Verbose cmdlet to output the number of files copied to each location.

* Linked Service, Data Factory, Managed Virtual Networks &  Integration Runtime Generation *
    This part of the script is only executed if the "adf_git_toggle_integration" variable is set to true. This causes all Azure Data Factory code artefacts to be deployed using Git / ADF integration rather than via Terraform and the ADF Api. 
    Under the Git deployment option we need to generate additional files for the linked services, data factories and integration runtimes. Under the ADF Api deployment method these entities are deployed by terraform and hence not generated by this script.


* Related Scripts *
1. ./UploadGeneratedPatternsToADF.ps1
   This script is used to upload the generated patterns to Azure Data Factory using the ADF API. It is used when the "GenerateArm" variable is set to false. It is a downstream script of this script and usually called after this script has been run.
2. ./solution/DeploymentV2/pwshmodules/GenerateAndUploadADFPipelines.psm1
    This is the script that usually calls this script. It is the overarching script that is used to generate and upload the patterns to Azure Data Factory.

#>



Import-Module ./GatherOutputsFromTerraform_DataFactoryFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_DataFactoryFolder

$newfolder = "./output/"


#Generate Patterns.json
(jsonnet "./patterns.jsonnet") | Set-Content("./Patterns.json")

$GenerateArm="false"

<# 
    This function, called "CoreReplacements", takes in six parameters: a string, "GFPIR", "SourceType", "SourceFormat", "TargetType", and "TargetFormat". 
    The function first replaces certain patterns in the input string with the values of the parameters passed in. Then it checks the value of a variable "GenerateArm" and performs different replacements on the string based on whether "GenerateArm" is true or false. Finally, the modified string is returned. 
#>
function CoreReplacements ($string, $GFPIR, $SourceType, $SourceFormat, $TargetType, $TargetFormat) {
    $string = $string.Replace("@GFP{SourceType}", $SourceType).Replace("@GFP{SourceFormat}", $SourceFormat).Replace("@GFP{TargetType}", $TargetType).Replace("@GFP{TargetFormat}", $TargetFormat)

    if($GenerateArm -eq "false")
    {
        $string = $string.Replace("@GF{IR}", $GFPIR).Replace("{IR}", $GFPIR)
    }
    else 
    {
        $string = $string.Replace("_@GF{IR}", "").Replace("_{IR}", "")
    }

    return  $string
}




if (!(Test-Path "./output"))
{
    $fld = New-Item -itemType Directory -Name "output" 
}
else
{
    Write-Verbose "Output Folder already exists"
}

#Remove Previous Outputs
Get-ChildItem ./output | foreach {
    Remove-item $_ -force
}

#create tout json to be used for git integration
$toutjson = $tout | ConvertTo-Json -Depth 10 | Set-Content($newfolder + "tout.json")

#Copy Static Pipelines
$folder = "./pipeline/static"
$templates = (Get-ChildItem -Path $folder -Filter "*.json"  -Verbose)
foreach ($file in $templates)
{ 
    $content = Get-Content $file
    $outfile = ('./output/' + $File.Name)
    $content | Set-Content -Path $outfile 
}

$irsjson = ($tout.integration_runtimes | ConvertTo-Json -Depth 10)


$irsql = @"
            Merge dbo.IntegrationRuntime Tgt
            using (
            Select * from OPENJSON('$irsjson') WITH 
            (
                name varchar(200), 
                short_name varchar(20), 
                is_azure bit, 
                is_managed_vnet bit     
            )
            ) Src on Src.short_name = tgt.IntegrationRuntimeName 
            when NOT matched by TARGET then insert
            (IntegrationRuntimeName, EngineId, ActiveYN)
            VALUES (Src.short_name,1,1);


            drop table if exists #tempIntegrationRuntimeMapping 
            Select ir.IntegrationRuntimeId, a.short_name IntegrationRuntimeName, c.[value] SystemId
            into #tempIntegrationRuntimeMapping
            from 
            (
            Select IR.*, Patterns.[Value] from OPENJSON('$irsjson') A 
           CROSS APPLY OPENJSON(A.[value]) Patterns 
           CROSS APPLY OPENJSON(A.[value]) with (short_name varchar(max)) IR 
           where Patterns.[key] = 'valid_source_systems'
           ) A
           OUTER APPLY OPENJSON(A.[Value])  C
           join 
           dbo.IntegrationRuntime ir on ir.IntegrationRuntimeName = a.short_name 
           
           drop table if exists #tempIntegrationRuntimeMapping2
           Select * into #tempIntegrationRuntimeMapping2
           from 
           (
           select a.IntegrationRuntimeId, a.IntegrationRuntimeName, b.SystemId from #tempIntegrationRuntimeMapping  a
           cross join [dbo].[SourceAndTargetSystems] b 
           where a.SystemId = '*'
           union 
           select a.IntegrationRuntimeId, a.IntegrationRuntimeName, a.SystemId from #tempIntegrationRuntimeMapping  a
           where a.SystemId != '*'
           ) a
                    
           Merge dbo.IntegrationRuntimeMapping tgt
           using #tempIntegrationRuntimeMapping2 src on 
           tgt.IntegrationRuntimeName = src.IntegrationRuntimeName and tgt.SystemId = src.SystemId
           when not matched by target then 
           insert 
           ([IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN])
           values 
           (src.IntegrationRuntimeId, src.IntegrationRuntimeName, cast(src.SystemId as bigint), 1);            

           
"@            

$irsql | Set-Content "MergeIRs.sql"

#Copy IR Specific Pipelines
$patterns = (Get-Content "Patterns.json") | ConvertFrom-Json -Depth 10
foreach ($ir in $tout.integration_runtimes)
{    

    $GFPIR = $ir.short_name
    if (($ir.is_azure -eq $false) -and ($tout.is_onprem_datafactory_ir_registered -eq $false))
    {
        Write-Verbose "Skipping Self Hosted Runtime as it is not yet registered"
    }
    else
    {        
        foreach ($pattern in $patterns)
        {    
            $valid = $false
            foreach ($p2 in $ir.valid_pipeline_patterns)
            {
               #Write-Verbose ($p2) -BackgroundColor Yellow -ForegroundColor Black
                if($p2.Folder -eq $pattern.Folder -or $p2.Folder -eq "*")
                {
                    $valid = $true
                }
            }

            if($valid)
            {
                $folder = "./pipeline/" + $pattern.Folder
                $templates = (Get-ChildItem -Path $folder -Filter "*.libsonnet"  -Verbose)

                Write-Verbose "_____________________________"
                Write-Verbose $folder 
                Write-Verbose "_____________________________"

                foreach ($t in $templates) {        
                    #$GFPIR = $pattern.GFPIR
                    $SourceType = $pattern.SourceType
                    $SourceFormat = $pattern.SourceFormat
                    $TargetType = $pattern.TargetType
                    $TargetFormat = $pattern.TargetFormat

                    $newname = (CoreReplacements -string $t.PSChildName -GFPIR $GFPIR -SourceType $SourceType -SourceFormat $SourceFormat -TargetType $TargetType -TargetFormat $TargetFormat).Replace(".libsonnet",".json")        
                    Write-Verbose $newname        
                    (jsonnet --tla-str GenerateArm=$GenerateArm --tla-str GFPIR=$GFPIR --tla-str SourceType="$SourceType" --tla-str SourceFormat="$SourceFormat" --tla-str TargetType="$TargetType" --tla-str TargetFormat="$TargetFormat" $t.FullName) | Set-Content('./output/' + $newname)

                }
            }
            else 
            {
                Write-Verbose ("Pattern "+  $pattern.Folder + " Suppressed on " + $ir.name)  #-ForegroundColor Blue
            }


        }
    }
}

#foreach unique folder used by pattern.json
$patternFolders = $patterns.Folder | Get-Unique 
foreach ($patternFolder in $patternFolders)
 {   
    $patternsInFolder = ($patterns | where-object {$_.Folder -eq $patternFolder})
    #get all patterns for that folder and generate the schema files
    $patternsInFolder | ForEach-Object -Parallel {
        $pattern = $_
        $SourceType = $pattern.SourceType
        $SourceFormat = $pattern.SourceFormat
        $TargetType = $pattern.TargetType
        $TargetFormat = $pattern.TargetFormat

        $TaskTypeId = $pattern.TaskTypeId
        
        $folder = "./pipeline/" + $pattern.Folder
        Write-Verbose "_____________________________"
        Write-Verbose "Generating ADF Schema Files: " 
        Write-Verbose $folder 
        Write-Verbose "_____________________________"
        
        $newfolder = ($folder + "/output")
        $hiddenoutput = !(Test-Path $newfolder) ? ($F = New-Item -itemType Directory -Force -Name $newfolder) : ($F = "")
        $newfolder = ($newfolder + "/schemas")
        $hiddenoutput = !(Test-Path $newfolder) ? ($F = New-Item -itemType Directory -Force -Name $newfolder) : ($F = "")
        $newfolder = ($newfolder + "/taskmasterjson/")
        $hiddenoutput = !(Test-Path $newfolder) ? ($F = New-Item -itemType Directory -Force -Name $newfolder) : ($F = "")
        
        $schemafile = (Get-ChildItem -Path ($folder+"/jsonschema/") -Filter "Main.libsonnet")
        #foreach ($schemafile in $schemafiles)
        #{  
            $mappingName = $pattern.pipeline
            Write-Verbose $mappingName
            $newname = ($schemafile.PSChildName).Replace(".libsonnet",".json").Replace("Main", $MappingName);
            #(jsonnet $schemafile.FullName) | Set-Content('../../TaskTypeJson/' + $newname)
            $hiddenoutput = (jsonnet --tla-str SourceType="$SourceType" --tla-str SourceFormat="$SourceFormat" --tla-str TargetType="$TargetType" --tla-str TargetFormat="$TargetFormat" $schemafile) | Set-Content($newfolder + $newname)
            #(jsonnet $schemafile.FullName) | Set-Content($newfolder + $newname)
        #}
    }    
    
    $sql = @"
    BEGIN 
    Select * into #TempTTM from ( VALUES
"@
    $folder = "./pipeline/" + $patternFolder    
    foreach ($pattern in  $patternsInFolder)
    {  
        $pipeline = $pattern.Pipeline        
        $schemafile = $folder + "/output/schemas/taskmasterjson/"+ $pattern.Pipeline + ".json"
                
        #Write-Verbose "_____________________________"
        #Write-Verbose "Inserting into TempTTM: " 
        #Write-Verbose $pipeline
        #Write-Verbose "_____________________________"        
        $psplit = $pipeline.split("_")
        $SourceType = $pattern.SourceType
        $SourceFormat = $pattern.SourceFormat
        $TargetType = $pattern.TargetType
        $TargetFormat = $pattern.TargetFormat
        $TaskTypeId = $pattern.TaskTypeId

        #$SourceType = $psplit[1]
        $SourceType = ($SourceType -eq "AzureBlobStorage") ? "Azure Blob":$SourceType
        $SourceType = ($SourceType -eq "AzureBlobFS") ? "ADLS" : $SourceType
        $SourceType = ($SourceType -eq "AzureSqlTable") ? "Azure SQL" : $SourceType
        $SourceType = ($SourceType -eq "AzureSqlDWTable") ? "Azure Synapse" : $SourceType
        $SourceType = ($SourceType -eq "SqlServerTable") ? "SQL Server" : $SourceType
        $SourceType = ($SourceType -eq "OracleServerTable") ? "Oracle Server" : $SourceType
        
        #$SourceFormat = $psplit[2]
        $SourceFormat = ($SourceFormat -eq "DelimitedText") ? "Csv":$SourceFormat

        #$TargetType = $psplit[3]
        $TargetType = ($TargetType -eq "AzureBlobStorage") ? "Azure Blob":$TargetType
        $TargetType = ($TargetType -eq "AzureBlobFS") ? "ADLS" : $TargetType
        $TargetType = ($TargetType -eq "AzureSqlTable") ? "Azure SQL" : $TargetType
        $TargetType = ($TargetType -eq "AzureSqlDWTable") ? "Azure Synapse" : $TargetType
        $TargetType = ($TargetType -eq "SqlServerTable") ? "SQL Server" : $TargetType
        $TargetType = ($TargetType -eq "OracleServerTable") ? "Oracle Server" : $TargetType

        #$TargetFormat = $psplit[4]        
        $TargetFormat = ($TargetFormat -eq "DelimitedText") ? "Csv":$TargetFormat

        if ($TaskTypeId -eq -1)
        {
            $TargetFormat = "Table"
        }
        if ($TaskTypeId -eq -10) 
        {
            $MappingType = 'DLL'
        }
        else 
        {
            $MappingType = 'ADF'
        }
        $content = Get-Content $schemafile -raw
        $sql += "("
        $sql += "$TaskTypeId, N'$MappingType', N'$pipeline', N'$SourceType', N'$SourceFormat', N'$TargetType', N'$TargetFormat', NULL, 1,N'$content',N'{}'"
        $sql += "),"
    }
    if ($sql.endswith(","))
    {   $sql = $sql.Substring(0,$sql.Length-1) }
    $sql += @"
    ) a([TaskTypeId], [MappingType], [MappingName], [SourceSystemType], [SourceType], [TargetSystemType], [TargetType], [TaskTypeJson], [ActiveYN], [TaskMasterJsonSchema], [TaskInstanceJsonSchema])
    
    
    Update [dbo].[TaskTypeMapping]
    Set 
    MappingName = ttm2.MappingName,
    TaskMasterJsonSchema = ttm2.TaskMasterJsonSchema,
    TaskInstanceJsonSchema = ttm2.TaskInstanceJsonSchema
    from 
    [dbo].[TaskTypeMapping] ttm  
    inner join #TempTTM ttm2 on 
        ttm2.TaskTypeId = ttm.TaskTypeId 
        and ttm2.MappingType = ttm.MappingType
        and ttm2.SourceSystemType = ttm.SourceSystemType 
        and ttm2.SourceType = ttm.SourceType 
        and ttm2.TargetSystemType = ttm.TargetSystemType 
        and ttm2.TargetType = ttm.TargetType 

    Insert into 
    [dbo].[TaskTypeMapping]
    ([TaskTypeId], [MappingType], [MappingName], [SourceSystemType], [SourceType], [TargetSystemType], [TargetType], [TaskTypeJson], [ActiveYN], [TaskMasterJsonSchema], [TaskInstanceJsonSchema])
    Select ttm2.* 
    from [dbo].[TaskTypeMapping] ttm  
    right join #TempTTM ttm2 on 
        ttm2.TaskTypeId = ttm.TaskTypeId 
        and ttm2.MappingType = ttm.MappingType
        and ttm2.SourceSystemType = ttm.SourceSystemType 
        and ttm2.SourceType = ttm.SourceType 
        and ttm2.TargetSystemType = ttm.TargetSystemType 
        and ttm2.TargetType = ttm.TargetType 
    where ttm.TaskTypeMappingId is null

    END 
"@

    $hiddentoutput = $sql | Set-Content ($folder + "/output/schemas/taskmasterjson/TaskTypeMapping.sql")    
}

# This will copy the output pipeline files into the locations required for the terraform deployment
if($GenerateArm -eq "true") {
    $templates = Get-ChildItem -Path './output/*' -Exclude '*_Azure.json', '*_Azure.json' -Include "GPL*.json", "GPL_Sql*.json" -Name
    foreach($template in $templates) {
        Copy-Item -Path "./output/$template" -Destination "../../DeploymentV2\terraform\modules\data_factory_pipelines_selfhosted/arm/"  
    }
        
    Write-Verbose "Copied $($templates.Count) to Self Hosted Pipelines Module in Terraform folder"

    $templates = Get-ChildItem -Path './output/*' -Exclude '*_Azure.json', '*_Azure.json' -Include "GPL*.json", "GPL_Az*.json" -Name
    foreach($template in $templates) {
        Copy-Item -Path "./output/$template" -Destination "../../DeploymentV2\terraform\modules\data_factory_pipelines_azure/arm/"  
    }
    Write-Verbose "Copied $($templates.Count) to Azure Hosted Pipelines Module in Terraform folder"

    $templates = Get-ChildItem -Path './output/*' -Exclude '*_Azure.json', '*_Azure.json' -Include "SPL_Az*.json" -Name
    foreach($template in $templates) {
        Copy-Item -Path "./output/$template" -Destination "../../DeploymentV2\terraform\modules\data_factory_pipelines_azure/arm/"  
    }
    Write-Verbose "Copied $($templates.Count) to Static Hosted Pipelines Module in Terraform folder"
}

#ADF GIT INTEGRATION


if($($tout.adf_git_toggle_integration)) {
    #LINKED SERVICES
    $folder = "./linkedService/"
    Write-Verbose "_____________________________"
    Write-Verbose "Generating ADF linked services for Git Integration: " 
    Write-Verbose "_____________________________"
    #GLS
    $files = (Get-ChildItem -Path $folder -Filter "GLS*" -Verbose)
    foreach ($ir in $tout.integration_runtimes)
    {    


        if (($ir.is_azure -eq $false) -and ($tout.is_onprem_datafactory_ir_registered -eq $false))
        {
            #we dont want to generate anything for an on-prem IR if they are not registered

        }
        else {
            $shortName = $ir.short_name
            $fullName = $ir.name
            foreach ($file in $files){
                $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
                $newName = ($file.PSChildName).Replace(".libsonnet",".json")
                $newName = "LS_" + $newName
                $newName = $newname.Replace("(IRName)", $shortName)
                $hiddenoutput = (jsonnet --tla-str shortIRName="$shortName" --tla-str fullIRName="$fullName" $schemafiletemplate | Set-Content($newfolder + $newName))
            }
        }


    }
    #SLS
    $files = (Get-ChildItem -Path $folder -Filter "SLS*" -Verbose)
    foreach ($file in $files){
        $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
        $newName = ($file.PSChildName).Replace(".libsonnet",".json")
        $newName = "LS_" + $newName
        $hiddenoutput = (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))
    }
    #DATASETS
    $folder = "./dataset/"
    Write-Verbose "_____________________________"
    Write-Verbose "Generating ADF datasets for Git Integration: " 
    Write-Verbose "_____________________________"
    #GDS
    $files = (Get-ChildItem -Path $folder -Filter "GDS*" -Verbose)
    foreach ($ir in $tout.integration_runtimes)
    {
        if (($ir.is_azure -eq $false) -and ($tout.is_onprem_datafactory_ir_registered -eq $false))
        {
            #we dont want to generate anything for an on-prem IR if they are not registered
        }
        else {    
            $shortName = $ir.short_name
            $fullName = $ir.name
            foreach ($file in $files){
                $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
                $newName = ($file.PSChildName).Replace(".libsonnet",".json")
                $newName = $newname.Replace("(IRName)", $shortName)
                $hiddenoutput = (jsonnet --tla-str shortIRName="$shortName" --tla-str fullIRName="$fullName" $schemafiletemplate | Set-Content($newfolder + $newName))
            }
        }

    }

    #MANAGED VIRTUAL NETWORK

    $folder = "./managedVirtualNetwork/"
    $files = (Get-ChildItem -Path $folder -Filter "*.libsonnet" -Verbose)
    Write-Verbose "_____________________________"
    Write-Verbose "Generating ADF managed virtual networks for Git Integration: " 
    Write-Verbose "_____________________________"
    foreach ($file in $files)
    {
        $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
        $newName = ($file.PSChildName).Replace(".libsonnet",".json")
        $newName = "MVN_" + $newName
        $hiddenoutput = (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))
    }

    #managedPrivateEndpoint/default folder within MANAGED VIRTUAL NETWORK
    $folder = "./managedVirtualNetwork/default/managedPrivateEndpoint"
    #if our vnet isolation isnt on, we only want the standard files
    if ($tout.is_vnet_isolated) {
        $files = (Get-ChildItem -Path $folder -Filter *is_vnet_isolated*)
        Write-Verbose "_____________________________"
        Write-Verbose "Generating ADF managed private endpoints for Git Integration: " 
        Write-Verbose "_____________________________"
        foreach ($file in $files)
        {
            $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
            $newName = ($file.PSChildName).Replace(".libsonnet",".json")
            $newName = "MVN_default-managedPrivateEndpoint_" + $newName
            $newName = $newname.Replace("[is_vnet_isolated]", "")

            $hiddenoutput = (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))
        }
    }

    #INTEGRATION RUNTIMES
    $folder = "./integrationRuntime/"
    Write-Verbose "_____________________________"
    Write-Verbose "Generating ADF integration runtimes for Git Integration: " 
    Write-Verbose "_____________________________"
    #IR
    foreach ($ir in $tout.integration_runtimes)
    {
        if (($ir.is_azure -eq $false) -and ($tout.is_onprem_datafactory_ir_registered -eq $false))
        {
            #we dont want to generate anything for an on-prem IR if they are not registered
        }
        else {   
            $shortName = $ir.short_name
            $fullName = $ir.name
            if($ir.is_azure)
            {
                $files = (Get-ChildItem -Path $folder -Filter *is_azure*)
                foreach ($file in $files)
                {
                    $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
                    $newName = ($file.PSChildName).Replace(".libsonnet",".json")
                    $newName = $newName.Replace("[is_azure]", "")
                    $newName = $newName.Replace("(IRName)", $shortName)
                    $newName = "IR_" + $newName
                    $hiddenoutput = (jsonnet --tla-str fullIRName="$fullName" $schemafiletemplate | Set-Content($newfolder + $newName))
                }
            }
            else
            { 
                $files = (Get-ChildItem -Path $folder -Exclude *is_azure*)
                foreach ($file in $files)
                {
                    $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
                    $newName = ($file.PSChildName).Replace(".libsonnet",".json")
                    $newName = $newName.Replace("(IRName)", $shortName)
                    $newName = "IR_" + $newName
                    $hiddenoutput = (jsonnet --tla-str fullIRName="$fullName" $schemafiletemplate | Set-Content($newfolder + $newName))
                }
            }
        }


    }
    $folder = "./factory/"
    Write-Verbose "_____________________________"
    Write-Verbose "Generating ADF factories for Git Integration: " 
    Write-Verbose "_____________________________"
    #FA
    $files = (Get-ChildItem -Path $folder -Filter "*.libsonnet" -Verbose)
    foreach ($file in $files){
        $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
        $newName = ($file.PSChildName).Replace(".libsonnet",".json")
        $newName = $newName.Replace("(DatafactoryName)", $($tout.datafactory_name))
        $newName = "FA_" + $newName
        $hiddenoutput = (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))
    }

    #REPLACING PRINCIPALID grabbed from az datafactory
    #REASON: PRINCIPALID Contains a GUID on these files that I cannot identify where it is retrieved from otherwise

    $files = (Get-ChildItem -Path $newFolder -Filter FA*)
    foreach ($file in $files)
    {
        $fileSysObj = Get-Content $file -raw | ConvertFrom-Json
        $fileAZ = az datafactory show --name $fileSysObj.name --resource-group $($tout.resource_group_name)
        $fileAZ = $fileAZ | ConvertFrom-Json
        $fileSysObj.identity.principalId = $fileAZ.identity.principalId
        $fileSysObj | ConvertTo-Json -depth 32| Set-Content($($newfolder) + $($file.PSChildName))
    }
   
}



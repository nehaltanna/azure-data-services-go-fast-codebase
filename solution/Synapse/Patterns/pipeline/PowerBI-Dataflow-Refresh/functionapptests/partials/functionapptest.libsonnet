local commons = import '../../../static/partials/functionapptest_commons.libsonnet';
local vars = import '../../../static/partials/secrets.libsonnet';
function(
    SynapsePipeline = "GPL_ExecuteAndCheckFunctions",
    Pattern = "PowerBI Dataflow Refresh",
    TestNumber = "-1",
    SourceFormat = "N/A",
    SourceType = "Non-Applicable",
    SourceDataFilename = "",
    SourceSchemaFileName = "",
    SourceSystemAuthType = "MSI",
    SourceSkipLineCount = "",
    SourceFirstRowAsHeader ="",    
    SourceSheetName = "",
    SourceMaxConcurrentConnections = 0,
    SourceRecursively = "false",
    SourceDeleteAfterCompletion = "",
    TargetFormat = "N/A",
    TargetType = "Non-Applicable",
    TargetDataFilename = "",
    TargetSchemaFileName = "",
    TargetSystemAuthType = "MSI",
    TargetSkipLineCount = "",
    TargetFirstRowAsHeader ="",    
    TargetSheetName = "",
    TargetMaxConcurrentConnections = 0,
    TargetRecursively = "false",
    TargetDeleteAfterCompletion = "",
    TestDescription = "",
    WorkspaceId = "",
    TaskGroupId = 0
    )
{
    local TaskMasterJson =     
    {
        "DataflowName": "TaskMasterDF",
        "WorkspaceId": "ea6e65c7-8840-425b-a957-8c72609ac812",
        "Source":{
            "Type": SourceFormat,                       
            "RelativePath": "",
            "DataFileName": SourceDataFilename,
            "SchemaFileName": SourceSchemaFileName,
            "MaxConcurrentConnections": SourceMaxConcurrentConnections,
            "Recursively": SourceRecursively,
            "DeleteAfterCompletion": SourceDeleteAfterCompletion,
            
        },

        "Target":{
            "Type":TargetFormat,
            "RelativePath":"",
            "DataFileName": TargetDataFilename,
            "SchemaFileName": TargetSchemaFileName,            
            "MaxConcurrentConnections": TargetMaxConcurrentConnections,
            "Recursively": TargetRecursively,
            "DeleteAfterCompletion": TargetDeleteAfterCompletion
        },
    },

    local TaskInstanceJson =  
    {
        
    },

    local SourceSystemJson = 
    {
            
    },

    local TargetSystemJson = 
    {   
         
    },
    "TaskGroupId": TaskGroupId,       
    "TaskInstanceJson":std.manifestJson(TaskInstanceJson),
    "TaskTypeId":-11,
    "TaskType":Pattern,
    "EngineName":vars.datafactory_name,
    "EngineResourceGroup":vars.resource_group_name,
    "EngineSubscriptionId":vars.subscription_id,
    "EngineJson":  '{"ClientId": "073a7c75-84de-4ace-9dbe-777617a0e3ff", "ClientSecretName": "testSecret", "TenantId": ""}',
    "TaskMasterJson":std.manifestJson(TaskMasterJson),       
    "TaskMasterId":TestNumber,
    "SourceSystemId": -21,
    "SourceSystemJSON":std.manifestJson(SourceSystemJson),
    "SourceSystemType":SourceType,
    "SourceSystemServer":"N/A",
    "SourceKeyVaultBaseUrl":"https://" + vars.keyvault_name +".vault.azure.net",
    "SourceSystemAuthType":SourceSystemAuthType,
    "SourceSystemSecretName":"",
    "SourceSystemUserName":"",   
    "TargetSystemId": -16,
    "TargetSystemJSON":std.manifestJson(TargetSystemJson),
    "TargetSystemType":TargetType,
    "TargetSystemServer":"N/A",
    "TargetKeyVaultBaseUrl":"https://" + vars.keyvault_name +".vault.azure.net",
    "TargetSystemAuthType":TargetSystemAuthType,
    "TargetSystemSecretName":"",
	"TargetSystemUserName":"",
    "SynapsePipeline": SynapsePipeline,
    "TestDescription": "[" + TestNumber + "] " +  " PowerBI Dataflow Refresh " + " execution test.",
    "DependencyChainTag": "" 
}+commons


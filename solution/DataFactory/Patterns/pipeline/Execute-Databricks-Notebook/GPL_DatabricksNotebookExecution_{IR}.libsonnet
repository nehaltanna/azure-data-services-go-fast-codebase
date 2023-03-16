function(GenerateArm="false",GFPIR="{IRA}",SourceType="",SourceFormat="", TargetType="", TargetFormat="")

local generateArmAsBool = GenerateArm == "true";
local Wrapper = import '../static/partials/wrapper.libsonnet';

local Folder = "ADS Go Fast/Data Movement/Execute-Databricks-Notebook/";
local name =  if(!generateArmAsBool) 
			then "GPL_" + "DatabricksNotebookExecution_" + "Primary_" + GFPIR 
			else "[concat(parameters('dataFactoryName'), '/','GPL_"+ "DatabricksNotebookExecution" +"_Primary_" + "', parameters('integrationRuntimeShortName'))]";


local pipeline = {
    "name": name,
    "properties": {
        "activities": [
            {
                "name": "Execute Databricks Notebook",
                "type": "DatabricksNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebookPath": {
                        "value": "@string(json(string(pipeline().parameters.TaskObject)).TMOptionals.NotebookPath)",
                        "type": "Expression"
                    },
                    "baseParameters": {
                        "TaskObject": {
                            "value": "@string(pipeline().parameters.TaskObject)",
                            "type": "Expression"
                        }
                    }
                },
                "linkedServiceName": {
                    "referenceName": "GLS_AzureDatabricks_"+GFPIR,
                    "type": "LinkedServiceReference",
                    "parameters": {
                        "ClusterNodeType": {
                            "value": "@string(json(string(pipeline().parameters.TaskObject)).TMOptionals.ClusterNodeType)",
                            "type": "Expression"
                        },
                        "ClusterVersion": {
                            "value": "@string(json(string(pipeline().parameters.TaskObject)).TMOptionals.ClusterVersion)",
                            "type": "Expression"
                        },
                        "DatabricksWorkspaceURL": {
                            "value": "@string(json(string(pipeline().parameters.TaskObject)).ExecutionEngine.JsonProperties.DatabricksWorkspaceURL)",
                            "type": "Expression"
                        },
                        "Workers": {
                            "value": "@string(json(string(pipeline().parameters.TaskObject)).TMOptionals.Workers)",
                            "type": "Expression"
                        },
                        "WorkspaceResourceID": {
                            "value": "@string(json(string(pipeline().parameters.TaskObject)).ExecutionEngine.JsonProperties.DatabricksWorkspaceResourceID)",
                            "type": "Expression"
                        },
                        "InstancePool": {
                            "value": "@if(equals(string(json(string(pipeline().parameters.TaskObject)).TMOptionals.CustomInstancePoolID), ''), string(json(string(pipeline().parameters.TaskObject)).ExecutionEngine.JsonProperties.DefaultInstancePoolID), string(json(string(pipeline().parameters.TaskObject)).TMOptionals.CustomInstancePoolID))",
                            "type": "Expression"
                        }
                    }
                }
            },
            {
                "name": "Execute Databricks Notebook Failed",
                "type": "ExecutePipeline",
                "dependsOn": [
                    {
                        "activity": "Execute Databricks Notebook",
                        "dependencyConditions": [
                            "Failed"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "pipeline": {
                        "referenceName": "SPL_AzureFunction",
                        "type": "PipelineReference"
                    },
                    "waitOnCompletion": false,
                    "parameters": {
                        "Body": {
                            "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"LogTypeId\":1,\"LogSource\":\"ADF\",\"ActivityType\":\"Execute Databricks Notebook\",\"StartDateTimeOffSet\":\"', string(pipeline().TriggerTime), '\",\"EndDateTimeOffSet\":\"', string(utcnow()), '\",\"Comment\":\"', encodeUriComponent(string(activity('Execute Databricks Notebook').error.message)), '\",\"Status\":\"Failed\"}'))",
                            "type": "Expression"
                        },
                        "FunctionName": "Log",
                        "Method": "Post"
                    }
                }
            },
            {
                "name": "Execute Databricks Notebook Succeeded",
                "type": "ExecutePipeline",
                "dependsOn": [
                    {
                        "activity": "Execute Databricks Notebook",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "pipeline": {
                        "referenceName": "SPL_AzureFunction",
                        "type": "PipelineReference"
                    },
                    "waitOnCompletion": false,
                    "parameters": {
                        "Body": {
                            "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"LogTypeId\":1,\"LogSource\":\"ADF\",\"ActivityType\":\"Execute Databricks Notebook\",\"StartDateTimeOffSet\":\"', string(pipeline().TriggerTime), '\",\"EndDateTimeOffSet\":\"', string(utcnow()), '\",\"RowsInserted\":\"', string(activity('Execute Databricks Notebook').output.runPageUrl), '\",\"Comment\":\"\",\"Status\":\"Complete\"}'))",
                            "type": "Expression"
                        },
                        "FunctionName": "Log",
                        "Method": "Post"
                    }
                }
            }
        ],
        "parameters": {
            "TaskObject": {
                "type": "object"
            }
        },
        "folder": {
            "name": Folder
        },
        "annotations": []
    },
	"type": "Microsoft.DataFactory/factories/pipelines"
};
Wrapper(GenerateArm,pipeline)+{}
function(GenerateArm="false",GFPIR="", SparkPoolName = "")
local name =  "GPL_ExecuteAndCheckFunctions_Primary_" + GFPIR;
local Wrapper = import '../static/partials/wrapper.libsonnet';
local ActivityName = "ExecuteAndCheckFunctions";

local Folder =  if(GenerateArm=="false") 
					then "ADS Go Fast/Data Movement/ExecuteAndCheckFunctions/" + GFPIR +"/"
					else "[concat('ADS Go Fast/Data Movement/ExecuteAndCheckFunctions/', parameters('integrationRuntimeShortName'), '/')]";

local pipeline = 
{
    "name": name,
        "properties": {
        "activities": [
            {
                "name": "Poll For Check Complete",
                "type": "Until",
                "dependsOn": [
                    {
                        "activity": "Execute Function",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "expression": {
                        "value": "@equals(\n    variables('CheckComplete'),\n    bool('true')\n)",
                        "type": "Expression"
                    },
                    "activities": [
                        {
                            "name": "Check Function",
                            "type": "AzureFunctionActivity",
                            "dependsOn": [],
                            "policy": {
                                "timeout": "7.00:00:00",
                                "retry": 0,
                                "retryIntervalInSeconds": 30,
                                "secureOutput": false,
                                "secureInput": false
                            },
                            "userProperties": [],
                            "typeProperties": {
                                "functionName": {
                                    "value": "@string(json(string(pipeline().parameters.TaskObject)).TMOptionals.FunctionToCheck)",
                                    "type": "Expression"
                                },
                                "method": "POST",
                                "body": {
                                    "value": "@activity('Execute Function').output",
                                    "type": "Expression"
                                }
                            },
                            "linkedServiceName": {
                                "referenceName": "SLS_AzureFunctionApp",
                                "type": "LinkedServiceReference"
                            }
                        },
                        {
                            "name": "Mark Check Function as Complete - Failed Function",
                            "type": "SetVariable",
                            "dependsOn": [
                                {
                                    "activity": "Check Function",
                                    "dependencyConditions": [
                                        "Failed"
                                    ]
                                }
                            ],
                            "userProperties": [],
                            "typeProperties": {
                                "variableName": "CheckComplete",
                                "value": {
                                    "value": "@bool('true')",
                                    "type": "Expression"
                                }
                            }
                        },
                        {
                            "name": "Failure due to execution error",
                            "type": "Fail",
                            "dependsOn": [
                                {
                                    "activity": "Mark Check Function as Complete - Failed Function",
                                    "dependencyConditions": [
                                        "Succeeded"
                                    ]
                                }
                            ],
                            "userProperties": [],
                            "typeProperties": {
                                "message": "Azure Function Execution Failed.",
                                "errorCode": "0"
                            }
                        },
                        {
                            "name": "Status Result Switch",
                            "type": "Switch",
                            "dependsOn": [
                                {
                                    "activity": "Check Function",
                                    "dependencyConditions": [
                                        "Succeeded"
                                    ]
                                }
                            ],
                            "userProperties": [],
                            "typeProperties": {
                                "on": {
                                    "value": "@activity('Check Function').output.Status",
                                    "type": "Expression"
                                },
                                "cases": [
                                    {
                                        "value": "Success",
                                        "activities": [
                                            {
                                                "name": "Mark Check Function As Complete - Success",
                                                "type": "SetVariable",
                                                "dependsOn": [],
                                                "userProperties": [],
                                                "typeProperties": {
                                                    "variableName": "CheckComplete",
                                                    "value": {
                                                        "value": "@bool('true')",
                                                        "type": "Expression"
                                                    }
                                                }
                                            }
                                        ]
                                    },
                                    {
                                        "value": "Failed",
                                        "activities": [
                                            {
                                                "name": "Mark Check Function as Complete - Failed",
                                                "type": "SetVariable",
                                                "dependsOn": [],
                                                "userProperties": [],
                                                "typeProperties": {
                                                    "variableName": "CheckComplete",
                                                    "value": {
                                                        "value": "@bool('true')",
                                                        "type": "Expression"
                                                    }
                                                }
                                            },
                                            {
                                                "name": "Failure due to Status",
                                                "type": "Fail",
                                                "dependsOn": [
                                                    {
                                                        "activity": "Mark Check Function as Complete - Failed",
                                                        "dependencyConditions": [
                                                            "Succeeded"
                                                        ]
                                                    }
                                                ],
                                                "userProperties": [],
                                                "typeProperties": {
                                                    "message": "Azure Function successfully completed however the Status of returned API call is 'Failed'. Note: This indicates the error is outside of the Azure Function execution.",
                                                    "errorCode": "0"
                                                }
                                            }
                                        ]
                                    }
                                ],
                                "defaultActivities": [
                                    {
                                        "name": "Wait1",
                                        "type": "Wait",
                                        "dependsOn": [],
                                        "userProperties": [],
                                        "typeProperties": {
                                            "waitTimeInSeconds": 60
                                        }
                                    }
                                ]
                            }
                        }
                    ],
                    "timeout": "0.02:00:00"
                }
            },
            {
                "name": "Execute Function",
                "type": "AzureFunctionActivity",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "functionName": {
                        "value": "@string(json(string(pipeline().parameters.TaskObject)).TMOptionals.FunctionToExecute)",
                        "type": "Expression"
                    },
                    "method": "POST",
                    "body": {
                        "value": "@pipeline().parameters.TaskObject",
                        "type": "Expression"
                    }
                },
                "linkedServiceName": {
                    "referenceName": "SLS_AzureFunctionApp",
                    "type": "LinkedServiceReference"
                }
            }
        ],
        "parameters": {
            "TaskObject": {
                "type": "object"
            }
        },
        "variables": {
            "CheckComplete": {
                "type": "Boolean",
                "defaultValue": false
            },
            "OutputMetaData": {
                "type": "String"
            }
        },
        "folder": {
            "name": Folder
        },
        "annotations": [],
        "lastPublishTime": "2022-04-06T03:50:37Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
};
Wrapper(GenerateArm,pipeline)+{}
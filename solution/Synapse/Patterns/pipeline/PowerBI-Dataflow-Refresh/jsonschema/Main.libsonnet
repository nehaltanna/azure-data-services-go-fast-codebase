local partials = {
    "Not-Applicable": import "Not-Applicable.libsonnet"
};


function(SourceType = "", SourceFormat = "Not-Applicable", TargetType = "", TargetFormat = "Not-Applicable")
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "title": "TaskMasterJson",
    "properties": {
        "DataflowName": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "df_testdataflow"
                },
                "infoText": "(required) Use this field to define the name of the dataflow you are wanting to refresh within the specified workspace."
            }
        },
        "WorkspaceId": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "00000000-0000-0000-0000-000000000000"
                },
                "infoText": "(required) Use this field to define the ID of the workspace that contains the dataflow you wish to reference."
            },
        },
        "FunctionToExecute": {
            "type": "string",
            "enum": [
                "PowerBIRefreshDataflow"
            ],
            "options": {
                "hidden": true
            },
            "default": "PowerBIRefreshDataflow"
        },
        "FunctionToCheck": {
            "type": "string",
            "enum": [
                "PowerBICheckDataflowRefresh"
            ],
            "options": {
                "hidden": true
            },
            "default": "PowerBICheckDataflowRefresh"
        },
        "Source": partials[SourceFormat](),
        "Target": partials[TargetFormat]()
    },
    "required": [
        "DataflowName",
        "WorkspaceId"
    ]
}
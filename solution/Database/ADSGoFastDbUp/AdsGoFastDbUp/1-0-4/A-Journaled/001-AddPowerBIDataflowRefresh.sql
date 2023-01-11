/* TASK TYPE FOR PowerBI Dataflow Refresh */
SET IDENTITY_INSERT [dbo].[TaskType] ON 
GO
INSERT [dbo].[TaskType] ([TaskTypeId], [TaskTypeName], [TaskExecutionType], [TaskTypeJson], [ActiveYN]) VALUES (-11, N'PowerBIApp SP API Access', N'ADF', NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[TaskType] OFF
GO

INSERT [dbo].[SourceAndTargetSystems_JsonSchema] ([SystemType], [JsonSchema]) VALUES (N'PowerBI SP', N'{  "$schema": "http://json-schema.org/draft-04/schema#",  "type": "object",  "properties": {    "ClientId": {      "type": "string"     }, "ClientSecretName": {      "type": "string"     }, "TenantId": {      "type": "string"     }  },  "required": [    "ClientId", "ClientSecretName"  ]}')
GO


SET IDENTITY_INSERT [dbo].[SourceAndTargetSystems] ON 
GO
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-21, N'Sample - PowerBIApp SP', N'PowerBI SP', N'Sample PowerBI SP', N'(external)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "ClientId" : "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  , "ClientSecretName" : "testSecret"  , "TenantId" : ""    }', 1, 1, NULL)
GO
SET IDENTITY_INSERT [dbo].[SourceAndTargetSystems] OFF 
GO


INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (1, 'Azure', -17, 1)
GO

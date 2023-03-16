/* TASK TYPE FOR Execute Databricks Notebook */
SET IDENTITY_INSERT [dbo].[TaskType] ON 
GO
INSERT [dbo].[TaskType] ([TaskTypeId], [TaskTypeName], [TaskExecutionType], [TaskTypeJson], [ActiveYN]) VALUES (-12, N'Execute Databricks Notebook', N'ADF', NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[TaskType] OFF
GO
/* Update execution engine json on datafactory */
UPDATE [dbo].[ExecutionEngine]
SET EngineJson = '{"DatabricksWorkspaceURL": "https://$DatabricksWorkspaceURL$", "DatabricksWorkspaceResourceID": "$DatabricksWorkspaceResourceID$", "DefaultInstancePoolID": "$DefaultInstancePoolID$"}'
WHERE EngineId = '-1'
GO
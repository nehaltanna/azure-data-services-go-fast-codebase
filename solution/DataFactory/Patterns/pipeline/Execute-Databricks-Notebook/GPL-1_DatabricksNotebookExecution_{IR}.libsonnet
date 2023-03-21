
function(GenerateArm="false",GFPIR="IRA",SourceType="SqlServerTable",SourceFormat="NA",TargetType="AzureBlobFS",TargetFormat="Parquet")
local Wrapper = import '../static/partials/wrapper.libsonnet';
local ParentPipelineTemplate = import '../static/partials/ParentPipeline.libsonnet';
local Name = if(GenerateArm=="false") 
			then "GPL_"+"DatabricksNotebookExecution"+"_"+GFPIR 
			else "[concat(parameters('dataFactoryName'), '/','GPL_"+"DatabricksNotebookExecution"+"_" + "', parameters('integrationRuntimeShortName'))]";
local CalledPipelineName = if(GenerateArm=="false") 
			then "GPL_"+"DatabricksNotebookExecution"+ "_Primary_" + GFPIR 
			else "[concat('GPL_"+ "DatabricksNotebookExecution" + "_Primary_" + "', parameters('integrationRuntimeShortName'))]";
local Folder =  if(GenerateArm=="false") 
					then "ADS Go Fast/Data Movement/Execute-Databricks-Notebook/" + GFPIR + "/ErrorHandler/"
					else "[concat('ADS Go Fast/Data Movement/Execute-Databricks-Notebook', parameters('integrationRuntimeShortName'), '/ErrorHandler/')]";

local pipeline = {} + ParentPipelineTemplate(Name, CalledPipelineName, Folder);
	
Wrapper(GenerateArm,pipeline)+{}
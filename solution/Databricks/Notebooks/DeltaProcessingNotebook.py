# Databricks notebook source
all_args = dbutils.notebook.entry_point.getCurrentBindings()

TaskObject = "Debug"

if len(all_args): # TaskObject passed as parameter
    TaskObject = all_args["TaskObject"]
    
print(TaskObject)

if TaskObject == "Debug":
    TaskObject = """{"TaskInstanceId": 37,
        "TaskMasterId": -1000,
        "TaskStatus": "InProgress",
        "TaskType": "Azure Storage to Azure Storage",
        "Enabled": 1,
        "ExecutionUid": "9d06d8c7-9184-4bee-9605-62142e22781c",
        "NumberOfRetries": 0,
        "DegreeOfCopyParallelism": 1,
        "KeyVaultBaseUrl": "https://ads-stg-kv-ads-r6p7.vault.azure.net/",
        "ScheduleMasterId": "-4",
        "TaskGroupConcurrency": "10",
        "TaskGroupPriority": 0,
        "TaskExecutionType": "ADF",
        "ExecutionEngine": {
            "EngineId": -2,
            "EngineName": "adsstgsynwadsr6p7",
            "SystemType": "Synapse",
            "ResourceGroup": "gfuat2",
            "SubscriptionId": "035a1364-f00d-48e2-b582-4fe125905ee3",
            "ADFPipeline": "GPL_SparkNotebookExecution_Azure",
            "EngineJson": {"endpoint": "https://adsstgsynwadsr6p7.dev.azuresynapse.net", "DeltaProcessingNotebook": "DeltaProcessingNotebook", "PurviewAccountName": "adsstgpuradsr6p7", "DefaultSparkPoolName":"adsstgsynspads"},
            "TaskDatafactoryIR": "Azure",
            "JsonProperties": {
                "endpoint": "https://adsstgsynwadsr6p7.dev.azuresynapse.net",
                "DeltaProcessingNotebook": "DeltaProcessingNotebook",
                "PurviewAccountName": "adsstgpuradsr6p7",
                "DefaultSparkPoolName": "adsstgsynspads"
            }
        },
        "Source": {
            "System": {
                "SystemId": -4,
                "SystemServer": "https://adsstgdlsadsr6p7adsl.dfs.core.windows.net",
                "AuthenticationType": "MSI",
                "Type": "ADLS",
                "Username": null,
                "Container": "datalakeraw"
            },
            "Instance": {
                "SourceRelativePath": "samples/SalesLT_Customer_CDC/",
                "TargetRelativePath": "/Tests/Azure Storage to Azure Storage/-1000/"
            },
            "DataFileName": "SalesLT.Customer*.parquet",
            "DeleteAfterCompletion": "false",
            "MaxConcurrentConnections": 0,
            "Recursively": "false",
            "RelativePath": "samples/SalesLT_Customer_CDC/",
            "SchemaFileName": "SalesLT.Customer*.json",
            "Type": "Parquet",
            "WriteSchemaToPurview": "Disabled"
        },
        "Target": {
            "System": {
                "SystemId": -4,
                "SystemServer": "https://adsstgdlsadsr6p7adsl.dfs.core.windows.net",
                "AuthenticationType": "MSI",
                "Type": "ADLS",
                "Username": null,
                "Container": "datalakeraw"
            },
            "Instance": {
                "SourceRelativePath": "samples/SalesLT_Customer_CDC/",
                "TargetRelativePath": "/Tests/Azure Storage to Azure Storage/-1000/"
            },
            "DataFileName": "SalesLT.Customer",
            "DeleteAfterCompletion": "false",
            "MaxConcurrentConnections": 0,
            "Recursively": "false",
            "RelativePath": "/Tests/Azure Storage to Azure Storage/-1000/",
            "SchemaFileName": "SalesLT.Customer.json",
            "Type": "Delta",
            "WriteSchemaToPurview": "Disabled"
        },
        "TMOptionals": {
            "CDCSource": "Disabled",
            "Purview": "Disabled",
            "QualifiedIDAssociation": "TaskMasterId",
            "SparkTableCreate": "Disabled",
            "SparkTableDBName": "",
            "SparkTableName": "",
            "UseNotebookActivity": "Disabled"
        }
    }"""

# COMMAND ----------

#/Shared/ads/notebooks/DeltaProcessingNotebook_new.py

#/Workspace/Repos/alysson.souza@databricks.com/azure-data-services-go-fast-codebase/solution/Databricks/notebook/DeltaProcessingNotebook_new/DeltaProcessingNotebook_new.py



import random
import json
from pyspark.sql import Row
from pyspark.sql.types import *
from pyspark.sql.functions import *
from datetime import date
from datetime import datetime

session_id = random.randint(0,1000000)

TaskObjectJson = json.loads(TaskObject)
Source = TaskObjectJson['Source']['System']['Container'] + "@" + TaskObjectJson['Source']['System']['SystemServer'].replace("https://","") + "/"
Schema = TaskObjectJson['Source']['System']['Container'] + "@" + TaskObjectJson['Source']['System']['SystemServer'].replace("https://","") + "/"
Target = TaskObjectJson['Target']['System']['Container'] + "@" + TaskObjectJson['Target']['System']['SystemServer'].replace("https://","") + "/"


Source = Source + TaskObjectJson['Source']['Instance']['SourceRelativePath'] + "/" + TaskObjectJson['Source']['DataFileName']
Schema = Schema + TaskObjectJson['Source']['Instance']['SourceRelativePath'] + "/" + TaskObjectJson['Source']['SchemaFileName']
Target = Target + TaskObjectJson['Target']['Instance']['TargetRelativePath'] + "/" + TaskObjectJson['Target']['DataFileName']


#remove any double slashes
Source = Source.replace('//', '/')
Schema = Schema.replace('//', '/')
Target = Target.replace('//', '/')

#get source and target data types
SourceDT = TaskObjectJson['Source']['Type']
TargetDT = TaskObjectJson['Target']['Type']


#add abfss
Source = "abfss://" + Source
Schema = "abfss://" + Schema
Target = "abfss://" + Target

now = datetime.now()

Source = Source.replace("{yyyy}", "%Y")
Source = Source.replace("{MM}", "%m")
Source = Source.replace("{dd}", "%d")
Source = Source.replace("{hh}", "%H")
Source = Source.replace("{mm}", "%M")
Source = now.strftime(Source)

Target = Target.replace("{yyyy}", "%Y")
Target = Target.replace("{MM}", "%m")
Target = Target.replace("{dd}", "%d")
Target = Target.replace("{hh}", "%H")
Target = Target.replace("{mm}", "%M")
Target = now.strftime(Target)

Schema = Schema.replace("{yyyy}", "%Y")
Schema = Schema.replace("{MM}", "%m")
Schema = Schema.replace("{dd}", "%d")
Schema = Schema.replace("{hh}", "%H")
Schema = Schema.replace("{mm}", "%M")
Schema = now.strftime(Schema)

print ("Source: " + Source)
print ("Schema: " + Schema)
print ("Target: " + Target)



# COMMAND ----------

schema_path = Schema
Source_path = Target
Target_path = Source

# COMMAND ----------

# MAGIC %md
# MAGIC ##For testing remove when TaskObjectJson is used

# COMMAND ----------

debug = True
if debug == True:
  repo_path = "/Workspace/Repos/shared/"

  #/Workspace/Repos/shared/azure-data-services-go-fast-codebase/solution/SampleFiles/SalesLT_Customer_CDC/SalesLT.CustomerCDCInit.json
  
  schema_path = f"file:{repo_path}/azure-data-services-go-fast-codebase/solution/SampleFiles/SalesLT_Customer_CDC/SalesLT.CustomerCDCInit.json"

  Source_path = f"file:{repo_path}/azure-data-services-go-fast-codebase/solution/SampleFiles/SalesLT_Customer_CDC/SalesLT.CustomerCDCInit.parquet"

  Target_path = "/tmp/AGF/SalesLT.Customer"

  TaskObjectJson['TMOptionals']['SparkTableDBName'] = "ads_sample_db"
  TaskObjectJson['TMOptionals']['SparkTableName'] = "ads_sample_target_table"

# COMMAND ----------

# #For testing
# #"/Shared/ads/notebooks/DeltaProcessingNotebook.py"
# repo_path = "/Shared/ads/notebooks/"
# #repo_path = "Workspace/Repos/shared/ads-git/"
# repo_path = "/Workspace/Repos/alysson.souza@databricks.com/"
# #/Workspace/Repos/alysson.souza@databricks.com/azure-data-services-go-fast-codebase/solution/SampleFiles/SalesLT_Customer_CDC/SalesLT.CustomerCDCInit.json
# schema_path = f"file:{repo_path}/azure-data-services-go-fast-codebase/solution/SampleFiles/SalesLT_Customer_CDC/SalesLT.CustomerCDCInit.json"

# Source_path = f"file:{repo_path}/azure-data-services-go-fast-codebase/solution/SampleFiles/SalesLT_Customer_CDC/SalesLT.CustomerCDCInit.parquet"

# Target_path = "/tmp/AGF/SalesLT.Customer"

# TaskObjectJson['TMOptionals']['SparkTableDBName'] = "ads_sample_db"
# TaskObjectJson['TMOptionals']['SparkTableName'] = "ads_sample_target_table"

# COMMAND ----------

# MAGIC %md
# MAGIC ##Enforce Schema if schema is provided otherwise Infer Schema 
# MAGIC 
# MAGIC Didn't test schema inference

# COMMAND ----------

try:
    print("Schema found - using schema json to find PK")
    schema = spark.read.load(schema_path, format='json', multiLine=True)
    #convert it into a list so we can loop it using python rules
    schema = schema.collect()
    #loop through each column to find the primary key column
    for col in schema:
        if col.PKEY_COLUMN:
            print(col.COLUMN_NAME)
            primaryKey = col
            mergeCondition = "oldData." + primaryKey.COLUMN_NAME + " = newData." + primaryKey.COLUMN_NAME
            break
except Exception as exp:
    print("Schema json not found - assuming source dataframe first column is PK")
    df = spark.read.load(Source_path, format=SourceDT)
    primaryKey = df.columns[0]
    print(primaryKey)
    mergeCondition = "oldData." + primaryKey + " = newData." + primaryKey

#set up the merge condition used in the next code block
print(mergeCondition)

# COMMAND ----------

# spark.sql(f"DROP DATABASE {TaskObjectJson['TMOptionals']['SparkTableDBName']} CASCADE")
# dbutils.fs.rm("Target_path")

# COMMAND ----------

# MAGIC %md 
# MAGIC ##Improvement? (None CDC path failed when reloading the same df)
# MAGIC 
# MAGIC A merge operation can fail if multiple rows of the source dataset match and the merge attempts to update the same rows of the target Delta table. According to the SQL semantics of merge, such an update operation is ambiguous as it is unclear which source row should be used to update the matched target row. You can preprocess the source table to eliminate the possibility of multiple matches. See the change data capture example—it shows how to preprocess the change dataset (that is, the source dataset) to retain only the latest change for each key before applying that change into the target Delta table.
# MAGIC 
# MAGIC Didn't test CDC
# MAGIC 
# MAGIC pdf = df.toPandas() might not be performant for large data sets 

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Temporary solution: dropping rows with the same cusotmerID but different values. 
# MAGIC 
# MAGIC otherwise the merge fails with this exception if it runs two times:
# MAGIC 
# MAGIC Cannot perform Merge as multiple source rows matched and attempted to modify the same

# COMMAND ----------

from pyspark.sql.window import Window
from pyspark.sql.functions import row_number

df = spark.read.load(Source_path, format=SourceDT)

windowSpec  = Window.partitionBy("CustomerID").orderBy("CustomerID")

df = df.withColumn("row_number",row_number().over(windowSpec))

df = df.where(df.row_number==1).drop(df.row_number)

# COMMAND ----------

from delta.tables import *
import pandas as pd
if(TaskObjectJson['TMOptionals']['CDCSource'] == 'Enabled'):
    print("CDC Source")
    ######---- commented for the temp solotuin above 
    #df = spark.read.load(Source_path, format=SourceDT)
    ######---- commented for the temp solotuin above 
    
    #these are our cdc specific columns
    cdcCols = ["__$start_lsn", "__$end_lsn", "__$seqval", "__$update_mask", "__$operation", "__$command_id"]
    #we are dropping all of the $ / _ as they cause issues with spark SQL functions -> this may be changed to just remove the first 3 chars of each of the cdcCols (__$)
    cdcColsToDrop = ["startlsn", "endlsn", "seqval", "updatemask", "operation", "commandid"]
    #these are columns we want to convert from binary data types to string as dataframes do not play nice with them currently
   #colsToString = ["__$start_lsn", "__$end_lsn", "__$seqval", "__$update_mask"]
    colsToString = ["startlsn", "endlsn", "seqval", "updatemask"]

    for col in cdcCols:
        new_col = col.replace('_','')
        new_col = new_col.replace('$','')
        df = df.withColumnRenamed(col, new_col)

    for col in colsToString: 
        try:
            df = df.withColumn(col, hex(col))
        except:
            print("Error converting the column " + col)

    #convert to pandas dataframe so we can do more manipulation
    pdf = df.toPandas()

    #we want to sort by our start lsn and then by the seqval so that we can drop everything except the most recent database change for every unique row
    try:
        #columns we are sorting by, the LSN and then the sequence value - ensure the latest is at the bottom of the table
        pdf = pdf.sort_values(by=["startlsn", "seqval"])
    except:
        print("error in finding valid sorting columns - skipping.")
    pdf_dedupe = pdf.drop_duplicates(subset=[primaryKey.COLUMN_NAME], keep='last', inplace=False)

    df = spark.createDataFrame(pdf_dedupe)

    #operation 1 is equal to delete, the other 3 operations (inserts old and new / upserts) can be done together
    dfDeletes = df.filter("operation == 1")
    dfUpserts = df.filter("operation != 1")
    #We want to sort our columns by our primary key now that we have only the latest actions
    dfDeletes = dfDeletes.sort(primaryKey.COLUMN_NAME)
    dfUpserts = dfUpserts.sort(primaryKey.COLUMN_NAME)

    #drop unwanted columns -> not needed for our delta table as they are cdc specific
    for col in cdcColsToDrop:
        try:
            dfDeletes = dfDeletes.drop(col)
            dfUpserts = dfUpserts.drop(col)
        except:
            print("Error dropping the column " + col)

    sql = 'describe detail "' + Target_path + '"'
    try:
        if (spark.sql(sql).collect()[0].asDict()['format'] == 'delta'):
            print("Table already exists. Performing Merge")
            olddt = DeltaTable.forPath(spark, Target_path)  
            olddt.alias("oldData").merge(
                dfUpserts.alias("newData"),
                mergeCondition) \
            .whenMatchedUpdateAll() \
            .whenNotMatchedInsertAll() \
            .execute()
        else:
            print("Table does not exist. No error, creating new Delta Table.")    
            dfUpserts.write.format("delta").save(Target_path)
    except: 
        print("Table does not exist, error thrown. Creating new Delta Table. Note - this error can be that no file is found.") 
        dfUpserts.write.format("delta").save(Target_path)

    olddt = DeltaTable.forPath(spark, Target_path)  
    olddt.alias("oldData").merge(
    dfDeletes.alias("newData"),
    mergeCondition) \
    .whenMatchedDelete() \
    .execute()  

else:
    print("Non CDC Source")
    if(TargetDT == 'Delta'):
        print("SourceDT = " + SourceDT + ", TargetDT = Delta.")
        ######---- commented for the temp solotuin above 
        #df = spark.read.load(Source_path, format=SourceDT)
        ######---- commented for the temp solotuin above 
               
        sql = 'describe detail "' + Target_path + '"'
        try:
            if (spark.sql(sql).collect()[0].asDict()['format'] == 'delta'):
                print("Table already exists. Performing Merge")
                olddt = DeltaTable.forPath(spark, Target_path)  
                olddt.alias("oldData").merge(
                    df.alias("newData"),
                    mergeCondition) \
                .whenMatchedUpdateAll() \
                .whenNotMatchedInsertAll() \
                .execute()
            else:
                print("Table does not exist. No error, creating new Delta Table.")    
                df.write.format("delta").save(Target_path)
        except:
            print("Table does not exist. Creating new Delta Table.")    
            df.write.format("delta").save(Target_path)
    elif(TargetDT == 'Parquet' and SourceDT == 'Delta'):
        print("SourceDT = Delta, TargetDT = Parquet.")
        df = spark.read.format("delta").load(Source_path)
        df.write.format("parquet").mode("overwrite").save(Target_path) 

# COMMAND ----------

dbutils.fs.ls("dbfs:/tmp/AGF/SalesLT.Customer")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Create Delta table in the hive metastore if already doesn't exist
# MAGIC Doesn't need to refresh the table as it is not an external table. 
# MAGIC 
# MAGIC Assuming that based on previous steps data is already stored in Delta format in the Target_path

# COMMAND ----------

if(TaskObjectJson['TMOptionals']['SparkTableCreate'] == 'Enabled'):
    targetDB = str.lower(TaskObjectJson['TMOptionals']['SparkTableDBName'])
    targetTable = str.lower(TaskObjectJson['TMOptionals']['SparkTableName'])

    spark.sql(f"CREATE DATABASE IF NOT EXISTS {targetDB}")
    # default is Delta format
    spark.sql(f"CREATE TABLE IF NOT EXISTS {targetDB}.{targetTable} USING Delta LOCATION '{Target_path}'")
else:
    print("Skipping Spark Table creation")

# COMMAND ----------


#spark.sql(f"SELECT * FROM hive_metastore.{targetDB}.{targetTable}")
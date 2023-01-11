SELECT 
	CAST(CEILING(count(*)/{chunkSize} + 0.00001) as int) as  batchcount
FROM [{tableSchema}].[{tableName}] 
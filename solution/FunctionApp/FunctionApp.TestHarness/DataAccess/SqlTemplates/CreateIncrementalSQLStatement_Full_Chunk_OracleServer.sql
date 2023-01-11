SELECT 
	CAST(CEIL(COUNT(*)/{chunkSize} + 0.00001) as INTEGER) as batchcount
FROM {tableSchema}.{tableName} 
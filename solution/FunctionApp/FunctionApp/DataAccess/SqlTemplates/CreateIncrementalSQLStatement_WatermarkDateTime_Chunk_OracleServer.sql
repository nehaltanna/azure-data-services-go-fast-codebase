SELECT MAX({incrementalField}) AS newWatermark, 
		CAST(CASE when COUNT(*) = 0 then 0 else CEIL(COUNT(*)/{chunkSize} + 0.00001) end as INTEGER) as batchcount
FROM  {tableSchema}.{tableName} 
WHERE {incrementalField} >= CAST('{incrementalValue}' as TIMESTAMP)
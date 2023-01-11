SELECT MAX([{incrementalField}]) AS newWatermark, 
		CAST(CASE when count(*) = 0 then 0 else CEILING(count(*)/{chunkSize} + 0.00001) end as int) as batchcount
FROM  [{tableSchema}].[{tableName}] 
WHERE [{incrementalField}] >= {incrementalValue}
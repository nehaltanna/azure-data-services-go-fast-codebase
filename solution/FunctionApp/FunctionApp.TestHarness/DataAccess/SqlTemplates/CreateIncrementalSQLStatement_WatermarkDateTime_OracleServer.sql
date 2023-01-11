SELECT 
	MAX({incrementalField}) AS newWatermark
FROM 
	{tableSchema}.{tableName} 
WHERE {incrementalField} >= CAST('{incrementalValue}' as TIMESTAMP)
SELECT 
	MAX({incrementalField}) AS newWatermark
FROM 
	{tableSchema}.{tableName} 
WHERE {incrementalField} >= {incrementalValue}
SELECT t.NAME AS TableName
    ,s.Name AS SchemaName
    ,p.rows AS RowCounts
    ,CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB
    ,CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00 / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceGB
    ,CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB
    ,CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00 / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceGB
    ,(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
    ,CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
    ,CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00 / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceGB
FROM sys.tables t
INNER JOIN sys.indexes i
    ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p
    ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a
    ON p.partition_id = a.container_id
LEFT JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE t.NAME = '' --TABLE NAME TO CHANGE
GROUP BY t.Name
    ,s.Name
    ,p.Rows
ORDER BY t.Name
 
--------------------------------------------------------------------------------------------------------------------------
 
GO
 
-- To query the size of a table (including indexes)
DECLARE @object SYSNAME
 
SET @object = 'tb_' --Change This
 
SELECT OBJECT_NAME(i.OBJECT_ID) AS TableName
  ,i.NAME AS IndexName
  ,i.index_id AS IndexID
  ,8 * SUM(a.used_pages) AS 'Indexsize(KB)'
  ,8 * SUM(a.used_pages)/1000000 AS 'Indexsize(GB)'
FROM sys.indexes AS i
INNER JOIN sys.partitions AS p
  ON p.OBJECT_ID = i.OBJECT_ID
    AND p.index_id = i.index_id
INNER JOIN sys.allocation_units AS a
  ON a.container_id = p.partition_id
WHERE p.object_id = object_id(@object)
GROUP BY i.OBJECT_ID
  ,i.index_id
  ,i.NAME
ORDER BY OBJECT_NAME(i.OBJECT_ID)
  ,i.index_id
IF OBJECT_ID ('tempdb..#temp') IS NOT NULL
BEGIN
PRINT 'Dropping #temp'
DROP TABLE #temp
END
ELSE
PRINT 'Table doesn''t exist'

DROP TABLE IF EXISTS #TEMP;

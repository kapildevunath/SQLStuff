GO
 
SELECT
  request_session_id AS SessionID,
  resource_database_id AS DatabaseID,
  DB_NAME(resource_database_id) AS DatabaseName,
  resource_type AS ResourceType,
  resource_description AS ResourceDescription,
  resource_associated_entity_id AS ResourceAssociatedEntityID,
  request_mode AS RequestMode,
  request_status AS RequestStatus
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID()
  --AND request_session_id  = 76
 
sp_who2 ACTIVE
 
/*
KILL 54; 
 
KILL 54 WITH STATUSONLY; 
 
GO 
 
 
sp_who2 76
 
DBCC INPUTBUFFER(76)
*/
 
------------------------------------------------------------------------------------------------
 
--Monitor Temp DB
 
--For when working on TempDB, and you never want to be the reason it falls over.
 
SELECT
(SUM(unallocated_extent_page_count)*1.0/128) AS [Free space(MB)]
,(SUM(version_store_reserved_page_count)*1.0/128)  AS [Used Space by VersionStore(MB)]
,(SUM(internal_object_reserved_page_count)*1.0/128)  AS [Used Space by InternalObjects(MB)]
,(SUM(user_object_reserved_page_count)*1.0/128)  AS [Used Space by UserObjects(MB)]
FROM tempdb.sys.dm_db_file_space_usage;
  
SELECT
(SUM(unallocated_extent_page_count)*1.0/128/1024) AS [Free space(GB)]
,(SUM(version_store_reserved_page_count)*1.0/128/1024)  AS [Used Space by VersionStore(GB)]
,(SUM(internal_object_reserved_page_count)*1.0/128/1024)  AS [Used Space by InternalObjects(GB)]
,(SUM(user_object_reserved_page_count)*1.0/128/1024)  AS [Used Space by UserObjects(GB)]
FROM tempdb.sys.dm_db_file_space_usage;
 
SELECT
    [name] AS [File Name],
    CAST(size / 128.0 / 1024.0 AS DECIMAL(10, 2)) AS [Size (GB)],
    CAST(fileproperty([name], 'SpaceUsed') / 128.0 / 1024.0 AS DECIMAL(10, 2)) AS [Used Space (GB)],
    CAST((size - fileproperty([name], 'SpaceUsed')) / 128.0 / 1024.0 AS DECIMAL(10, 2)) AS [Unused Space (GB)],
    [filename] AS [File Path]
FROM sys.sysfiles;
 
 
--Usage of tempDB by spid
 
EXEC tempdb..sp_spaceused '#tb_execution_count_DESC_DISTINCT'
  
select *
from sys.dm_db_session_space_usage
where session_id = 112
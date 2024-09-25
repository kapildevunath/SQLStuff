--SP_HELPDB
--SELECT @@SERVERNAME
--SQL2\INST1
--Info: https://www.red-gate.com/hub/product-learning/redgate-monitor/when-sql-server-performance-goes-bad-implicit-conversions
 
USE 
GO
 
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
 
 
 
DECLARE @dbname SYSNAME = QUOTENAME(DB_NAME());
WITH XMLNAMESPACES
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
   stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Batch,
   + t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)') +'.'
   + t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)')+ '.'
   + t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)') AS The_ColumnReference,
   ic.DATA_TYPE AS ConvertFrom,
   ic.CHARACTER_MAXIMUM_LENGTH AS ConvertFromLength,
   t.value('(@DataType)[1]', 'varchar(128)') AS ConvertTo,
   t.value('(@Length)[1]', 'int') AS ConvertToLength,
   query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
CROSS APPLY stmt.nodes('.//Convert[@Implicit="1"]') AS n(t)
JOIN INFORMATION_SCHEMA.COLUMNS AS ic
   ON QUOTENAME(ic.TABLE_SCHEMA) = t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)')
   AND QUOTENAME(ic.TABLE_NAME) = t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)')
   AND ic.COLUMN_NAME = t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)')
WHERE t.exist('ScalarOperator/Identifier/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1
 
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
 
IF EXISTS --if the session already exists, then delete it. We are assuming you've changed something
  (
  SELECT * FROM sys.server_event_sessions
    WHERE server_event_sessions.name = 'Find_Implicit_Conversions_Affecting_Performance'
  )
  DROP EVENT SESSION Find_Implicit_Conversions_Affecting_Performance ON SERVER;
GO
CREATE EVENT SESSION Find_Implicit_Conversions_Affecting_Performance ON SERVER
  ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.database_name,sqlserver.username,sqlserver.session_nt_username,sqlserver.sql_text)
    WHERE ([sqlserver].[database_name]=N'')) --CHANGE THIS ACCORDING TO YOUR USE
      ADD TARGET package0.ring_buffer
      WITH (STARTUP_STATE=ON)
GO
ALTER EVENT SESSION Find_Implicit_Conversions_Affecting_Performance ON SERVER STATE = START;
 
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
 
DECLARE @Target_Data XML =
          (
          SELECT TOP 1 Cast(xet.target_data AS XML) AS targetdata
            FROM sys.dm_xe_session_targets AS xet
              INNER JOIN sys.dm_xe_sessions AS xes
                ON xes.address = xet.event_session_address
            WHERE xes.name = 'Find_Implicit_Conversions_Affecting_Performance'
              AND xet.target_name = 'ring_buffer'
          );
SELECT
CONVERT(datetime2,
        SwitchOffset(CONVERT(datetimeoffset,the.event_data.value('(@timestamp)[1]', 'datetime2')),
        DateName(TzOffset, SYSDATETIMEOFFSET()))) AS datetime_local,
the.event_data.value('(data[@name="compile_time"]/value)[1]', 'nvarchar(5)') AS [Compile_Time],
CASE the.event_data.value('(data[@name="convert_issue"]/value)[1]', 'int')
                  WHEN 1 THEN 'cardinality estimate'ELSE 'seek plan'END  AS [Convert_Issue],
the.event_data.value('(data[@name="expression"]/value)[1]', 'nvarchar(max)') AS [Expression],
the.event_data.value('(action[@name="database_name"]/value)[1]', 'sysname') AS [Database],
the.event_data.value('(action[@name="username"]/value)[1]', 'sysname') AS Username,
the.event_data.value('(action[@name="session_nt_username"]/value)[1]', 'sysname') AS [Session NT Username],
the.event_data.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS [SQL Context]
FROM @Target_Data.nodes('//RingBufferTarget/event') AS the (event_data)
 
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
 
SELECT Count(*)
  FROM sys.dm_exec_query_stats qStats
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS execution_plan
  WHERE Cast(query_plan AS VARCHAR(MAX)) LIKE ('%CONVERT_IMPLICIT%')
    AND last_execution_time > DateAdd(MINUTE, -10, GetDate())
    AND max_elapsed_time > 100000
    AND execution_plan.dbid =Db_Id()
 
 
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
 
SELECT max_elapsed_time, execution_plan.[dbid],
  Db_Name(execution_plan.[dbid]), SQL_Text.text
  FROM sys.dm_exec_query_stats qStats
    OUTER APPLY sys.dm_exec_sql_text(sql_handle) SQL_Text
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS execution_plan
  WHERE Cast(query_plan AS VARCHAR(MAX)) LIKE ('%CONVERT_IMPLICIT%')
    AND last_execution_time > DateAdd(MINUTE, -10, GetDate())
    AND max_elapsed_time > 100000
    AND execution_plan.dbid =Db_Id()
  ORDER BY max_elapsed_time DESC;
 
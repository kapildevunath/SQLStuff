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
  --AND request_session_id =
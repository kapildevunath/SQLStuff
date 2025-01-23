SELECT
    local_net_address AS IPAddress,
    local_tcp_port AS Port
FROM
    sys.dm_exec_connections
WHERE
    session_id = @@SPID;
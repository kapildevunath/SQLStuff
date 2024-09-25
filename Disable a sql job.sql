USE msdb;
GO

DECLARE @JOBNAME VARCHAR (200)

SET  @JOBNAME =  (SELECT [Name] FROM dbo.sysjobs WHERE name LIKE '%%')

IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = @jobName)
BEGIN
    -- Disable the SQL Server job
    EXEC dbo.sp_update_job
        @job_name = @jobName,
        @enabled = 0;
    PRINT 'Job disabled successfully.';
END
ELSE
BEGIN
    PRINT 'Job does not exist.';
END
GO
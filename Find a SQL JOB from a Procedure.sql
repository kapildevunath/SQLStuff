USE 
GO
SELECT 
j.name AS 'Job Name', s.step_name AS 'Step Name', s.command AS 'Command'
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
WHERE s.command LIKE '%pr_%'
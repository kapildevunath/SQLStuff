Example:

SELECT * 
  FROM #TempPD pd
  JOIN dbo.tb_PTSNet_PlayerAccount pa 
    ON pd.PlayerAccountID = pa.PlayerAccountID 
   AND pa.GamingServerID = pa.GamingServerID
 WHERE pa.UserTypeID = 0 -- Real Player


UPDATE dbo.tb_PTSNet_Maintenance_Job
   SET ScheduleID = 6
 WHERE SourceProcedure = 'dbo.pr_PTSNet_Maintenance_rerun_playerdetail'
   AND IsActive = 1

SELECT column
  FROM  table
 WHERE 1 = 1

should be

SELECT column
  FROM  table
 WHERE 1 = 1

(SELECT FROM WHERE -- all right aligned)
USE ;
GO

--  Author:
--  Date: 07-August-2024
--  Notes:

--  Tables affected:
--  1. dbo.tb_
--  2. dbo.tb_

SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON;
GO

BEGIN TRY

  DECLARE @ScheduleId INT = 6,
          @SourceProcedure VARCHAR(256) = 'dbo.pr_PTSNet_Maintenance_rerun_playerdetail';

  IF NOT EXISTS (SELECT 1
                    FROM dbo.tb_PTSNet_Maintenance_JobSchedule
                   WHERE ScheduleId = @ScheduleId)
  BEGIN

    BEGIN TRANSACTION;

      -- Add the schedule that isn't there...
      INSERT INTO dbo.tb_ ()
      VALUES ();

      --...and reference it
      UPDATE dbo.tb_
         SET 
       WHERE ;

     IF (@@ROWCOUNT <> 1)
     BEGIN
       RAISERROR(N'Incorrect number of dbp.tb_ rows updated.', 16, -1);
     END;

    COMMIT TRANSACTION;

  END;

  -- Optional: output changes
  SELECT 
    FROM dbo.tb_
   WHERE ;

  SELECT 
    FROM dbo.tb_
   WHERE ;

END TRY
BEGIN CATCH

  IF (XACT_STATE() <> 0)
  BEGIN
    ROLLBACK TRANSACTION;
  END;

  DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_SEVERITY(),
          @ErrorState INT = ERROR_STATE(),
          @ErrorSeverity INT = ERROR_MESSAGE();

  RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH;
GO

/*
Made some changes, can see and ask questions:
Removed tabs (NO TABS)
Added some validation after the update
Collapsed extra declares, lines, indents
Used vars over repeating scalars
None of these are functional but good, clean SQL to abide by. 
*/



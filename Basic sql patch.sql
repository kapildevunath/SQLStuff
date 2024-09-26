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
          @SourceProcedure VARCHAR(256) = 'dbo.';

  IF NOT EXISTS (SELECT 1
                    FROM dbo.
                   WHERE  = )
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
       RAISERROR(N'Incorrect number of dbo.tb_ rows updated.', 16, -1);
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

  DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
          @ErrorState INT = ERROR_STATE(),
          @ErrorSeverity INT = ERROR_SEVERITY();

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



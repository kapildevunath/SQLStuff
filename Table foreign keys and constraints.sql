DECLARE @TABLE VARCHAR(100);
SET @TABLE = 'tb_'

SELECT tc.table_name [Main Table], tc.constraint_name, tc.constraint_type
      ,kcu.column_name, kcu.table_name, kcu.column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON (tc.constraint_name = kcu.constraint_name)
WHERE tc.table_name = @TABLE
/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Look at buffers
 * 
 * This script is free software: you can redistribute it and/or 
 * modify it under the terms of the GNU General Public License as 
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

USE SSISDB
GO

-- Run a package... and look at the buffers
DECLARE @execution_id BIGINT
EXEC [catalog].[create_execution] 
	@package_name = N'010_Buffers.dtsx'
	, @execution_id = @execution_id OUTPUT
	, @folder_name = N'SSISDemo'
	, @project_name = N'030_Troubleshooting'
	, @use32bitruntime = False
	, @reference_id = NULL
EXEC [catalog].[set_execution_parameter_value]
	@execution_id
	, @object_type = 50
	, @parameter_name = N'LOGGING_LEVEL'
	, @parameter_value = 1
EXEC [catalog].[start_execution] 
	@execution_id
GO


-- Is it running?
SELECT * 
FROM catalog.operations
WHERE status = 2


-- Look at the buffers and spill to disk
SELECT * 
FROM [catalog].dm_execution_performance_counters(NULL)


-- Possible solutions to spooling to disk:
-- Change DefaultBufferSize & DefaultBufferMaxRows
-- Add more memory, if spooling to disk

-- Change TEMP/TMP environment variable
-- C:\> echo %TEMP%

-- Ask developers to push down to T-SQL
-- Sort -> ORDER BY
-- Aggregate -> GROUP BY
-- Merge join -> INNER JOIN/LEFT OUTER JOIN


-- Stop package... no need to wait for it!
DECLARE @operation_id INT = 
	(SELECT MAX(operation_id) 
	FROM [catalog].[operations])

EXEC [catalog].[stop_operation] @operation_id


-- The end
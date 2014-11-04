/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Create a data dump
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
-- Execute 020_SlowPackage.dtsx via T-SQL - LOGGING_LEVEL = 1 (basic)

-- Find the environment reference
DECLARE @environment_references_id BIGINT 
SELECT @environment_references_id = reference_id
FROM catalog.environment_references e
INNER JOIN catalog.projects p
ON e.project_id = p.project_id
WHERE e.environment_name = 'Production'
AND p.name = '030_Troubleshooting'

-- Create execution
DECLARE @execution_id BIGINT
EXEC catalog.create_execution 
	@package_name=N'020_SlowPackage.dtsx'
	, @execution_id = @execution_id OUTPUT
	, @folder_name = N'SSISDemo'
	, @project_name = N'030_Troubleshooting'
	, @use32bitruntime = False
	, @reference_id = @environment_references_id

-- Basic logging level
DECLARE @logging_level smallint = 1

-- Assign logging level
EXEC catalog.set_execution_parameter_value 
	@execution_id
	, @object_type=50
	, @parameter_name = N'LOGGING_LEVEL'
	, @parameter_value = @logging_level

-- Start execution
EXEC catalog.start_execution @execution_id
GO


-- Is it running? Find the execution id
SELECT *
FROM catalog.executions
WHERE status = 2
GO

-- Get an execution_dump
EXEC catalog.create_execution_dump 
	@execution_id = XXX
GO

-- Go take a look at 
-- C:\Program Files\Microsoft SQL Server\120\Shared\ErrorDumps


-- Stop package
DECLARE @operation_id INT = (SELECT MAX(operation_id) 
							FROM [catalog].[operations]
							WHERE status = 2)

EXEC [catalog].[stop_operation] @operation_id


-- The end
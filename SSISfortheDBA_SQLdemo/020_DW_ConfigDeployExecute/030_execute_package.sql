/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Execute SSIS package
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



-- 1) Execute the package via SSMS
-- -> Show the report


-- 2) Execute via T-SQL - LOGGING_LEVEL = 1 (basic)

USE SSISDB
GO

-- Find the environment reference
DECLARE @environment_references_id BIGINT 

SELECT @environment_references_id = reference_id 
FROM catalog.environment_references
WHERE environment_name = 'Production'

-- Create execution
DECLARE @execution_id BIGINT
EXEC catalog.create_execution 
	@package_name=N'Master.dtsx'
	, @execution_id = @execution_id OUTPUT
	, @folder_name = N'SSISdemo'
	, @project_name = N'020_DataWarehouse'
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


-- Show Active Operations
-- -> Integrations Services Catalogs 
-- -> Right Click on SSISDB -> Active Operations



-- The end...
/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Troubleshoot SSIS package
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

-- 1) Execute DimReseller.dtsx via T-SQL - LOGGING_LEVEL = 1 (basic)

-- Find the environment reference
DECLARE @environment_references_id BIGINT 
SELECT @environment_references_id = reference_id
FROM catalog.environment_references e
INNER JOIN catalog.projects p
ON e.project_id = p.project_id
WHERE e.environment_name = 'Production'
AND p.name = '020_DataWarehouse'

-- Create execution
DECLARE @execution_id BIGINT
EXEC catalog.create_execution 
	@package_name=N'DimReseller.dtsx'
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


-- Is it running?
SELECT * 
FROM catalog.operations
WHERE status = 2


-- Did it fail?
SELECT * 
FROM catalog.operations
WHERE status = 4


-- Okay what happened? Let's use Jamie's magic query
SELECT event_message_id
	, message
	, package_name
	, event_name
	, message_source_name
	, package_path
	, execution_path
	, message_type
	, message_source_type
FROM (SELECT  em.*
	FROM catalog.event_messages em
	WHERE em.operation_id = (SELECT MAX(execution_id) FROM catalog.executions)
		AND event_name NOT LIKE '%Validate%'
	) q
/* Put in whatever WHERE predicates you might like*/
WHERE event_name = 'OnError'
--WHERE	package_name = 'Package.dtsx'
--WHERE execution_path LIKE '%<some executable>%'
ORDER BY message_time DESC



-- Take the error messages out into Notepad and take a 
-- look. Use WordWrap.








-- Hmmm... it should work... why is the lookup not working?


-- Let's try a data tap! 


-- Find the environment reference
DECLARE @environment_references_id BIGINT 
SELECT @environment_references_id = reference_id 
FROM catalog.environment_references e
INNER JOIN catalog.projects p
ON e.project_id = p.project_id
WHERE environment_name = 'Production'
AND p.name = '020_DataWarehouse'

-- Create execution
DECLARE @execution_id BIGINT
EXEC catalog.create_execution 
	@package_name=N'DimReseller.dtsx'
	, @execution_id = @execution_id OUTPUT
	, @folder_name = N'SSISdemo'
	, @project_name = N'020_DataWarehouse'
	, @use32bitruntime = False
	, @reference_id = @environment_references_id

-- Add the data tap
--
-- To locate the identification string, in SQL Server 
-- Data Tools right-click the path between two data flow components 
-- and then click Properties. 
-- The IdentificationString property appears in the Properties 
-- window.

-- We could ask our developer to find the @dataflow_path_id_string 
-- for us... but we don't want to disturb them.

-- Go to Visual Studio and look for the IdentificationString 
-- property in the DimReseller.dtsx

EXEC catalog.add_data_tap 
	@execution_id = @execution_id
	, @task_package_path = '\Package\Data Flow Task'
	, @dataflow_path_id_string 
		= 'Paths[Data Clean.Derived Column Output]'
	, @data_filename = 'DimReseller.csv'

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


-- Are we done yet?
SELECT * 
FROM catalog.operations
WHERE status = 2


-- Go take a look at: 
-- C:\Program Files\Microsoft SQL Server\120\DTS\DataDumps\




--What is wrong?























-- It is not the correct query! 
-- It's the DimProduct query, instead of the DimReseller query.
-- We need to get that fixed before we can run it...


-- The end
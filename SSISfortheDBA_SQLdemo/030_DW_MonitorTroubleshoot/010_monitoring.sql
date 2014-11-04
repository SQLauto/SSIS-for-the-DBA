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



-- 1) Show reports



USE SSISDB
GO


-- 2) Show executions
-- Displays the instances of package execution in the 
-- Integration Services catalog. 
-- Packages that are executed with the Execute Package 
-- task run in the same instance of execution as the 
-- parent package.
SELECT * 
FROM catalog.executions
ORDER BY execution_id DESC


-- Displays a row for each executable in the specified execution
-- An executable is a task or container that you add to the 
-- control flow of a package.
SELECT *
FROM catalog.executables
ORDER BY execution_id DESC, executable_id DESC



-- Displays a row for each executable that is run, including 
-- each iteration of an executable.
SELECT *
FROM catalog.executable_statistics
ORDER BY execution_id DESC, executable_id DESC


-- Show execution of all packages, including duration and result
-- Based on http://paultebraak.wordpress.com/2013/03/14/ssis-2012-execution-reporting/
SELECT es.execution_duration 
	, CASE es.execution_result
		WHEN 0 THEN 'Success'
		WHEN 1 THEN 'Failure'
		WHEN 2 THEN 'Completion'
		WHEN 3 THEN 'Cancelled'
	END AS execution_result_description
	, executable_name
	, e.*
	, es.statistics_id 
	, es.execution_result 
	, CONVERT(DATETIME, es.start_time) AS start_time 
	, CONVERT(DATETIME, es.end_time) AS end_time 
FROM catalog.executables e
LEFT OUTER JOIN catalog.executable_statistics es 
ON e.executable_id = es.executable_id
	AND e.execution_id = es.execution_id
WHERE package_path = '\Package'
ORDER BY execution_id DESC, executable_id DESC


-- Get event messages for latest execution_id
-- From: http://sqlblog.com/blogs/jamie_thomson/archive/2012/10/17/querying-the-ssis-catalog-here-s-a-handy-query.aspx
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
--WHERE	event_name = 'OnError'
--WHERE	package_name = 'Package.dtsx'
--WHERE execution_path LIKE '%<some executable>%'
ORDER BY message_time DESC



-- 2) Execute with Verbose logging level
-- -> And look for DiagnosticEx

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
	@package_name=N'Master.dtsx'
	, @execution_id = @execution_id OUTPUT
	, @folder_name = N'SSISdemo'
	, @project_name = N'020_DataWarehouse'
	, @use32bitruntime = False
	, @reference_id = @environment_references_id

-- Verbose logging level
DECLARE @logging_level smallint = 3

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




-- Get event messages for latest execution_id
--
-- Look for DiagnosticEx for DimProduct
SELECT event_message_id
	, message_source_name
	, CAST(message AS xml)
	, package_name
	, event_name
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
WHERE event_name = 'DiagnosticEx'
--WHERE	package_name = 'Package.dtsx'
--WHERE execution_path LIKE '%<some executable>%'
ORDER BY message_time DESC


-- The end


/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Deploy SSIS projects
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

-- 1) Have the developer make an .ispac file in Visual Studio
-- -> You could let your developers deploy directly from 
--    Visual Studio (not recommended)


-- 2) Deploy via SSMS
-- -> Integration Services Catalogs -> SSISDB -> SSISdemo
-- -> Right click Projects -> Deploy Project
-- -> Choose Project deployment file
-- -> Choose destination


-- 3) Deploy via T-SQL
-- From: http://msdn.microsoft.com/en-us/library/jj820152.aspx

USE SSISDB
GO

DECLARE @ProjectBinary AS VARBINARY(MAX)
DECLARE @operation_id AS BIGINT

SET @ProjectBinary = (
	SELECT * 
	FROM OPENROWSET(
		BULK 'c:\ssisdemo\020_DataWarehouse.ispac'
		, SINGLE_BLOB) AS BinaryData
	)

EXEC catalog.deploy_project 
	@folder_name = 'SSISdemo'
	, @project_name = '020_DataWarehouse'
	, @Project_Stream = @ProjectBinary
	, @operation_id = @operation_id OUT


-- Project versions
SELECT *
FROM catalog.object_versions
WHERE object_name = '020_DataWarehouse'


-- Restore project to earlier version
EXEC catalog.restore_project 
	@folder_name = 'SSISdemo'
    , @project_name = '020_DataWarehouse'
    , @object_version_lsn = 2


-- Project versions again - notice the restored_by 
-- and last_restored_time
SELECT *
FROM catalog.object_versions


-- Check out the object_version_lsn for our project
SELECT *
FROM catalog.projects


-- Configure Production environment and connection strings
EXEC catalog.create_environment
	@environment_name = N'Production'
	, @environment_description = N'Environment for production server'
	, @folder_name = N'SSISdemo'
GO

DECLARE @DWConnection sql_variant = 
	N'Data Source=SQL2014DEMO01\SQLDEMO01;Initial Catalog=AdventureWorksDW2014;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;'

EXEC catalog.create_environment_variable
	@variable_name = N'DWConnection'
	, @sensitive = False
	, @description = N''
	, @environment_name = N'Production'
	, @folder_name = N'SSISdemo'
	, @value = @DWConnection
	, @data_type = N'String'
GO

DECLARE @SourceConnection sql_variant = 
	N'Data Source=SQL2014DEMO01\SQLDEMO01;Initial Catalog=AdventureWorks2014;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;'

EXEC catalog.create_environment_variable
	@variable_name = N'SourceConnection'
	, @sensitive = False
	, @description = N''
	, @environment_name = N'Production'
	, @folder_name = N'SSISdemo'
	, @value = @SourceConnection
	, @data_type = N'String'
GO

-- Reference environment to the project
DECLARE @reference_id BIGINT
EXEC catalog.create_environment_reference
	@environment_name = N'Production'
	, @reference_id=@reference_id OUTPUT
	, @project_name=N'020_DataWarehouse'
	, @folder_name=N'SSISdemo'
	, @reference_type=R
GO

-- Set connections for the project to use the values
-- in the environment
EXEC catalog.set_object_parameter_value
	@object_type = 20
	, @parameter_name = N'CM.AdventureWorks2014.ConnectionString'
	, @object_name = N'020_DataWarehouse'
	, @folder_name = N'SSISdemo'
	, @project_name = N'020_DataWarehouse'
	, @value_type = R
	, @parameter_value = N'SourceConnection'
GO

EXEC catalog.set_object_parameter_value
	@object_type = 20
	, @parameter_name = N'CM.AdventureWorksDW2014.ConnectionString'
	, @object_name = N'020_DataWarehouse'
	, @folder_name = N'SSISdemo'
	, @project_name = N'020_DataWarehouse'
	, @value_type = R
	, @parameter_value = N'DWConnection'
GO

-- The end
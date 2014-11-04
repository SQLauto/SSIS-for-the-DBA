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

 -- Deploy via T-SQL
 -- http://msdn.microsoft.com/en-us/library/jj820152.aspx

USE SSISDB
GO

DECLARE @ProjectBinary AS VARBINARY(MAX)
DECLARE @operation_id AS BIGINT

SET @ProjectBinary = (
	SELECT * 
	FROM OPENROWSET(
		BULK 'c:\ssisdemo\030_Troubleshooting.ispac'
		, SINGLE_BLOB) AS BinaryData
	)

EXEC catalog.deploy_project 
	@folder_name = 'SSISdemo'
	, @project_name = '030_Troubleshooting'
	, @Project_Stream = @ProjectBinary
	, @operation_id = @operation_id OUT



-- Reference environment to the project
DECLARE @reference_id BIGINT
EXEC catalog.create_environment_reference
	@environment_name = N'Production'
	, @reference_id=@reference_id OUTPUT
	, @project_name=N'030_Troubleshooting'
	, @folder_name=N'SSISdemo'
	, @reference_type=R
GO

-- Set connections for the project to use the values
-- in the environment
EXEC catalog.set_object_parameter_value
	@object_type = 20
	, @parameter_name = N'CM.AdventureWorks2014.ConnectionString'
	, @object_name = N'030_Troubleshooting'
	, @folder_name = N'SSISdemo'
	, @project_name = N'030_Troubleshooting'
	, @value_type = R
	, @parameter_value = N'SourceConnection'
GO

EXEC catalog.set_object_parameter_value
	@object_type = 20
	, @parameter_name = N'CM.AdventureWorksDW2014.ConnectionString'
	, @object_name = N'030_Troubleshooting'
	, @folder_name = N'SSISdemo'
	, @project_name = N'030_Troubleshooting'
	, @value_type = R
	, @parameter_value = N'DWConnection'
GO

-- The end
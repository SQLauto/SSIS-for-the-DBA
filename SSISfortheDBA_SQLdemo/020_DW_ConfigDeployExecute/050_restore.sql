/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Restore SSISDB
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

-- CONNECT TO SQLDEMO02 INSTANCE!
-- Are you on SQLDEMO02?!? Are you sure? Are you really sure? :)
IF SERVERPROPERTY('InstanceName') != 'SQLDEMO02'
	RAISERROR ('Connect to the right instance, mkay!', 18, 16);
ELSE
	PRINT 'GO GO GO!'



-- Create a SSIS Catalog in SSMS
-- 
-- This is by far the easiest way to get it setup correctly
-- 
-- Alternative there are several other steps needed.
-- See: http://msdn.microsoft.com/en-us/library/hh213291.aspx
-- and: http://blogs.msdn.com/b/mattm/archive/2012/03/23/ssis-catalog-backup-and-restore.aspx



USE master
GO

-- Restore database
RESTORE DATABASE [SSISDB] 
FROM DISK = N'C:\ssisdemo\SSISDB.bak' 
WITH FILE = 1, 
MOVE N'data' TO N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLDEMO02\MSSQL\DATA\SSISDB.mdf',  
MOVE N'log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLDEMO02\MSSQL\DATA\SSISDB.ldf',  
REPLACE,  STATS = 5





USE SSISDB
GO

-- This works fine, as it does not need the database master key
SELECT *
FROM [catalog].projects




-- Executing a package however...
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










-- Restore database master key
--
-- This error is perfectly OK:
-- "The current master key cannot be decrypted. 
-- The error was ignored because the FORCE option 
-- was specified.

RESTORE MASTER KEY 
FROM FILE = 'c:\ssisdemo\SSISDBKey'
DECRYPTION BY PASSWORD = 'P@ssw0rd!' 
	-- 'Password used to encrypt the master key 
	-- during SSISDB backup'
ENCRYPTION BY PASSWORD = 'NewP@ssw0rd' 
	-- 'New Password'
FORCE
GO


-- Remap user to login
ALTER USER ##MS_SSISServerCleanupJobUser##
WITH LOGIN = ##MS_SSISServerCleanupJobLogin##
GO


-- Check if schema build and assembly build is 
-- compatible. Will raise an error, if they are not
EXEC [catalog].[check_schema_version] @use32bitruntime = 0




-- We can now execute a package...
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



-- Yay!
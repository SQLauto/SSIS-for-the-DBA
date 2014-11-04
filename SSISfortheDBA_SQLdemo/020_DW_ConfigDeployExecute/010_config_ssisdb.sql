/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Setup and configure SSISDB
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

-- Enable CLR
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO

-- Create SSIS Catalog
-- In SSMS:
-- -> Right click on Integration Services Catalogs 
-- -> Create Catalog 
-- -> Check Enable automatic execution of Integration Services 
--    stored procedure at SQL Server startup - executes 
--    catalog.startup
--    (The stored procedure fixes the status of any packages there 
--    were running if and when the SSIS server instance goes down)
-- -> Choose a very secret password 
--
-- ... or use the PowerShell script from 
-- http://msdn.microsoft.com/en-us/library/gg471509.aspx


USE SSISDB
GO

-- Create a folder for the SSIS demo project
EXEC catalog.create_folder @folder_name = N'SSISdemo'

EXEC catalog.set_folder_description 
	@folder_name = N'SSISdemo'
	, @folder_description=N'SSIS for the DBA demo'


-- The end
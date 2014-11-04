/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Clean up environment
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
 
 -- Remove SSISDBS
EXEC xp_cmdshell 'powershell.exe -file "c:\ssisdemo\remove_ssisdb.ps1" -nologo'  

-- Delete datadumps
EXEC xp_cmdshell 'DEL /F /Q "C:\Program Files\Microsoft SQL Server\120\DTS\DataDumps\*"'

-- Delete errordumps
EXEC xp_cmdshell 'DEL /F /Q "C:\Program Files\Microsoft SQL Server\120\Shared\ErrorDumps\*"'

-- Delete ssisdemo files
EXEC xp_cmdshell 'DEL /F /Q /S "C:\ssisdemo\*"'
GO

-- Disable CLR
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 0;
GO
RECONFIGURE;
GO
sp_configure 'show advanced options', 0;
GO
RECONFIGURE;

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'DW Update')
	EXEC msdb.dbo.sp_delete_job @job_name=N'DW Update', @delete_history = 1, @delete_unused_schedule=1

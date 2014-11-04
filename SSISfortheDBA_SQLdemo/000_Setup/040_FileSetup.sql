/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Preparing files
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

-- Enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO

-- Set base dir for the demos - end with \
DECLARE @basedir VARCHAR(8000)
SET @basedir = '\\vmware-host\Shared Folders\201410 - SSIS for the DBA - PASS Summit 2014\Demo - SSIS for the DBA\'


EXEC xp_cmdshell 'IF exist c:\ssisdemo\ ( echo ssisdemo exists ) ELSE ( mkdir c:\ssisdemo && echo ssisdemo created)'

EXEC xp_cmdshell 'IF exist c:\ssisdemo\data\ ( echo ssisdemo\data exists ) ELSE ( mkdir c:\ssisdemo\data && echo ssisdemo\data created)'

EXEC xp_cmdshell 'IF exist c:\ssisdemo\archive\ ( echo ssisdemo\archive exists ) ELSE ( mkdir c:\ssisdemo\archive && echo ssisdemo\archive created)'


EXEC xp_cmdshell 'IF exist c:\ssisdemo\blobbuffers\ ( echo ssisdemo\blobbuffers exists ) ELSE ( mkdir c:\ssisdemo\blobbuffers && echo ssisdemo\blobbuffers created)'

EXEC xp_cmdshell 'IF exist c:\ssisdemo\inrowbuffers\ ( echo ssisdemo\inrowbuffers exists ) ELSE ( mkdir c:\ssisdemo\inrowbuffers && echo ssisdemo\inrowbuffers created)'



DECLARE @sql VARCHAR(8000)

SET @sql = 'copy "' + @basedir + 'Data\*" c:\ssisdemo\data'
EXEC xp_cmdshell @sql

SET @sql = 'copy "' + @basedir + 'SSISfortheDBA\020_DataWarehouse\bin\Development\*" c:\ssisdemo'
EXEC xp_cmdshell @sql

SET @sql = 'copy "' + @basedir + 'SSISfortheDBA\030_Troubleshooting\bin\Development\*" c:\ssisdemo'
EXEC xp_cmdshell @sql


SET @sql = 'copy "' + @basedir + 'SSISfortheDBA_SQLdemo\999_Cleanup\remove_ssisdb.ps1" c:\ssisdemo'
EXEC xp_cmdshell @sql

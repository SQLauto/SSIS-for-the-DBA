/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Backup SSISDB
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

-- Backup SSISDB
BACKUP DATABASE [SSISDB] 
TO DISK = 'c:\ssisdemo\SSISDB.bak' 
WITH COPY_ONLY, NOFORMAT, INIT, STATS = 10, CHECKSUM
GO

-- Backup database master key
BACKUP MASTER KEY TO FILE = 'c:\ssisdemo\SSISDBKey'
ENCRYPTION BY PASSWORD = 'P@ssw0rd!'
GO

-- Now time to restore it...
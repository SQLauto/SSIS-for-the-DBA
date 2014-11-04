/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Look at wait stats
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


-- So... the package is slow! Is it SSIS or something else?

-- Take a look at 010_SlowPackage.dtsx in SSDT


-- Clear wait stats - be careful about doing this in production
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR)
GO

-- Let's chear the clean buffers from the buffer pool
-- Don't do this in production! For testing purpose only.
DBCC DROPCLEANBUFFERS
GO


-- Run a slow package... is it SSIS or the environment?
DECLARE @execution_id BIGINT
EXEC [catalog].[create_execution] @package_name = N'020_SlowPackage.dtsx',
    @execution_id = @execution_id OUTPUT, @folder_name = N'SSISDemo',
    @project_name = N'030_Troubleshooting', @use32bitruntime = False,
    @reference_id = NULL
EXEC [catalog].[set_execution_parameter_value] @execution_id,
    @object_type = 50, @parameter_name = N'LOGGING_LEVEL',
    @parameter_value = 1
EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO


-- Waiting for 300,000 rows to be read/written
SELECT * FROM [catalog].dm_execution_performance_counters(NULL)


-- How long did it take?
SELECT execution_id, [status], package_name
	, CONVERT(DECIMAL(10,2), (DATEDIFF(MILLISECOND, start_time, end_time)/1000.0)) AS ExecutionTimeSeconds
FROM [catalog].[executions]
WHERE execution_id = (SELECT MAX(execution_id) FROM [catalog].[executions])
ORDER BY execution_id DESC
GO


-- Execution time: 40.86

-- What was SQL Server waiting for?

-- From Glenn Berry's SQL Server 2014 Diagnostic Information Queries
-- http://sqlserverperformance.wordpress.com/
-- Isolate top waits for server instance since last restart or 
-- statistics clear (Top Waits)
WITH Waits
AS (SELECT wait_type, CAST(wait_time_ms / 1000. AS DECIMAL(12, 2)) AS [wait_time_s],
	CAST(100. * wait_time_ms / SUM(wait_time_ms) OVER () AS DECIMAL(12,2)) AS [pct],
	ROW_NUMBER() OVER (ORDER BY wait_time_ms DESC) AS rn
	FROM sys.dm_os_wait_stats WITH (NOLOCK)
	WHERE wait_type NOT IN (N'CLR_SEMAPHORE', N'LAZYWRITER_SLEEP', N'RESOURCE_QUEUE',N'SLEEP_TASK', N'FT_IFTSHC_MUTEX',
			                N'SLEEP_SYSTEMTASK', N'SQLTRACE_BUFFER_FLUSH', N'WAITFOR', N'LOGMGR_QUEUE',
			                N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH', N'XE_TIMER_EVENT',
			                N'BROKER_TO_FLUSH', N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT', N'CLR_AUTO_EVENT',
			                N'DISPATCHER_QUEUE_SEMAPHORE' ,N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'XE_DISPATCHER_WAIT',
			                N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'ONDEMAND_TASK_QUEUE',
			                N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP', N'DIRTY_PAGE_POLL',
			                N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',N'SP_SERVER_DIAGNOSTICS_SLEEP',
							N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
							N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE',
							N'PWAIT_ALL_COMPONENTS_INITIALIZED')),
Running_Waits 
AS (SELECT W1.wait_type, wait_time_s, pct,
	SUM(pct) OVER(ORDER BY pct DESC ROWS UNBOUNDED PRECEDING) AS [running_pct]
	FROM Waits AS W1)
SELECT wait_type, wait_time_s, pct, running_pct
FROM Running_Waits
WHERE running_pct - pct <= 99
ORDER BY running_pct
OPTION (RECOMPILE);


-- Explain ASYNC_NETWORK_IO






-- Let's optimize the package, by removing the slow script component
-- Take a look at the package in SSDT, and execute the package again


-- Clear wait stats - be careful about doing this in production
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR)
GO

-- Let's chear the clean buffers from the buffer pool
DBCC DROPCLEANBUFFERS
GO


-- Run a package... is it SSIS or the environment?
DECLARE @execution_id BIGINT
EXEC [catalog].[create_execution] @package_name = N'030_FastPackage.dtsx',
    @execution_id = @execution_id OUTPUT, @folder_name = N'SSISDemo',
    @project_name = N'030_Troubleshooting', @use32bitruntime = False,
    @reference_id = NULL
EXEC [catalog].[set_execution_parameter_value] @execution_id,
    @object_type = 50, @parameter_name = N'LOGGING_LEVEL',
    @parameter_value = 1
EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO



-- Waiting for 300,000 rows to be read/written
SELECT * FROM [catalog].dm_execution_performance_counters(NULL)


-- How long did it take?
SELECT execution_id, [status], package_name
	, CONVERT(DECIMAL(10,2), (DATEDIFF(MILLISECOND, start_time, end_time)/1000.0)) AS ExecutionTimeSeconds
FROM [catalog].[executions]
WHERE execution_id = (SELECT MAX(execution_id) FROM [catalog].[executions])
ORDER BY execution_id DESC
GO

-- Execution time: ________2.09


-- From Glenn Berry's SQL Server 2014 Diagnostic Information Queries
-- http://sqlserverperformance.wordpress.com/
-- Isolate top waits for server instance since last restart or 
-- statistics clear (Top Waits)
WITH Waits
AS (SELECT wait_type, CAST(wait_time_ms / 1000. AS DECIMAL(12, 2)) AS [wait_time_s],
	CAST(100. * wait_time_ms / SUM(wait_time_ms) OVER () AS DECIMAL(12,2)) AS [pct],
	ROW_NUMBER() OVER (ORDER BY wait_time_ms DESC) AS rn
	FROM sys.dm_os_wait_stats WITH (NOLOCK)
	WHERE wait_type NOT IN (N'CLR_SEMAPHORE', N'LAZYWRITER_SLEEP', N'RESOURCE_QUEUE',N'SLEEP_TASK', N'FT_IFTSHC_MUTEX',
			                N'SLEEP_SYSTEMTASK', N'SQLTRACE_BUFFER_FLUSH', N'WAITFOR', N'LOGMGR_QUEUE',
			                N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH', N'XE_TIMER_EVENT',
			                N'BROKER_TO_FLUSH', N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT', N'CLR_AUTO_EVENT',
			                N'DISPATCHER_QUEUE_SEMAPHORE' ,N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'XE_DISPATCHER_WAIT',
			                N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'ONDEMAND_TASK_QUEUE',
			                N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP', N'DIRTY_PAGE_POLL',
			                N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',N'SP_SERVER_DIAGNOSTICS_SLEEP',
							N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
							N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE',
							N'PWAIT_ALL_COMPONENTS_INITIALIZED')),
Running_Waits 
AS (SELECT W1.wait_type, wait_time_s, pct,
	SUM(pct) OVER(ORDER BY pct DESC ROWS UNBOUNDED PRECEDING) AS [running_pct]
	FROM Waits AS W1)
SELECT wait_type, wait_time_s, pct, running_pct
FROM Running_Waits
WHERE running_pct - pct <= 99
ORDER BY running_pct
OPTION (RECOMPILE);





-- Explain:
-- PAGEIOLATCH_EX - a thread is waiting for a data page to be read 
--   into the buffer pool from disk
-- ASYNC_NETWORK_IO - Waiting for SSIS
-- PAGEIOLATCH_SH - a thread is waiting for a data page to be read 
--   into the buffer pool from disk
-- WRITELOG - log management system waiting for a log flush to disk. 
--   It commonly indicates that the I/O subsystem can’t keep up with --   the log flush volume




-- The end
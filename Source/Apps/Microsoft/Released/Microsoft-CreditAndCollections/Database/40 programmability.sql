SET ANSI_NULLS              ON;
SET ANSI_PADDING            ON;
SET ANSI_WARNINGS           ON;
SET ANSI_NULL_DFLT_ON       ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER       ON;
go

CREATE PROCEDURE cc.sp_get_replication_counts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SUBSTRING(ta.name, CHARINDEX('_',ta.name)+1, CHARINDEX('_M',ta.name)-CHARINDEX('_',ta.name)-1) AS EntityName, SUM(pa.rows) AS [Count]
    FROM sys.tables ta INNER JOIN sys.partitions pa ON pa.OBJECT_ID = ta.OBJECT_ID
                       INNER JOIN sys.schemas sc ON ta.schema_id = sc.schema_id
    WHERE
        sc.name='dbo' AND ta.is_ms_shipped = 0 AND pa.index_id IN (0,1) AND
        ta.name LIKE '%CustCollectionsBIMeasurements_%'
    GROUP BY ta.name
    ORDER BY ta.name;
END;
go


CREATE PROCEDURE cc.sp_get_pull_status
AS
BEGIN
    SET NOCOUNT ON;
    
    --InitialPullComplete statuses
    -- -1 -> Initial State
    -- 1 -> Data is present but not complete
    -- 2 -> Data pull is complete
    -- 3 -> No data is present

    DECLARE @StatusCode INT = -1;		
	DECLARE @ASDeployment bit = 0;
	DECLARE @DeploymentTimestamp datetime2;
 	SELECT @DeploymentTimestamp = Convert(DATETIME2, [value], 126)
	FROM cc.[configuration] WHERE configuration_group = 'SolutionTemplate' AND configuration_subgroup = 'Notifier' AND [name] = 'DeploymentTimestamp';

    DECLARE @InitialStatusDone NVARCHAR(4);

	SELECT @InitialStatusDone = [value]
	FROM cc.[configuration] WHERE configuration_group = 'SolutionTemplate' AND configuration_subgroup = 'Notifier' AND [name] = 'InitialPullDone';

	IF EXISTS (SELECT * FROM cc.[configuration] WHERE configuration_group = 'SolutionTemplate' AND configuration_subgroup = 'Notifier' AND [name] = 'ASDeployment' AND [value] ='true')
	SET @ASDeployment = 1;

	IF (@InitialStatusDone = 'True' AND @ASDeployment = 0)
		SET @StatusCode = 2; --Data pull complete

    -- AS Flow
    IF @ASDeployment=1 AND DATEDIFF(HOUR, @DeploymentTimestamp, Sysdatetime()) > 24 AND NOT EXISTS (SELECT * FROM cc.ssas_jobs WHERE [statusMessage] = 'Success')
		SET @StatusCode = 1;
	ELSE 			
	BEGIN
		IF (@InitialStatusDone = 'True')
		SET @StatusCode = 2; --Data pull complete
	END;

    UPDATE cc.[configuration] 
    SET [configuration].[value] = @StatusCode
    WHERE [configuration].configuration_group = 'SolutionTemplate' AND [configuration].configuration_subgroup = 'Notifier' AND [configuration].[name] = 'DataPullStatus'
END;

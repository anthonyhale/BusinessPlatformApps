﻿SET ANSI_NULLS              ON;
SET ANSI_PADDING            ON;
SET ANSI_WARNINGS           ON;
SET ANSI_NULL_DFLT_ON       ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER       ON;
go

-- Must be executed inside the target database

-- Regular views
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='aal' AND TABLE_NAME='FailuresView' AND TABLE_TYPE='VIEW')
    DROP VIEW aal.FailuresView;

-- Tables
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='aal' AND TABLE_NAME='HistoricalData' AND TABLE_TYPE='BASE TABLE')
    DROP TABLE aal.HistoricalData;
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='aal' AND TABLE_NAME='LiveData' AND TABLE_TYPE='BASE TABLE')
    DROP TABLE aal.LiveData;


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name='aal')
BEGIN
    EXEC ('CREATE SCHEMA aal AUTHORIZATION dbo'); -- Avoid batch error
END;


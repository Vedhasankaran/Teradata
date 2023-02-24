DIAGNOSTIC HELPSTATS ON FOR SESSION;


Teradata Data Dictionay(Metadata) Queries
Teradata data dictionary tables are metadata tables present in the DBC database. It can be used for variety of things such as checking table size, query bottleneck and database size etc.



To view current User database,Default database and Session Id
SELECT USER;
Output: TUTORIAL_USER

Dbc.Tables : Objects present in a database and their related information
SELECT databasename,tablename,tablekind,version,journalflag,creatorname,createtimestamp,lastaltertimestamp 
FROM dbc.tables 
WHERE databasename = ['databasename']
AND tablename      = ['objectname'] 
AND TableKind      = 'T' ;
/*
Table Kind	Object Type
T	Table
V	View
M	Macro
P	Stored Procedure
G	Trigger
I	Join Index
N	Hash Index
*/

Dbc.Columns : Column informatiom of tables, views, join index & hash index etc.
SELECT databasename,tablename,columnname,columnformat,columntitle,columnlength,columntype,defaultvalue
FROM dbc.columns 
WHERE databasename = ['databasename'] 
AND tablename      = ['objectname'] 
ORDER BY columnname;

Dbc.Indices : Stores all the index related informatiom for tables, views, join index , hash index & secondary index etc.
SELECT databasename,tablename,indexnumber,indexname,columnname,indextype,uniqueflag,indexmode,accesscount
FROM dbc.indices 
WHERE databasename = ['databasename']
AND   tablename    = ['objectname'] 
ORDER BY indexnumber;
-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.Indexconstraints : Stores all the index's constraints specified while creating indexes.
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename, tablename, indexname, indexnumber, constrainttype, creatorname, createtimestamp, constrainttext
FROM dbc.indexconstraints 
WHERE databasename = ['databasename']
AND   tablename    = ['objectname'] ;
-------------------------------------------------------------------------------------------------------------------------------
-- Table Size : Table size can be determined from multiple tables for example : Dbc.Allspace & Dbc.Tablesize.
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename,tablename,CAST(SUM(currentperm)/(1024*1024*1024) AS DECIMAL(18,5)) AS TableSize_in_GB 
FROM dbc.allspace
WHERE databasename = ['databasename']
AND   tablename    = ['objectname']
GROUP BY databasename,tablename;


SELECT databasename,tablename, CAST(SUM(currentperm)/(1024*1024*1024) AS DECIMAL(18,5)) AS TableSize_in_GB
FROM dbc.tablesize 
WHERE databasename = '[databasename]' 
AND   tablename    = '[objectname]'
GROUP BY databasename,tablename ;
-------------------------------------------------------------------------------------------------------------------------------
-- Database Size : Database size can determined using Dbc.Diskspace.
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename, CAST(SUM(maxperm)/(1024*1024*1024) AS DECIMAL(18,5)) AS "Allocated(GB)",
       CAST(SUM(currentperm)/(1024*1024*1024) AS DECIMAL(18,5)) AS  "Used(GB)",
       "Allocated(GB)"- "Used(GB)"  AS "Free(GB)"
FROM dbc.diskspace WHERE databasename = ['databasename']
GROUP BY 1;
-------------------------------------------------------------------------------------------------------------------------------
-- Table Skewness : To determined table's skewness .
-------------------------------------------------------------------------------------------------------------------------------
SELECT SUM(cnt) as total_rows, 
       COUNT(*) as total_amps, 
       MAX(cnt) as Max_rows_per_amp, 
       MIN(cnt) as min_rows_per_amp, 
       AVG(cnt) as avg_rows_per_amp 
FROM (SELECT HASHAMP(HASHBUCKET(HASHROW([PI]))), COUNT(*) FROM ['Tablename'] Group by 1 ) dt (a, cnt) ; 

-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.Sessioninfo : Active sessions and related information.
-------------------------------------------------------------------------------------------------------------------------------
SELECT username,sessionno,defaultdatabase,ifpno,partition,logicalhostid,hostno, logondate,logontime,logonsource
FROM  dbc.sessioninfo
WHERE username = '[databaseuser]' ORDER BY 2 ;

-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.Databases : All database present within system and its proprties (more detail can be available in Dbc.DBase .
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename,dbkind,creatorname,ownername,permspace,spoolspace,tempspace,commentstring,
       createtimestamp,lastaltername,lastaltertimestamp
FROM dbc.databases ;

-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.Errormsgs : To error message for an error code.
-------------------------------------------------------------------------------------------------------------------------------
SELECT errortext FROM dbc.errormsgs WHERE errorcode = [errorCodeNumber];

-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.PartitioningConstraintsV : To get detail about PPI table's partitions and constraint.
-------------------------------------------------------------------------------------------------------------------------------
SELECT errortext FROM dbc.partitioningconstraintsv WHERE databasename='tutorial_db' AND tablename='employee';

Number of Nodes/AMPs in Teradata System:
Number of Nodes
SELECT COUNT(DISTINCT nodeid) FROM dbc.resusagescpu;

Number of Amps on each Node
SELECT nodeid,COUNT(DISTINCT vproc) number_of_amps 
FROM dbc.ResCpuUsageByAmpView 
GROUP BY nodeid;


Number of AMPs in the system
 SELECT HASHAMP()+1;
 
-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.Triggers : Triggers and related information.
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename, subjecttabledatabasename, tablename, triggername, enabledflag, actiontime, event, 
       triggercomment,creatorname, createtimestamp, lastaltername, lastaltertimestamp
FROM dbc.triggers 
WHERE databasename = ['databasename'];

-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.Allrolerights : Check Table/view access for a particular role.
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename, tablename
FROM dbc.allrolerights 
WHERE  rolename = ['Role_name']
AND    tablename= ['tablename/viewname']
GROUP BY 1,2
Order by 1,2;

-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.Allrights : Access right granted on a given object.
-------------------------------------------------------------------------------------------------------------------------------
SELECT username, databasename, tablename, columnname, accessright, grantauthority, grantorname, 
     allnessflag, creatorname, createtimestamp 
FROM dbc.allrights
WHERE databasename = ['databasename']
AND   tablename    = ['tablename/viewname']
ORDER BY 1;

-------------------------------------------------------------------------------------------------------------------------------
-- Dbc.Userrights : Access rights that the used has on a given table
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename,tablename,accessright,grantauthority,grantorname,creatorname,createtimestamp
FROM dbc.userrights 
WHERE databasename  =['databasename']
AND tablename       =['tablename/viewname']
ORDER BY accessright;

-------------------------------------------------------------------------------------------------------------------------------
-- Teradata Version:
-------------------------------------------------------------------------------------------------------------------------------
SELECT infokey, CAST(infodata AS VARCHAR(50)) FROM dbc.dbcinfo;

Average Row Size: The easiest way to get an average row size for a populated table is always size of the table divided by number of records in the table(count).
Table Size / Count(rows)

-------------------------------------------------------------------------------------------------------------------------------
-- Teradata Version:
-------------------------------------------------------------------------------------------------------------------------------
SELECT  ProcID,
        UserName,
        QueryText,
        LockLevel,
        StartTime,
        FirstRespTime,
        ClientID,
        ClientAddr,
        ErrorCode,
        ErrorText,
        TotalIOCount,
        NumResultRows
FROM    DBC.QryLogV
WHERE   StartTime > CURRENT_TIMESTAMP - INTERVAL '6' DAY
AND StartTime < CURRENT_TIMESTAMP - INTERVAL '3' DAY
ORDER BY    StartTime DESC;

-------------------------------------------------------------------------------------------------------------------------------

COLLECT STATISTICS USING SAMPLE ON COLUMN aPrettyDistinctColumn;
SHOW STATISTICS VALUES ON aTable;

-------------------------------------------------------------------------------------------------------------------------------
-- Find the Logged in Teradata server
-------------------------------------------------------------------------------------------------------------------------------
SELECT regexp_substr(regexp_substr(LogonSource,'[^ ]+',1,4),'[^;]+',1,1) Connected_Server
FROM dbc.sessioninfo
WHERE sessionno = (SELECT SESSION);

-------------------------------------------------------------------------------------------------------------------------------
-- List of all databases/users in Teradata
-------------------------------------------------------------------------------------------------------------------------------
select databasename from dbc.databases order by 1;

-------------------------------------------------------------------------------------------------------------------------------
-- Table Size : Table size can be determined from multiple tables, for example : Dbc.Allspace & Dbc.Tablesize.
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename,tablename,CAST(SUM(currentperm)/(1024*1024*1024) AS DECIMAL(18,5)) AS TableSize_in_GB 
FROM dbc.allspace
WHERE databasename = ['databasename']
AND   tablename    = ['objectname']
GROUP BY databasename,tablename;


SELECT databasename,tablename, CAST(SUM(currentperm)/(1024*1024*1024) AS DECIMAL(18,5)) AS TableSize_in_GB
FROM dbc.tablesize 
WHERE databasename = '[databasename]' 
AND   tablename    = '[objectname]'
GROUP BY databasename,tablename 
-------------------------------------------------------------------------------------------------------------------------------
-- Teradata Error Messages : To check error message for an error code.
-------------------------------------------------------------------------------------------------------------------------------
SELECT errortext FROM dbc.errormsgs WHERE errorcode = [errorCodeNumber];

-------------------------------------------------------------------------------------------------------------------------------
Identify All Roles assigned to Teradata Table
-------------------------------------------------------------------------------------------------------------------------------
SELECT databasename, tablename, rolename, AccessRight 
FROM dbc.allrolerights
WHERE  databasename = 'SDE_NA_PRDVIEW'
AND    tablename= 'RCL_DLR_RPT_DATE_DROPDOWN_NOPI';
-------------------------------------------------------------------------------------------------------------------------------
-- Identify All rights for a Teradata user
-------------------------------------------------------------------------------------------------------------------------------

SELECT username, databasename, tablename, columnname, accessright, grantorname
FROM dbc.allrights
WHERE username='tutorial_user';

-------------------------------------------------------------------------------------------------------------------------------
-- SIZES of DATABASES
-------------------------------------------------------------------------------------------------------------------------------
SELECT DatabaseName
,Sum(CurrentPerm)
FROM DBC.AllSpaceV
WHERE DatabaseName like 'SDE_%'
GROUP BY 1 having sum(currentperm) > 0
ORDER BY 2 desc;


-------------------------------------------------------------------------------------------------------------------------------
-- Users who are using a lot of spool
-------------------------------------------------------------------------------------------------------------------------------

SELECT databasename
,SUM(peakspool)
FROM DBC.DiskSpaceV
GROUP BY 1 HAVING SUM(peakspool) > 50000000000
ORDER BY 2 DESC;
-------------------------------------------------------------------------------------------------------------------------------
-- If you want to column information
-------------------------------------------------------------------------------------------------------------------------------

SELECT  DatabaseName,
        TableName,
        ColumnName,
        CASE ColumnType
when 'A1' then 'ARRAY'
when 'AN' then 'MULTI-DIMENSIONAL ARRAY'
when 'AT' then 'TIME'
when 'BF' then 'BYTE'
when 'BO' then 'BLOB'
when 'BV' then 'VARBYTE'
when 'CF' then 'CHARACTER'
when 'CO' then 'CLOB'
when 'CV' then 'VARCHAR'
when 'D ' then 'DECIMAL'
when 'DA' then 'DATE'
when 'DH' then 'INTERVAL DAY TO HOUR'
when 'DM' then 'INTERVAL DAY TO MINUTE'
when 'DS' then 'INTERVAL DAY TO SECOND'
when 'DY' then 'INTERVAL DAY'
when 'F ' then 'FLOAT'
when 'HM' then 'INTERVAL HOUR TO MINUTE'
when 'HS' then 'INTERVAL HOUR TO SECOND'
when 'HR' then 'INTERVAL HOUR'
when 'I ' then 'INTEGER'
when 'I1' then 'BYTEINT'
when 'I2' then 'SMALLINT'
when 'I8' then 'BIGINT'
when 'JN' then 'JSON'
when 'MI' then 'INTERVAL MINUTE'
when 'MO' then 'INTERVAL MONTH'
when 'MS' then 'INTERVAL MINUTE TO SECOND'
when 'N ' then 'NUMBER'
when 'PD' then 'PERIOD(DATE)'
when 'PM' then 'PERIOD(TIMESTAMP WITH TIME ZONE)'
when 'PS' then 'PERIOD(TIMESTAMP)'
when 'PT' then 'PERIOD(TIME)'
when 'PZ' then 'PERIOD(TIME WITH TIME ZONE)'
when 'SC' then 'INTERVAL SECOND'
when 'SZ' then 'TIMESTAMP WITH TIME ZONE'
when 'TS' then 'TIMESTAMP'
when 'TZ' then 'TIME WITH TIME ZONE'
when 'UT' then 'UDT Type'
when 'XM' then 'XML'
when 'YM' then 'INTERVAL YEAR TO MONTH'
when 'YR' then 'INTERVAL YEAR'
            END AS DataType,
            DecimalTotalDigits,
            DecimalFractionalDigits
FROM    DBC.ColumnsV
WHERE   ColumnType in ('I1', 'I2', 'I8', 'I', 'N', 'D', 'F')
AND DatabaseName NOT IN ('All', 'Crashdumps', 'DBC', 'dbcmngr',
    'Default', 'External_AP', 'EXTUSER', 'LockLogShredder', 'PUBLIC',
    'Sys_Calendar', 'SysAdmin', 'SYSBAR', 'SYSJDBC', 'SYSLIB',
    'SystemFe', 'SYSUDTLIB', 'SYSUIF', 'TD_SERVER_DB', 
    'TD_SYSGPL', 'TD_SYSXML', 'TDMaps', 'TDPUSER', 'TDQCD',
    'TDStats', 'tdwm', 'SQLJ', 'SYSSPATIAL','TD_SYSFNLIB')
ORDER BY    DatabaseName,
            TableName;




-------------------------------------------------------------------------------------------------------------------------------
-- If you want to get, all the tables present in sales database
-------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM dbc.tables WHERE tablekind = 'T' and databasename = 'sde_americas_prddata';
SELECT * FROM dbc.tables  where databasename like 'sde_%'
and tablekind = 'V' and RequestText like '%SDE_NA_PRDDATA%';

-- Query columns lists
SELECT  * 
FROM    DBC.ColumnsV
WHERE DatabaseName='DBC' AND TableName='Databases';

-- Query functions list
SELECT  * 
FROM    DBC.FunctionsV;

-- Query hash and join indices lists
SELECT  * 
FROM    DBC.IndicesV
WHERE DatabaseName='DBC' AND TableName='RoleGrants';

-- Check disk space size
SELECT  * 
FROM    DBC.DiskSpaceV 
WHERE DatabaseName='DBC';

SELECT  UserName,
    DatabaseName,
    TableName,
    ColumnName,
    AccessRight,
    GrantAuthority,
    GrantorName,
    AllnessFlag,
    CreatorName,
    CreateTimeStamp, 
        CASE 
            WHEN ACCESSRIGHT = 'D' THEN 'DELETE'
            WHEN ACCESSRIGHT = 'I' THEN 'INSERT'
            WHEN ACCESSRIGHT = 'R' THEN 'SELECT'
            WHEN ACCESSRIGHT = 'SH' THEN 'SHOW TABLE/VIEW'
            WHEN ACCESSRIGHT = 'U' THEN 'UPDATE' 
            ELSE 'OTHER - ' || ACCESSRIGHT
        END ACCESS_LEVEL
FROM    DBC.AllRights
WHERE   UserName='PUBLIC';


DBC.UserGrantedRightsV
DBC.UserRightsV
DBC.AllRoleRightsV
DBC.UserRoleRightsV

-------------------------------------------------------------------------------------------------------------------------------
-- Size of Tables /Database
-------------------------------------------------------------------------------------------------------------------------------
SELECT
DATABASENAME,
TABLENAME,
SUM (CURRENTPERM)/1024**2 AS CURRENT_MB,
SUM (CURRENTPERM)/1024**3 AS CURRENT_GB
FROM DBC.ALLSPACE
WHERE  DATABASENAME = 'DATABASE_NAME'
AND TABLENAME = 'TABLE_NAME'
GROUP BY 1,2
ORDER BY 1,2

-------------------------------------------------------------------------------------------------------------------------------
-- Query to  gives the skewness for all tables.
-------------------------------------------------------------------------------------------------------------------------------
SELECT
ts.DatabaseName ,ts.TableName,td.CreateTimeStamp AS Created ,td.LastAlterTimeStamp AS LastAltered,td.AccessCount ,td.LastAccessTimeStamp AS LastAccess ,
SUM(ts.CurrentPerm) AS CurrentPerm ,
SUM(ts.PeakPerm) AS PeakPerm,
(100 – (AVG(ts.CurrentPerm)/MAX(ts.CurrentPerm)*100)) AS SkewFactor
FROM DBC.TableSize ts JOIN DBC.Tables td
ON ts.DatabaseName = td.DatabaseName
AND ts.TableName = td.TableName
GROUP BY 1,2,3,4,5,6;

-------------------------------------------------------------------------------------------------------------------------------
-- Query to find the Primary key, Foreign key, primary Index,PPI for the Database?

-------------------------------------------------------------------------------------------------------------------------------

Select DatabaseName, TableName ,columnName,

Case When IndexType=’K’ Then ‘Primary Key’

When IndexType=’S’ Then ‘Secondary Index’

When IndexType=’P’ Then ‘Primary Index’

When IndexType=’Q’ Then ‘PPIndex’

When IndexType=’J’ Then ‘Join Index’

End    as implimented _Index From DBC.IndicesWhere TableName in ( Select distinct TableName From DBC.Tablesize Where DatabaseName <>’DBC’ And CurrentPerm>0 ) Order by 1,2,3


How to view every column and the columns contained in indexes in Teradata?

SELECT * FROM DBC.TVFields;
 SELECT * FROM DBC.Indexes;
 
 How to find out list of indexes in Teradata?
 SELECT databasename, tablename, columnname, indextype, indexnumber, indexname FROM   dbc.indices ORDER BY databasename,  tablename, indexnumber;

--
-- How do you execute the given SQL statement repeatedly in BTEQ?
--
Select top 1* from database.table1; =n

Here “=n” is to run the previous sql statement, “n” number of times.
SELECT INDEX(‘Write’, ‘i’); Displays Result as ‘3’
SELECT INDEX(‘Write’, ‘te’); Displays Result as ‘4’


----------------------------------------------------------------------------------------------
-- ROLES BASED RETREIVAL
----------------------------------------------------------------------------------------------

SELECT  rr.rolename,rm.grantee
FROM dbc.allrolerights rr
LEFT OUTER JOIN
DBC.ROLEMEMBERS rm
ON rr.rolename=rm.rolename
WHERE  rr.databasename IN ('XXXXXXXXXXXXXXXXX')
group by 1,2
order by 1,2

SELECT  rr.rolename,rm.grantee
FROM dbc.allrolerights rr
LEFT OUTER JOIN
DBC.ROLEMEMBERS rm
ON rr.rolename=rm.rolename
WHERE   rm.grantee = 'XXXXXXXXXXXxx'
group by 1,2
order by 1,2

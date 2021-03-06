if object_id('dbo.UnitTest_PopulateDDL') is not null
begin
   exec ('drop procedure dbo.UnitTest_PopulateDDL')
end
go


create procedure dbo.UnitTest_PopulateDDL
as
begin

delete from dbo.SyncConfig
where TargetTable  in ('UnitTest_TargetTable1','UnitTest_TargetTable2')

insert into dbo.SyncConfig
([TargetDatabase]
,[TargetSchema]
,[TargetTable]
,[SourceDatabase]
,[SourceSchema]
,[SourceTable]
,[IsActive]
,[ProcessMode]
,[TableGroup]
,SurrogateKeyColumn
,SurrogateTable
,[PrimaryKeyColumns]
,[TargetActiveColumn]
,[TargetCreateDateColumn]
,[TargetUpdateDateColumn]
,[SourceUpdateDateColumn]
,[IsSourceCleanupAfterRun]
,IsSourceToLoadCopy
,IsDiff)
select
  db_name() as TargetDatabase
  ,'dbo' as TargetSchema
  ,'UnitTest_TargetTable1' as TargetTable
  ,db_name() as SourceDatabase
  ,'dbo' as SourceSchema
  ,'UnitTest_SourceTable1' as SourceTable
  ,1 as IsActive
  ,'Type-1' as ProcessMode
  ,'UnitTest' as TableGroup
  ,'TargetTableID' as SurrogateKeyColumn
  ,'UnitTest_SKMap_TargetTable1' as SurrogateTable
  ,N'<columns>
      <column name="PKColumn" />
    </columns>' as PrimaryKeyColumns
  ,'UnitTestIsActive' as TargetActiveColumn
  ,'UnitTestCreateDate' as TargetCreateDateColumn
  ,'UnitTestUpdateDate' as TargetUpdateDateColumn
  ,'UnitTestStagingTime' as SourceUpdateDateColumn
  ,0 as IsSourceCleanupAfterRun
  ,1 as IsSourceToLoadCopy
  ,1 as IsDiff


insert into dbo.SyncConfig
([TargetDatabase]
,[TargetSchema]
,[TargetTable]
,[SourceDatabase]
,[SourceSchema]
,[SourceTable]
,[IsActive]
,[ProcessMode]
,[TableGroup]
,SurrogateKeyColumn
,SurrogateTable
,[PrimaryKeyColumns]
,[TargetBeginDateColumn]
,[TargetEndDateColumn]
,[TargetCreateDateColumn]
,[TargetUpdateDateColumn]
,[SourceUpdateDateColumn]
,[IsSourceCleanupAfterRun]
,IsSourceToLoadCopy
,IsDiff)
select
  db_name() as TargetDatabase
  ,'dbo' as TargetSchema
  ,'UnitTest_TargetTable2' as TargetTable
  ,db_name() as SourceDatabase
  ,'dbo' as SourceSchema
  ,'UnitTest_SourceTable1' as SourceTable
  ,1 as IsActive
  ,'Type-2' as ProcessMode
  ,'UnitTest' as TableGroup
  ,'TargetTableID' as SurrogateKeyColumn
  ,'UnitTest_SKMap_TargetTable1' as SurrogateTable
  ,N'<columns>
      <column name="PKColumn" />
    </columns>' as PrimaryKeyColumns
  ,'UnitTestBeginDate' as TargetBeginDateColumn
  ,'UnitTestEndDate' as TargetEndDateColumn
  ,'UnitTestCreateDate' as TargetCreateDateColumn
  ,'UnitTestUpdateDate' as TargetUpdateDateColumn
  ,'UnitTestStagingTime' as SourceUpdateDateColumn
  ,0 as IsSourceCleanupAfterRun
  ,1 as IsSourceToLoadCopy
  ,1 as IsDiff
end
go

exec UnitTest_PopulateDDL
go

if object_id('dbo.UnitTest_SourceTable1') is not null
begin
   exec ('drop table dbo.UnitTest_SourceTable1')
end
go

if object_id('dbo.UnitTest_TargetTable1') is not null
begin
   exec ('drop table dbo.UnitTest_TargetTable1')
end
go

if object_id('dbo.UnitTest_SKMap_TargetTable1') is not null
begin
   exec ('drop table dbo.UnitTest_SKMap_TargetTable1')
end
go

if object_id('dbo.UnitTest_TargetTable2') is not null
begin
   exec ('drop table dbo.UnitTest_TargetTable2')
end
go

create table dbo.UnitTest_TargetTable1
(TargetTableID int not null
,PKColumn varchar(400) not null primary key clustered
,IntColumn int
,GuidColumn uniqueidentifier
,NvarcharColumn nvarchar(400)
,DateColumn datetime
,UnitTestStagingTime datetime not null default(getdate())
,UnitTestIsActive bit
,UnitTestCreateDate datetime
,UnitTestUpdateDate datetime
)
go


create table dbo.UnitTest_TargetTable2
(TargetTableID int not null
,PKColumn varchar(400) not null
,IntColumn int
,GuidColumn uniqueidentifier
,NvarcharColumn nvarchar(400)
,DateColumn datetime
,UnitTestStagingTime datetime not null
,UnitTestBeginDate datetime
,UnitTestEndDate datetime
,UnitTestCreateDate datetime
,UnitTestUpdateDate datetime
,constraint UnitTest_TargetTable2PK primary key clustered (TargetTableID, UnitTestBeginDate)
)
go

create table dbo.UnitTest_SourceTable1
(PKColumn varchar(400) not null primary key clustered
,IntColumn int
,GuidColumn uniqueidentifier
,NvarcharColumn nvarchar(400)
,DateColumn datetime
,UnitTestStagingTime datetime not null default(getdate())
)
go

create table dbo.UnitTest_SKMap_TargetTable1
(TargetTableID int not null
,PKColumn varchar(400) not null
,constraint UnitTest_SKMap_TargetTable1PK primary key clustered (TargetTableID)
)
go


; WITH Nbrs_3( n ) AS ( SELECT 1 UNION SELECT 0 ),
Nbrs_2( n ) AS ( SELECT 1 FROM Nbrs_3 n1 CROSS JOIN Nbrs_3 n2 ),
Nbrs_1( n ) AS ( SELECT 1 FROM Nbrs_2 n1 CROSS JOIN Nbrs_2 n2 ),
Nbrs_0( n ) AS ( SELECT 1 FROM Nbrs_1 n1 CROSS JOIN Nbrs_1 n2 ),
Nbrs ( n ) AS ( SELECT 1 FROM Nbrs_0 n1 CROSS JOIN Nbrs_0 n2 )

insert into dbo.UnitTest_SourceTable1
(PKColumn
,IntColumn
,GuidColumn
,NvarcharColumn
,DateColumn
,UnitTestStagingTime)
SELECT 
   PKColumn = cast(n as varchar) + cast(n as varchar)
  ,n as IntColumn
  ,newid() as GuidColumn
  ,NvarcharColumn = N'TestData='+cast(n as varchar) + cast(n as varchar)
  ,DateColumn = dateadd(ss,-1.0*n,getdate())
  ,UnitTestStagingTime = getdate()
FROM ( SELECT ROW_NUMBER() OVER (ORDER BY n)
FROM Nbrs ) D ( n )
WHERE n <= 500 ; 
go


select case when count(*)=2 then 'Success' else 'Failure' end as Status
  ,'Make sure both unit test sync configs exist' as TestDescription
from dbo.SyncConfig
where TargetTable in ('UnitTest_TargetTable1','UnitTest_TargetTable2')

union all

select case when count(*)=4 then 'Success' else 'Failure' end as Status
    ,'Make sure 4 unit test tables exist' as TestDescription
from sys.tables t
where t.name in ('UnitTest_SourceTable1','UnitTest_SKMap_TargetTable1','UnitTest_TargetTable1','UnitTest_TargetTable2')

union all

select case when count(*)=500 then 'Success' else 'Failure' end as Status
  ,'Make sure source table has 500 rows' as TestDescription
from dbo.UnitTest_SourceTable1


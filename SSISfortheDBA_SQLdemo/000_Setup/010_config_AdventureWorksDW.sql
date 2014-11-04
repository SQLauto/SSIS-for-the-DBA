/* Demo script for SSIS for the DBA
 *
 * Written by David Peter Hansen 
 * @dphansen | davidpeterhansen.com/talks
 *
 * Behind the scene script - not particular pretty :-)
 * Config AdventureWorksDW2014
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

USE AdventureWorksDW2014
GO

-- Drop tables and schemas if they exist
IF EXISTS (SELECT 1 FROM sys.tables 
			WHERE name = 'bigTransactionHistory' 
			AND SCHEMA_NAME(schema_id) = 'extract')
	DROP TABLE [extract].[bigTransactionHistory]
GO

IF EXISTS (SELECT 1 FROM sys.tables 
			WHERE name = 'DimProduct' 
			AND SCHEMA_NAME(schema_id) = 'staging')
	DROP TABLE [staging].[DimProduct]
GO

IF EXISTS (SELECT 1 FROM sys.tables 
			WHERE name = 'DimReseller' 
			AND SCHEMA_NAME(schema_id) = 'staging')
	DROP TABLE staging.[DimReseller]
GO

IF EXISTS (SELECT 1 FROM sys.tables 
			WHERE name = 'Product' 
			AND SCHEMA_NAME(schema_id) = 'extract')
	DROP TABLE extract.[Product]
GO

IF EXISTS (SELECT 1 FROM sys.tables 
			WHERE name = 'ProductCategory' 
			AND SCHEMA_NAME(schema_id) = 'extract')
	DROP TABLE extract.[ProductCategory]
GO

IF EXISTS (SELECT 1 FROM sys.tables 
			WHERE name = 'ProductModel' 
			AND SCHEMA_NAME(schema_id) = 'extract')
	DROP TABLE extract.[ProductModel]
GO

IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
	DROP SCHEMA staging
GO

IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'extract')
	DROP SCHEMA extract
GO

-- Create staging schema
CREATE SCHEMA staging
GO

-- Create exctract schema
CREATE SCHEMA extract
GO


CREATE TABLE [extract].[bigTransactionHistory](
	[TransactionID] [int] NULL,
	[ProductID] [int] NOT NULL,
	[TransactionDate] [datetime] NULL,
	[Quantity] [int] NULL,
	[ActualCost] [money] NULL,
	BlobColumn NVARCHAR(MAX) NULL
) 

-- Create staging table for DimProduct
CREATE TABLE [staging].[DimProduct](
	[ProductKey] [int] NULL,
	[ProductAlternateKey] [nvarchar](25) NULL,
	[ProductSubcategoryKey] [int] NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[EnglishProductName] [nvarchar](50) NULL,
	[SpanishProductName] [nvarchar](50) NULL,
	[FrenchProductName] [nvarchar](50) NULL,
	[StandardCost] [money] NULL,
	[FinishedGoodsFlag] [bit] NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NULL,
	[ReorderPoint] [smallint] NULL,
	[ListPrice] [money] NULL,
	[Size] [nvarchar](50) NULL,
	[SizeRange] [nvarchar](50) NULL,
	[Weight] [float] NULL,
	[DaysToManufacture] [int] NULL,
	[ProductLine] [nchar](2) NULL,
	[DealerPrice] [money] NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ModelName] [nvarchar](50) NULL,
	[LargePhoto] [varbinary](max) NULL,
	[EnglishDescription] [nvarchar](400) NULL,
	[FrenchDescription] [nvarchar](400) NULL,
	[ChineseDescription] [nvarchar](400) NULL,
	[ArabicDescription] [nvarchar](400) NULL,
	[HebrewDescription] [nvarchar](400) NULL,
	[ThaiDescription] [nvarchar](400) NULL,
	[GermanDescription] [nvarchar](400) NULL,
	[JapaneseDescription] [nvarchar](400) NULL,
	[TurkishDescription] [nvarchar](400) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Status] [nvarchar](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE TABLE staging.[DimReseller](
	[ResellerKey] [int] NULL,
	[GeographyKey] [int] NULL,
	[ResellerAlternateKey] [nvarchar](15) NULL,
	[Phone] [nvarchar](25) NULL,
	[BusinessType] [varchar](20) NULL,
	[ResellerName] [nvarchar](50) NULL,
	[NumberEmployees] [int] NULL,
	[OrderFrequency] [char](1) NULL,
	[OrderMonth] [tinyint] NULL,
	[FirstOrderYear] [int] NULL,
	[LastOrderYear] [int] NULL,
	[ProductLine] [nvarchar](50) NULL,
	[AddressLine1] [nvarchar](60) NULL,
	[AddressLine2] [nvarchar](60) NULL,
	[AnnualSales] [money] NULL,
	[BankName] [nvarchar](50) NULL,
	[MinPaymentType] [tinyint] NULL,
	[MinPaymentAmount] [money] NULL,
	[AnnualRevenue] [money] NULL,
	[YearOpened] [int] NULL
)

-- Create extract tables
CREATE TABLE extract.[Product](
	[ProductID] [int] NULL,
	[Name] nvarchar(50) NULL,
	[ProductNumber] [nvarchar](25) NULL,
	[MakeFlag] bit NULL,
	[FinishedGoodsFlag] bit NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NULL,
	[ReorderPoint] [smallint] NULL,
	[StandardCost] [money] NULL,
	[ListPrice] [money] NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NULL,
	[ProductLine] [nchar](2) NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [uniqueidentifier] NULL,
	[ModifiedDate] [datetime] NULL
)

CREATE TABLE extract.[ProductCategory](
	[ProductCategoryID] [int] NULL,
	[Name] nvarchar(50) NULL,
	[rowguid] [uniqueidentifier] NULL,
	[ModifiedDate] [datetime] NULL ,
)

CREATE TABLE extract.[ProductModel](
	[ProductModelID] [int] NULL,
	[Name] nvarchar(50) NULL,
	[CatalogDescription] [xml] NULL,
	[Instructions] [xml] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL NULL,
	[ModifiedDate] [datetime] NULL
)



/* Helper Stored proc for dbo.UpdateDimension 
 * Returns a CSV string from a column in a table
 */
IF EXISTS (SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'dbo' AND name = 'Table2Csv')
	DROP PROCEDURE dbo.Table2Csv
GO

CREATE PROCEDURE dbo.[Table2Csv]
    @TableName sysname
  , @ColumnName sysname
  , @CsvString NVARCHAR(MAX) = NULL OUTPUT 
  , @Separator NVARCHAR(MAX) = NULL
AS

SET NOCOUNT ON;

DECLARE @Sql NVARCHAR(MAX);
DECLARE @LenSeparator INT;
	
/* use comma as the default seperator */
IF @Separator IS NULL BEGIN
	SET @Separator = ''', ''';
END
ELSE BEGIN
	SET @Separator = '''' + @Separator + ' ''';
END

SET @Sql =
'
SET NOCOUNT ON;
SET CONCAT_NULL_YIELDS_NULL OFF;

DECLARE @LocalDelimiter NVARCHAR(MAX);

SET @LocalDelimiter = '''';
SET @CsvString = '''';

SELECT @CsvString = @CsvString + @LocalDelimiter + ' + @ColumnName + ',
						@LocalDelimiter = ' + @Separator + '
FROM ' + @TableName + ';

IF LEN(@CsvString) = 0 SET @CsvString = NULL;
';

EXECUTE dbo.sp_executesql 
	@stmt = @Sql
	, @params = N'@CsvString NVARCHAR(MAX) OUTPUT'
	, @CsvString = @CsvString OUTPUT;
GO

/* Updates a dimension from a staging table - T1 history only */
IF EXISTS (SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'dbo' AND name = 'UpdateDimension')
	DROP PROCEDURE dbo.UpdateDimension
GO

CREATE PROCEDURE dbo.UpdateDimension(@DimensionName NVARCHAR(200))
AS

SELECT 'd.' + c.name + ' = s.' + c.name AS ColumnAssignment
	, '(d.[' + c.name + '] <> s.[' + c.name + '] OR (d.[' + c.name + '] IS NULL AND s.[' + c.name + '] IS NOT NULL))' AS ColumnDiff
	, c.name AS [Columns]
INTO #T
FROM sys.tables t
INNER JOIN sys.columns c
ON t.object_id = c.object_id
WHERE SCHEMA_NAME(t.schema_id) = 'Dimensions'
	AND t.name = @DimensionName
	AND c.name NOT LIKE 'NK_%'
	AND c.name NOT LIKE 'SK_%'
	AND c.name != 'ValidFrom'

DECLARE @ColumnAssignment NVARCHAR(MAX);
DECLARE @ColumnDiff NVARCHAR(MAX);
DECLARE @Columns NVARCHAR(MAX);

EXECUTE dbo.Table2Csv 
	@TableName = '#T'
	, @ColumnName = 'ColumnAssignment'
	, @CsvString = @ColumnAssignment OUTPUT;
	
EXECUTE dbo.Table2Csv 
	@TableName = '#T'
	, @ColumnName = 'ColumnDiff'
	, @CsvString = @ColumnDiff OUTPUT
	, @Separator = ' OR ';

EXECUTE dbo.Table2Csv 
	@TableName = '#T'
	, @ColumnName = 'Columns'
	, @CsvString = @Columns OUTPUT;


DECLARE @Sql NVARCHAR(MAX)

SET @Sql = 
'MERGE INTO <DimensionTable> AS d
USING <StagingTable> AS s
ON s.<StagingSK> = d.<DimensionSK>
WHEN MATCHED AND <ColumnDiff> THEN
	UPDATE SET <ColumnAssignment>
WHEN NOT MATCHED BY TARGET THEN
	INSERT (<NKColumn>, <DimensionColumns>)
	VALUES (<NKColumn>, <StagingColumns>);'

SET @Sql = REPLACE(@Sql, '<DimensionTable>', 'dbo.' + @DimensionName);
SET @Sql = REPLACE(@Sql, '<StagingTable>', 'staging.' + @DimensionName);
SET @Sql = REPLACE(@Sql, '<StagingSK>', 'SK_' + @DimensionName);
SET @Sql = REPLACE(@Sql, '<DimensionSK>', 'SK_' + @DimensionName);
SET @Sql = REPLACE(@Sql, '<NKColumn>', 'NK_' + @DimensionName);
SET @Sql = REPLACE(@Sql, '<ColumnDiff>', @ColumnDiff);
SET @Sql = REPLACE(@Sql, '<ColumnAssignment>', @ColumnAssignment);
SET @Sql = REPLACE(@Sql, '<DimensionColumns>', @Columns);
SET @Sql = REPLACE(@Sql, '<StagingColumns>', @Columns);

PRINT @Sql

EXECUTE dbo.sp_executesql @stmt = @Sql;
GO
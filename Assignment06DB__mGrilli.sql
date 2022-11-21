--*************************************************************************--
-- Title: Assignment06
-- Author: _mGrilli
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,_mGrilli,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB__mGrilli')
	 Begin 
	  Alter Database [Assignment06DB__mGrilli] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB__mGrilli;
	 End
	Create Database Assignment06DB__mGrilli;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB__mGrilli;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
	GO
	--SELECT * FROM Categories;
	CREATE VIEW vCategories
	WITH SCHEMABINDING 
	AS 
	SELECT 
		CategoryID,
		CategoryName 
	FROM 
		dbo.Categories;
	GO
	
	--SELECT * FROM Products;
	CREATE VIEW vProducts
	WITH SCHEMABINDING 
	AS 
	SELECT 
		ProductID, 
		ProductName, 
		CategoryID, 
		UnitPrice 
	FROM 
		dbo.Products;
	GO

	--SELECT * FROM Employees;
	CREATE VIEW vEmployees
	WITH SCHEMABINDING 
	AS
	SELECT 
		EmployeeID,
		Employee = EmployeeFirstName + ' ' + EmployeeLastName,
		ManagerID
	FROM 
		dbo.Employees
	GO

	--SELECT * FROM Inventories;
	CREATE VIEW vInventories
	WITH SCHEMABINDING 
	AS
	SELECT
		InventoryID,
		InventoryDate,
		EmployeeID,
		ProductID,
		Count
	FROM 
		dbo.Inventories
GO	
	
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Deny Select On Products to Public;
Deny Select On Inventories to Public;
Deny Select On Employees to Public;

Grant Select On vProductsByCategories to Public;
Grant Select On vInventoriesByProductsByDates to Public;
Grant Select On vInventoriesByEmployeesByDates to Public;
Grant Select On vInventoriesByProductsByCategories to Public;
Grant Select On vInventoriesByProductsByEmployees to Public;
Grant Select On vInventoriesForChaiAndChangByEmployees to Public;
Grant Select On vEmployeesByManager to Public;
Grant Select On vInventoriesByProductsByCategoriesByEmployees to Public;

GO
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!


--SELECT ProductName, C.CategoryName, UnitPrice 
--FROM Products AS P
--JOIN Categories AS C
--ON C.CategoryID = P.CategoryID

CREATE VIEW vProductsByCategories
WITH SCHEMABINDING 
AS 
SELECT 
	C.CategoryName, 
	ProductName, 
	UnitPrice 
FROM 
	dbo.Products AS P
JOIN 
	dbo.Categories AS C
ON 
	C.CategoryID = P.CategoryID
GO

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--SELECT 
--		Products.ProductName, 
--		Inventories.InventoryDate, 
--		Inventories.Count 
--	FROM 
--		Products 
--	INNER JOIN 
--		Inventories
--	ON 
--		Products.ProductID = Inventories.ProductID 
--	GO

CREATE VIEW vInventoriesByProductsByDates
WITH SCHEMABINDING 
AS
SELECT 
		Products.ProductName, 
		Inventories.InventoryDate, 
		Inventories.Count 
	FROM 
		dbo.Products 
	INNER JOIN 
		dbo.Inventories
	ON 
		Products.ProductID = Inventories.ProductID 
	GO
-- Here is an example of some rows selected from the view:
-- ProductName		InventoryDate	Count
-- Alice Mutton		2017-01-01		0
-- Alice Mutton		2017-02-01		10
-- Alice Mutton		2017-03-01		20
-- Aniseed Syrup	2017-01-01		13
-- Aniseed Syrup	2017-02-01		23
-- Aniseed Syrup	2017-03-01		33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--SELECT DISTINCT 
--	Inventories.InventoryDate, 
--	Employees.EmployeeFirstName + ' ' + 
--	Employees.EmployeeLastName AS EmployeeName
--FROM 
--	Inventories 
--INNER JOIN 
--	Employees 
--ON 
--	Inventories.EmployeeID = Employees.EmployeeID
--GO

CREATE VIEW vInventoriesByEmployeesByDates
WITH SCHEMABINDING 
AS
SELECT DISTINCT 
	Inventories.InventoryDate, 
	Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS EmployeeName
FROM 
	dbo.Inventories 
INNER JOIN 
	dbo.Employees 
ON 
	Inventories.EmployeeID = Employees.EmployeeID
GO


-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--SELECT 
--	Categories.CategoryName,
--	Products.ProductName,
--	Inventories.InventoryDate,
--	Inventories.Count
--FROM 
--	Categories
--JOIN 
--	Products
--ON 
--	Categories.CategoryID = Products.CategoryID
--JOIN 
--	Inventories
--ON 
--	Products.ProductID = Inventories.ProductID
--GO

CREATE VIEW vInventoriesByProductsByCategories
WITH SCHEMABINDING 
AS
SELECT 
	Categories.CategoryName,
	Products.ProductName,
	Inventories.InventoryDate,
	Inventories.Count
FROM 
	dbo.Categories
JOIN 
	dbo.Products
ON 
	Categories.CategoryID = Products.CategoryID
JOIN 
	dbo.Inventories
ON 
	Products.ProductID = Inventories.ProductID
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--SELECT 
--	Categories.CategoryName,
--	Products.ProductName,
--	Inventories.InventoryDate,
--	Inventories.Count,
--	Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS EmployeeName
--FROM 
--	Categories
--JOIN 
--	Products
--ON 
--	Categories.CategoryID = Products.CategoryID
--JOIN 
--	Inventories
--ON 
--	Products.ProductID = Inventories.ProductID
--JOIN 
--	Employees
--ON 
--	Inventories.EmployeeID = Employees.EmployeeID

CREATE VIEW vInventoriesByProductsByEmployees
WITH SCHEMABINDING 
AS
SELECT 
	Categories.CategoryName,
	Products.ProductName,
	Inventories.InventoryDate,
	Inventories.Count,
	Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS EmployeeName
FROM 
	dbo.Categories
JOIN 
	dbo.Products
ON 
	Categories.CategoryID = Products.CategoryID
JOIN 
	dbo.Inventories
ON 
	Products.ProductID = Inventories.ProductID
JOIN 
	dbo.Employees
ON 
	Inventories.EmployeeID = Employees.EmployeeID
GO



-- Here is an example of some rows selected from the view:
-- CategoryName	  ProductName			InventoryDate	Count	EmployeeName
-- Beverages	  Chai					2017-01-01		39		Steven Buchanan
-- Beverages	  Chang					2017-01-01		17		Steven Buchanan
-- Beverages	  Chartreuse verte		2017-01-01		69		Steven Buchanan
-- Beverages	  Côte de Blaye			2017-01-01		17		Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01		20		Steven Buchanan
-- Beverages	  Ipoh Coffee			2017-01-01		17		Steven Buchanan
-- Beverages	  Lakkalikööri			2017-01-01		57		Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--SELECT 
--	Categories.CategoryName, 
--	Products.ProductName, 
--	Inventories.InventoryDate, 
--	Inventories.Count,
--	Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS EmployeeName
--FROM 
--	Categories
--JOIN 
--	Products
--ON 
--	Categories.CategoryID = Products.CategoryID
--JOIN 
--	Inventories
--ON 
--	Products.ProductID = Inventories.ProductID
--JOIN 
--	Employees
--ON 
--	Inventories.EmployeeID = Employees.EmployeeID
--WHERE 
--	ProductName = (
--		SELECT 
--			ProductName 
--		WHERE 
--			Products.ProductName = 'Chai' OR Products.ProductName = 'Chang')

CREATE VIEW vInventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING 
AS
SELECT 
	Categories.CategoryName, 
	Products.ProductName, 
	Inventories.InventoryDate, 
	Inventories.Count,
	Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS EmployeeName
FROM 
	dbo.Categories
JOIN 
	dbo.Products
ON 
	Categories.CategoryID = Products.CategoryID
JOIN 
	dbo.Inventories
ON 
	dbo.Products.ProductID = Inventories.ProductID
JOIN 
	dbo.Employees
ON 
	Inventories.EmployeeID = Employees.EmployeeID
WHERE 
	ProductName = (
		SELECT 
			ProductName 
		WHERE 
			Products.ProductName = 'Chai' OR Products.ProductName = 'Chang')
GO

-- Here are the rows selected from the view:

-- CategoryName		ProductName		InventoryDate	Count	EmployeeName
-- Beverages		Chai			2017-01-01		 39		Steven Buchanan
-- Beverages		Chang			2017-01-01		 17		Steven Buchanan
-- Beverages		Chai			2017-02-01		 49		Robert King
-- Beverages		Chang			2017-02-01		 27		Robert King
-- Beverages		Chai			2017-03-01		 59		Anne Dodsworth
-- Beverages		Chang			2017-03-01		 37		Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--SELECT 
--	emp.EmployeeFirstName + ' ' + emp.EmployeeLastName 
--	AS Employee, Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName 
--	AS Manager
--FROM 
--	Employees AS emp
--JOIN 
--	Employees AS Manager
--ON 
--	emp.EmployeeID = Manager.ManagerID

CREATE VIEW vEmployeesByManager
WITH SCHEMABINDING 
AS
SELECT 
	emp.EmployeeFirstName + ' ' + emp.EmployeeLastName 
	AS Employee, Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName 
	AS Manager
FROM 
	dbo.Employees AS emp
JOIN 
	dbo.Employees AS Manager
ON 
	emp.EmployeeID = Manager.ManagerID
GO


-- Here are teh rows selected from the view:
-- Manager				Employee
-- Andrew Fuller		Andrew Fuller
-- Andrew Fuller		Janet Leverling
-- Andrew Fuller		Laura Callahan
-- Andrew Fuller		Margaret Peacock
-- Andrew Fuller		Nancy Davolio
-- Andrew Fuller		Steven Buchanan
-- Steven Buchanan		Anne Dodsworth
-- Steven Buchanan		Michael Suyama
-- Steven Buchanan		Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--vInventoriesByProductsByCategoriesByEmployees
--Select * From [dbo].[vCategories]
--Select * From [dbo].[vProducts]
--Select * From [dbo].[vInventories]
--Select * From [dbo].[vEmployees]

--SELECT 
--	c.CategoryID, 
--	c.CategoryName,
--	p.ProductID,
--	p.ProductName,
--	p.UnitPrice,
--	i.InventoryID,
--	i.InventoryDate,
--	i.Count,
--	i.EmployeeID,
--	EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--FROM 
--	Categories AS c
--JOIN 
--	Products AS p
--ON 
--	c.CategoryID = p.CategoryID
--JOIN
--	Inventories AS i
--ON
--	i.ProductID = p.ProductID
--JOIN 
--	Employees AS e
--ON 
--	i.EmployeeID = e.EmployeeID

--ORDER BY 1,4,6,10
--DROP VIEW vInventoriesByProductsByCategoriesByEmployees

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
WITH SCHEMABINDING 
AS
SELECT 
	c.CategoryID, 
	c.CategoryName,
	p.ProductID,
	p.ProductName,
	p.UnitPrice,
	i.InventoryID,
	i.InventoryDate,
	i.Count,
	i.EmployeeID,
	Employee = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
	Manager = m.EmployeeFirstName + ' ' + m.EmployeeLastName

FROM 
	dbo.Categories AS c
JOIN 
	dbo.Products AS p
ON 
	c.CategoryID = p.CategoryID
JOIN
	dbo.Inventories AS i
ON
	i.ProductID = p.ProductID
JOIN 
	dbo.Employees AS e
ON 
	e.EmployeeID = i.EmployeeID
JOIN 
	dbo.Employees AS m
ON 
	m.EmployeeID = e.ManagerID
GO

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName				UnitPrice	InventoryID		InventoryDate	Count	EmployeeID		Employee
-- 1	          Beverages	    1	        Chai					18.00	    1				2017-01-01		39		5				Steven Buchanan
-- 1	          Beverages	    1	        Chai					18.00	    78				2017-02-01		49		7				Robert King
-- 1	          Beverages	    1	        Chai					18.00	    155				2017-03-01		59		9				Anne Dodsworth
-- 1	          Beverages	    2	        Chang					19.00	    2				2017-01-01		17		5				Steven Buchanan
-- 1	          Beverages	    2	        Chang					19.00	    79				2017-02-01		27		7				Robert King
-- 1	          Beverages	    2	        Chang					19.00	    156				2017-03-01		37		9				Anne Dodsworth
-- 1	          Beverages	    24			Guaraná Fantástica		4.50	    24				2017-01-01		20		5				Steven Buchanan
-- 1	          Beverages	    24			Guaraná Fantástica		4.50	    101				2017-02-01		30		7				Robert King
-- 1	          Beverages	    24			Guaraná Fantástica		4.50	    178				2017-03-01		40		9				Anne Dodsworth
-- 1	          Beverages	    34			Sasquatch Ale			14.00	    34				2017-01-01		111		5				Steven Buchanan
-- 1	          Beverages	    34			Sasquatch Ale			14.00	    111				2017-02-01		121		7				Robert King
-- 1	          Beverages	    34			Sasquatch Ale			14.00	    188				2017-03-01		131		9				Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)

Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories] ORDER BY 1,2
Select * From [dbo].[vInventoriesByProductsByDates] ORDER BY 1,2
Select * From [dbo].[vInventoriesByEmployeesByDates] ORDER BY 1,2
Select * From [dbo].[vInventoriesByProductsByCategories] ORDER BY 1,2
Select * From [dbo].[vInventoriesByProductsByEmployees] ORDER BY 3,1,2,5
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees] ORDER BY 3,1,2
Select * From [dbo].[vEmployeesByManager] ORDER BY 1,2
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees] ORDER BY 1,3,6,10
/***************************************************************************************/
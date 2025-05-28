DROP DATABASE IF EXISTS SuperMarket;

CREATE DATABASE SuperMarket;

USE SuperMarket;

DROP TABLE IF EXISTS Customer;

-- create table(4)

CREATE TABLE Customer(
Customer_Id INT IDENTITY(1,1) PRIMARY KEY,
Customer_Name NVARCHAR(50) NOT NULL,
Customer_Address NVARCHAR(50) NOT NULL);

DROP TABLE IF EXISTS Items;

CREATE TABLE Items(
Item_Code INT IDENTITY(101,1) PRIMARY KEY,
Item_Name NVARCHAR(50) NOT NULL,
Item_Price MONEY NOT NULL);

DROP TABLE IF EXISTS Bill;

CREATE TABLE Bill(
Bill_Number INT IDENTITY(1001,1) PRIMARY KEY,
Bill_Date DATE NOT NULL,
Customer_Id INT FOREIGN KEY REFERENCES Customer(Customer_Id),
Total_Bill_Price MONEY NOT NULL DEFAULT 0);

DROP TABLE IF EXISTS Bill_Operation;

CREATE TABLE Bill_Operation(
Bill_Id INT FOREIGN KEY REFERENCES Bill(Bill_Number),
Item_Id INT FOREIGN KEY REFERENCES Items(Item_Code),
Quantity INT DEFAULT 1,
Total_Price MONEY NOT NULL DEFAULT 0,
PRIMARY KEY (Bill_Id,Item_Id));

-- Add data with store procedure

DROP PROCEDURE IF EXISTS AddCustomer;

CREATE PROCEDURE AddCustomer
@Customer_Name NVARCHAR(50),
@Customer_Address NVARCHAR(50)
AS
BEGIN
	INSERT INTO Customer(Customer_Name,Customer_Address)
	VALUES (@Customer_Name,@Customer_Address)
END;

DROP PROCEDURE IF EXISTS AddItems;

CREATE PROCEDURE AddItems
@Item_Name NVARCHAR(50),
@Item_Price MONEY
AS
BEGIN
	INSERT INTO Items(Item_Name,Item_Price)
	VALUES (@Item_Name,@Item_Price)
END;

DROP PROCEDURE IF EXISTS AddOrderItem

CREATE PROCEDURE AddOrderItem
@Bill_Id INT,
@Item_Id INT,
@Quantity INT
AS
BEGIN
	INSERT INTO Bill_Operation(Bill_Id,Item_Id,Quantity)
	VALUES (@Bill_Id,@Item_Id,@Quantity)
END;

DROP PROCEDURE IF EXISTS AddBill;

CREATE PROCEDURE AddBill
@Bill_Date DATE,
@Customer_Id INT
AS
BEGIN
	INSERT INTO Bill(Bill_Date,Customer_Id)
	VALUES (@Bill_Date,@Customer_Id)
END;

-- trigger of bill and bill operation

DROP TRIGGER IF EXISTS After_Insert_Product;

CREATE TRIGGER After_Insert_Product 
ON Bill_Operation
AFTER INSERT
AS 
BEGIN
	UPDATE BO
	SET BO.Total_Price = BO.Quantity * IT.Item_Price
	FROM Bill_Operation BO
	JOIN inserted i ON BO.Item_Id = i.Item_Id AND BO.Bill_Id = i.Bill_Id
	JOIN Items IT ON i.Item_Id = IT.Item_Code
END;


DROP TRIGGER IF EXISTS After_Bill

CREATE TRIGGER After_Bill	
ON Bill_Operation
After Insert
AS
BEGIN
	UPDATE B
	SET B.Total_Bill_Price = (SELECT SUM(Total_Price)
							FROM Bill_Operation
							WHERE B.Bill_Number = Bill_Id)
	FROM Bill B
	JOIN inserted i ON B.Bill_Number = i.Bill_Id
END;



-- sample data


EXEC AddCustomer 'Sriram', 'Cuddalore';
EXEC AddCustomer 'Sairam', 'Chennai';

EXEC AddItems 'Soap', 20;
EXEC AddItems 'Rice', 100;

EXEC AddBill '2025-05-28', 1;
EXEC AddBill '2025-05-28', 2;

EXEC AddOrderItem 1001, 101, 2;
EXEC AddOrderItem 1001, 102, 1; 

EXEC AddOrderItem 1002, 101, 3;
EXEC AddOrderItem 1002, 102, 2;

SELECT * FROM Bill;
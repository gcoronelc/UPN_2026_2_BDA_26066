USE master;

IF EXISTS ( SELECT name FROM sysdatabases WHERE name = 'Northwind_DM' )
	DROP DATABASE Northwind_DM;

CREATE DATABASE Northwind_DM;
go

USE Northwind_DM;

CREATE TABLE PRODUCTO(
	idProducto			integer NOT NULL PRIMARY KEY,
	nomProducto			nvarchar(40) NOT NULL,
	idCategoria			integer NOT NULL,
	nomCategoria		nvarchar(15) NOT NULL );

CREATE TABLE CLIENTE(
	idCliente			nchar(5) NOT NULL PRIMARY KEY,
	nomCliente			nvarchar(40) NOT NULL,
	paisCliente			nvarchar(15) NULL );

CREATE TABLE PROVEEDOR(
	idProveedor			integer NOT NULL PRIMARY KEY,
	nomProveedor		nvarchar(40) NOT NULL,
	paisProveedor		nvarchar(15) NULL );

CREATE TABLE EMPLEADO(
	idEmpleado			integer NOT NULL PRIMARY KEY,
	nomEmpleado			nvarchar(40) NOT NULL,
	edadVenta			smallint NULL );


CREATE TABLE TIEMPO(
	fecha				date NOT NULL PRIMARY KEY,
	año					smallint NOT NULL,
	semestre			smallint NOT NULL,
	trimestre			smallint NOT NULL,
	mes					smallint NOT NULL );

CREATE TABLE VENTAS_FACT(
	VentaKey		integer NOT NULL IDENTITY(1,1) PRIMARY KEY,
	idVenta			integer NOT NULL,
	idProducto		integer NOT NULL FOREIGN KEY REFERENCES PRODUCTO,
	idCliente		nchar(5) NOT NULL FOREIGN KEY REFERENCES CLIENTE,
	idProveedor		integer NOT NULL FOREIGN KEY REFERENCES PROVEEDOR,
	idEmpleado		integer NOT NULL FOREIGN KEY REFERENCES EMPLEADO,
	fecha			date NOT NULL FOREIGN KEY REFERENCES TIEMPO,
	unidades		integer NOT NULL,
	precioVenta		money NOT NULL,
	monto			money NOT NULL );

select * from INFORMATION_SCHEMA.TABLES;


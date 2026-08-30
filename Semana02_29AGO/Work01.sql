USE RH;
GO

-- Función de Tabla en Linea

CREATE FUNCTION dbo.fn_empleados ( @p_dpto int )
RETURNS TABLE
AS
RETURN
	SELECT idempleado, apellido, nombre
	FROM dbo.empleado
	WHERE iddepartamento = @p_dpto;
GO


SELECT * FROM dbo.fn_empleados(103);
GO

SELECT * FROM dbo.fn_empleados(101);
GO


-- Función de tabla de múltiples instrucciones

CREATE FUNCTION dbo.fn_catalogo ( )
RETURNS @tabla TABLE
(
	codigo int identity(1,1) primary key not null,
	nombre varchar(50) not null,
	precio money not null
)
AS
BEGIN
INSERT INTO @tabla(nombre,precio) values('Televisor', 1500.00);
INSERT INTO @tabla(nombre,precio) values('Refrigeradora', 1450.00);
INSERT INTO @tabla(nombre,precio) values('Lavadora', 1350.00);
RETURN;
END;
GO

SELECT * FROM dbo.fn_catalogo();
GO

-- Ejercicio
/*
Se necesita saber de un departamento particular los siguientes datos:
- El nombre del departamento.
- La cantidad de empleados.
- El importe de su planilla.
Se debe crear una funcion de tipo tabla.
*/

ALTER FUNCTION dbo.fn_departamento ( @iddpto int)
RETURNS @tabla TABLE
(
	codigo int identity(1,1) primary key not null,
	atributo varchar(100) not null,
	valor varchar(100) not null
)
AS
BEGIN
	DECLARE @cont int, @nombre varchar(100);
	DECLARE @cant_emps int, @planilla money;
	-- Paso 1: Verificar si el departamento existe.
	SET @cont = ( select count(1) from dbo.departamento where iddepartamento = @iddpto );
	if ( @cont = 0 )
	begin
		insert into @tabla(atributo,valor) values('CONDICION','ID NO EXISTE EN LA TABLA DEPARTAMENTO');
		return;
	end;
	-- Paso 2: Nombre del departamento
	select @nombre = nombre from dbo.departamento where iddepartamento = @iddpto;
	insert into @tabla(atributo,valor) values('NOMBRE',@nombre);
	-- Paso 3: Verificar si tiene empleados
	SET @cant_emps = (select count(1) from dbo.empleado where iddepartamento = @iddpto);
	if (@cant_emps = 0)
	begin
		insert into @tabla(atributo,valor) values('CONDICION','NO TIENE EMPLEADOS');
		return;
	end;
	insert into @tabla(atributo,valor) values('CANT. EMPLEADOS',@cant_emps);
	-- Paso 4: Planilla
	SET @planilla = (select sum(sueldo) from empleado where iddepartamento = @iddpto)
	insert into @tabla(atributo,valor) values('IMPORTE PLANILLA',@planilla);
	RETURN;
END;
GO

select * from dbo.fn_departamento(1);
go

select * from dbo.fn_departamento(104);
go

select * from dbo.fn_departamento(105);
go











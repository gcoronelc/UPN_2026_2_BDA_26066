use EDUCA2;
go

select * from dbo.CURSO;
go

select * from dbo.ALUMNO;
go

select * from dbo.MATRICULA;
go

select * from dbo.PAGO;
go

select * from dbo.EMPLEADO;
go


-- Bloque anonimo

BEGIN
    -- Variables
	DECLARE @NUM1 INT, @NUM2 INT, @SUMA INT;
	-- Generando datos
	SET @NUM1 = CAST( RAND() * 100 AS INT );
	SET @NUM2 = CAST( RAND() * 100 AS INT );
	-- Proceso
	SET @SUMA = @NUM1 + @NUM2;
	-- Reporte
	PRINT CONCAT( 'NUM1 = ', @NUM1 );
	PRINT CONCAT( 'NUM2 = ', @NUM2 );
	PRINT CONCAT( 'SUMA = ', @SUMA );
END;
GO


CREATE FUNCTION dbo.fn_suma ( @num1 int, @num2 int )
RETURNS int
AS
BEGIN
	DECLARE @suma int;
	SET @suma = @num1 + @num2;
	RETURN @suma;
END;
GO

SELECT dbo.fn_suma( 24, 56 ) as suma;
GO


-- Antonela

CREATE FUNCTION DBO.mayor_de_tres_num

(

  @a INT,

  @b INT,

  @c INT

)

RETURNS INT

AS

BEGIN

  DECLARE @mayor INT;



  IF @a >= @b AND @a >= @c

    SET @mayor = @a;

  ELSE IF @b >= @a AND @b >= @c

    SET @mayor = @b;

  ELSE

    SET @mayor = @c;



  RETURN @mayor;

END;

GO





SELECT DBO.mayor_de_tres_num(8, 21, 10);

GO

-- Tocas Solis

CREATE FUNCTION dbo.fn_mayor (@num1 int, @num2 int, @num3 int)

RETURNS int

AS

BEGIN

  DECLARE @NUMEROMAYOR int;

  SET @NUMEROMAYOR = CASE

    WHEN @num1 >= @num2 AND @num1 >= @num3 THEN @num1

    WHEN @num2 >= @num1 AND @num2 >= @num3 THEN @num2

    ELSE @num3

  END;

  RETURN @NUMEROMAYOR;

END;

GO

SELECT dbo.fn_mayor(20, 18, 5);

GO



USE EDUCA2;
GO

-- Procedimiento Simple

CREATE PROCEDURE dbo.usp_lista_cursos
AS
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM dbo.curso;
END;
GO

EXEC dbo.usp_lista_cursos;
GO

-- Procedimiento con parametro de entrada

CREATE PROCEDURE dbo.usp_suma ( @num1 int, @num2 int )
AS
BEGIN
	DECLARE @suma int;
	SET @suma = @num1 + @num2;
	SELECT @num1 NUM1, @num2 NUM2, @suma SUMA;
END;
GO


EXEC dbo.usp_suma 100, 200;
GO


/*
En base al procedimiento anterior construir otro 
que calcule la suma y el producto de dos numeros.
*/


-- Consultar precio de un curso

CREATE PROCEDURE dbo.usp_precio ( @p_idcurso int, @p_precio money OUT )
AS
BEGIN
	SELECT @p_precio = cur_precio
	FROM dbo.CURSO
	WHERE cur_id = @p_idcurso;
END;
GO


ALTER PROCEDURE dbo.usp_precio ( @p_idcurso int, @p_precio money OUT )
AS
BEGIN
	DECLARE @cont int;
	SET @cont = (SELECT count(1) FROM CURSO WHERE cur_id = @p_idcurso);
	if (@cont=0)
	BEGIN
		SET @p_precio = -1;
		RETURN;
	END
	SELECT @p_precio = cur_precio
	FROM dbo.CURSO
	WHERE cur_id = @p_idcurso;
END;
GO

BEGIN
	DECLARE @precio money;
	set @precio = 777;
	EXEC dbo.usp_precio 3, @precio OUT;
	PRINT CONCAT( 'PRECIO: ', @precio );
END;
GO

BEGIN
	DECLARE @precio money;
	set @precio = 777;
	EXEC dbo.usp_precio 3333, @precio OUT;
	IF @precio = -1
		PRINT('El codigo del curso no existe');
	ELSE
		PRINT CONCAT( 'PRECIO: ', @precio );
END;
GO


ALTER PROCEDURE dbo.usp_precio2 ( @p_idcurso int, @p_precio money OUT )
AS
BEGIN
	DECLARE @cont int;
	select @cont = (select count(1) from CURSO WHERE cur_id = @p_idcurso);
	if (@cont=0)
	begin
		RAISERROR (
            'Codigo de curso no existe.', -- Mensaje (con formato)
            16, -- Severidad (11 a 19 lanzan error y van al bloque CATCH)
            1  -- Estado (Un valor de 1 a 127 para identificar este error específico)
        );
		return;
	end;
	SELECT @p_precio = cur_precio
	FROM dbo.CURSO
	WHERE cur_id = @p_idcurso;
END;
GO

BEGIN
	DECLARE @precio money;
	set @precio = 777;
	EXEC dbo.usp_precio2 3, @precio OUT;
	PRINT(@@ERROR);
	PRINT CONCAT( 'PRECIO: ', @precio );
END;
GO

BEGIN
	DECLARE @precio money;
	set @precio = 777;
	EXEC dbo.usp_precio2 3333, @precio OUT;
	IF @@ERROR =0
		PRINT CONCAT( 'PRECIO: ', @precio );
	ELSE
		PRINT(ERROR_MESSAGE());
END;
GO


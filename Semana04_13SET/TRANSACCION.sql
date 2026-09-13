alter PROCEDURE USP_MATRICULAR
(
	@idCurso int,              @idAlumno int,
	@idEmp int,                @tipo varchar(20),
	@cuotas int,               @estado int OUT, 	
	@precio NUMERIC(10,2) OUT,  @mensaje varchar(200) OUT
)
AS
BEGIN
DECLARE
	@cont NUMERIC(10,0);
BEGIN TRY
	BEGIN TRANSACTION;
	-- Bloque de código SQL a proteger
	-- Paso 1: Verificar si existe el curso
	SET @cont = (select count(1) from curso where cur_id=@idCurso);
	if(@cont=0)
	begin
		THROW 51000, 'El CURSO no existe.', 1;
	end;
	-- Paso 2: Verificar si ya esta matriculado
	SET @cont = (select count(1) from matricula 
		where cur_id=@idCurso and alu_id=@idAlumno );
	if(@cont>0)
	begin
		THROW 51000, 'Ya registra una maricula.', 1;
	end;
	-- Paso 3: Verificar si existe el empleado
	SET @cont = (select count(1) from empleado where emp_id=@idEmp);
	if(@cont=0)
	begin
		THROW 51000, 'Empleado no existe.', 1;
	end;
	-- Paso 4: validar el tipo
	SET @tipo = UPPER(@tipo);
	SET @cont = CHARINDEX(@tipo, 'REGULAR,MEDIABECA,BECA');
	if( @cont = 0 )
	begin
		THROW 51000, 'El tipo es incorrecto.', 1;
	end;
	-- Paso 5; Varificar cuota
	if( @cuotas<1 OR @cuotas>3)
	begin
		THROW 51000, 'Cantidad de cuotas es incorrects.', 1;
	end;
	if( (@tipo<>'REGULAR') AND (@cuotas<>1) )
	begin
		THROW 51000, 'Cantidad de cuotas es incorrects.', 1;
	end;
	-- Paso 6: Establece precio según el negocio
	select @precio = cur_precio from CURSO WITH (ROWLOCK)
	where cur_id = @idCurso;
	SET @precio = CASE
		when @tipo='MEDIABECA' then @precio * 0.50
		when @tipo='BECA' then @precio * 0.10
		else @precio END;
	-- Registrar matricula
	insert into MATRICULA(cur_id,alu_id,emp_id,mat_tipo,mat_fecha,mat_precio, mat_cuotas)
	values(@idCurso,@idAlumno,@idEmp,@tipo,GETDATE(),@precio,@cuotas)

	update CURSO
	set cur_matriculados = cur_matriculados + 1
	where cur_id = @idCurso;

	COMMIT TRANSACTION;
	SET @estado = 1;
END TRY
BEGIN CATCH
	-- Código para mostrar el mensaje de la excepción
	set @estado = -1;
	set @mensaje = ERROR_MESSAGE();
	ROLLBACK TRANSACTION;
	
END CATCH;
END;
GO

select * from curso where cur_id=5;
select * from matricula where cur_id=5;
go


declare @estado int, @precio numeric(10,2), @mensaje varchar(200);
exec usp_matricular 55, 1, 4,'BECA', 3, @estado OUT, @precio OUT, @mensaje OUT;
select @estado, @precio, @mensaje;
go

declare @estado int, @precio numeric(10,2), @mensaje varchar(200);
exec usp_matricular 1, 3, 4,'BECA', 3, @estado OUT, @precio OUT, @mensaje OUT;
select @estado, @precio, @mensaje;
go

declare @estado int, @precio numeric(10,2), @mensaje varchar(200);
exec usp_matricular 5, 3, 4,'BECAmundial', 3, @estado OUT, @precio OUT, @mensaje OUT;
select @estado, @precio, @mensaje;
go

declare @estado int, @precio numeric(10,2), @mensaje varchar(200);
exec usp_matricular 5, 3, 4,'REGULAR', 30, @estado OUT, @precio OUT, @mensaje OUT;
select @estado, @precio, @mensaje;
go

declare @estado int, @precio numeric(10,2), @mensaje varchar(200);
exec usp_matricular 5, 3, 4,'MEDIABECA', 3, @estado OUT, @precio OUT, @mensaje OUT;
select @estado, @precio, @mensaje;
go

declare @estado int, @precio numeric(10,2), @mensaje varchar(200);
exec usp_matricular 5, 3, 4,'REGULAR', 2, @estado OUT, @precio OUT, @mensaje OUT;
select @estado, @precio, @mensaje;
go

declare @estado int, @precio numeric(10,2), @mensaje varchar(200);
exec usp_matricular 5, 8, 4,'MEDIABECA', 1, @estado OUT, @precio OUT, @mensaje OUT;
select @estado, @precio, @mensaje;
go



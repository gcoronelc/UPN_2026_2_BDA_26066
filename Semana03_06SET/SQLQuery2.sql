use northwind;
go


create function fn_mcd
(@n1 int, @n2 int)
returns int
begin
	while(@n1 <> @n2)
	begin
		if( @n1 > @n2 )
			set @n1 = @n1 - @n2;
		else
			set @n2 = @n2 - @n1;
	end;
	return @n1;
end;
go

select dbo.fn_mcd(15,20) Buena;
go






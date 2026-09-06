-- Asegurarnos de que estamos usando la base de datos Northwind
USE Northwind;
GO

-- 1. Declarar las variables que guardarán los datos de cada fila
DECLARE @ProductID INT;
DECLARE @PrecioActual MONEY; -- Northwind usa el tipo de datos MONEY para los precios

-- Declarar el cursor usando buenas prácticas (LOCAL, FORWARD_ONLY y READ_ONLY para leer rápido)
DECLARE cursor_precios CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR 
    SELECT ProductID, UnitPrice 
    FROM Products 
    WHERE CategoryID = 1; -- Categoría 1 es 'Beverages' (Bebidas) en Northwind

-- 2. Abrir el cursor
OPEN cursor_precios;

-- 3. Leer la primera fila y guardar sus datos en las variables
FETCH NEXT FROM cursor_precios INTO @ProductID, @PrecioActual;

-- Bucle para recorrer el cursor fila por fila hasta que no queden más registros
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Aquí va la lógica: Le subiremos un 10% al precio actual de cada producto
    -- UPDATE Products 
    -- SET UnitPrice = @PrecioActual * 1.10 
    -- WHERE ProductID = @ProductID;

    print  cast(@ProductID as varchar(15)) + ' - ' + cast(@PrecioActual as varchar(20));

    -- Leer la siguiente fila para continuar el bucle
    FETCH NEXT FROM cursor_precios INTO @ProductID, @PrecioActual;
END;

-- 4. Cerrar el cursor al terminar el bucle
CLOSE cursor_precios;

-- 5. Liberar la memoria del servidor de manera inmediata
DEALLOCATE cursor_precios;
GO

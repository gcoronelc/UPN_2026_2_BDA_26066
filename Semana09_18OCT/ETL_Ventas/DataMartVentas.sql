/* ============================================================================
   UPN · Base de Datos Avanzadas y Big Data · Unidad II · Semana 7
   PASO 3 — MODELO DIMENSIONAL DE VENTAS (SQL SERVER)
   Archivo: DataMartVentas.sql
   Origen: ventas.csv (500 registros sintéticos) + Modelo_Dimensional_Ventas.docx v1.1

   Objetivo: crear un Data Mart en esquema estrella (3 dimensiones y 1 hecho).
   Ciudad es un atributo de DimCliente, NO una dimensión independiente.
   El script no carga ventas: la carga se realizará con Python (Paso 4).

   Ejecución: SQL Server Management Studio (SSMS) o Azure Data Studio
              sobre una instancia con permiso CREATE DATABASE.
   Reejecución: no elimina datos ni objetos existentes.
   NOTA: para reiniciar el laboratorio use una base nueva o un procedimiento
         de limpieza explícito autorizado por el docente.
   ============================================================================ */

USE master;
GO

IF DB_ID(N'DataMartVentas') IS NULL
BEGIN
    CREATE DATABASE DataMartVentas;
END;
GO

USE DataMartVentas;
GO

/* 1. DIMENSIÓN CLIENTE ---------------------------------------------------- */
IF OBJECT_ID(N'dbo.DimCliente', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimCliente
    (
        ClienteKey      INT IDENTITY(1,1) NOT NULL,
        IdCliente       VARCHAR(10)       NOT NULL,
        NombreCliente   NVARCHAR(100)     NOT NULL,
        Ciudad          NVARCHAR(80)      NULL,

        CONSTRAINT PK_DimCliente PRIMARY KEY (ClienteKey),
        CONSTRAINT UQ_DimCliente_IdCliente UNIQUE (IdCliente),
        CONSTRAINT CK_DimCliente_IdCliente_NoBlanco
            CHECK (LEN(LTRIM(RTRIM(IdCliente))) > 0),
        CONSTRAINT CK_DimCliente_Nombre_NoBlanco
            CHECK (LEN(LTRIM(RTRIM(NombreCliente))) > 0),
        CONSTRAINT CK_DimCliente_Ciudad_NoBlanco
            CHECK (Ciudad IS NULL OR LEN(LTRIM(RTRIM(Ciudad))) > 0)
    );
END;
GO

/* 2. DIMENSIÓN PRODUCTO --------------------------------------------------- */
IF OBJECT_ID(N'dbo.DimProducto', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimProducto
    (
        ProductoKey     INT IDENTITY(1,1) NOT NULL,
        IdProducto      VARCHAR(10)       NOT NULL,
        NombreProducto  NVARCHAR(120)     NOT NULL,
        Categoria       NVARCHAR(80)      NOT NULL,

        CONSTRAINT PK_DimProducto PRIMARY KEY (ProductoKey),
        CONSTRAINT UQ_DimProducto_IdProducto UNIQUE (IdProducto),
        CONSTRAINT CK_DimProducto_IdProducto_NoBlanco
            CHECK (LEN(LTRIM(RTRIM(IdProducto))) > 0),
        CONSTRAINT CK_DimProducto_Nombre_NoBlanco
            CHECK (LEN(LTRIM(RTRIM(NombreProducto))) > 0),
        CONSTRAINT CK_DimProducto_Categoria_NoBlanco
            CHECK (LEN(LTRIM(RTRIM(Categoria))) > 0)
    );
END;
GO

/* 3. DIMENSIÓN FECHA ------------------------------------------------------ */
IF OBJECT_ID(N'dbo.DimFecha', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimFecha
    (
        FechaKey        INT       NOT NULL,   -- AAAAMMDD, ejemplo: 20260709
        FechaCompleta   DATE      NOT NULL,
        Dia             TINYINT   NOT NULL,
        Mes             TINYINT   NOT NULL,
        Trimestre       TINYINT   NOT NULL,
        Anio            SMALLINT  NOT NULL,

        CONSTRAINT PK_DimFecha PRIMARY KEY (FechaKey),
        CONSTRAINT UQ_DimFecha_FechaCompleta UNIQUE (FechaCompleta),
        CONSTRAINT CK_DimFecha_Dia CHECK (Dia BETWEEN 1 AND 31),
        CONSTRAINT CK_DimFecha_Mes CHECK (Mes BETWEEN 1 AND 12),
        CONSTRAINT CK_DimFecha_Trimestre CHECK (Trimestre BETWEEN 1 AND 4),
        CONSTRAINT CK_DimFecha_Coherencia CHECK
        (
            FechaKey = CONVERT(INT, CONVERT(CHAR(8), FechaCompleta, 112))
            AND Dia = DATEPART(DAY, FechaCompleta)
            AND Mes = DATEPART(MONTH, FechaCompleta)
            AND Trimestre = DATEPART(QUARTER, FechaCompleta)
            AND Anio = DATEPART(YEAR, FechaCompleta)
        )
    );
END;
GO

/* 4. TABLA DE HECHOS ------------------------------------------------------ */
IF OBJECT_ID(N'dbo.FactVentas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactVentas
    (
        VentaKey        BIGINT IDENTITY(1,1) NOT NULL,
        IdVentaOrigen   VARCHAR(20)         NOT NULL,
        ClienteKey      INT                 NOT NULL,
        ProductoKey     INT                 NOT NULL,
        FechaKey        INT                 NOT NULL,
        Cantidad        INT                 NOT NULL,
        PrecioUnitario  DECIMAL(12,2)       NOT NULL,
        ImporteBruto    DECIMAL(18,2)       NOT NULL,

        CONSTRAINT PK_FactVentas PRIMARY KEY (VentaKey),
        CONSTRAINT UQ_FactVentas_IdVentaOrigen UNIQUE (IdVentaOrigen),
        CONSTRAINT FK_FactVentas_Cliente FOREIGN KEY (ClienteKey)
            REFERENCES dbo.DimCliente (ClienteKey),
        CONSTRAINT FK_FactVentas_Producto FOREIGN KEY (ProductoKey)
            REFERENCES dbo.DimProducto (ProductoKey),
        CONSTRAINT FK_FactVentas_Fecha FOREIGN KEY (FechaKey)
            REFERENCES dbo.DimFecha (FechaKey),
        CONSTRAINT CK_FactVentas_Origen_NoBlanco
            CHECK (LEN(LTRIM(RTRIM(IdVentaOrigen))) > 0),
        CONSTRAINT CK_FactVentas_Cantidad_Positiva CHECK (Cantidad > 0),
        CONSTRAINT CK_FactVentas_Precio_Positivo CHECK (PrecioUnitario > 0),
        CONSTRAINT CK_FactVentas_Importe_Coherente CHECK
        (
            ImporteBruto = CONVERT(DECIMAL(18,2), Cantidad * PrecioUnitario)
        )
    );
END;
GO

/* 5. ÍNDICES DE APOYO A LAS RELACIONES Y CONSULTAS ------------------------ */
IF OBJECT_ID(N'dbo.FactVentas', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes
                   WHERE object_id = OBJECT_ID(N'dbo.FactVentas')
                     AND name = N'IX_FactVentas_ClienteKey')
        CREATE INDEX IX_FactVentas_ClienteKey ON dbo.FactVentas (ClienteKey);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes
                   WHERE object_id = OBJECT_ID(N'dbo.FactVentas')
                     AND name = N'IX_FactVentas_ProductoKey')
        CREATE INDEX IX_FactVentas_ProductoKey ON dbo.FactVentas (ProductoKey);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes
                   WHERE object_id = OBJECT_ID(N'dbo.FactVentas')
                     AND name = N'IX_FactVentas_FechaKey')
        CREATE INDEX IX_FactVentas_FechaKey ON dbo.FactVentas (FechaKey);
END;
GO

/* 6. INSPECCIÓN INICIAL: ANTES DE LA CARGA ETL ---------------------------- */
SELECT 'DimCliente' AS Tabla, COUNT_BIG(*) AS Filas FROM dbo.DimCliente
UNION ALL SELECT 'DimProducto', COUNT_BIG(*) FROM dbo.DimProducto
UNION ALL SELECT 'DimFecha', COUNT_BIG(*) FROM dbo.DimFecha
UNION ALL SELECT 'FactVentas', COUNT_BIG(*) FROM dbo.FactVentas;
GO

/* 7. CONSULTAS SUGERIDAS DESPUÉS DE LA CARGA CON PYTHON -------------------
   No se ejecutan automáticamente. Descomente tras finalizar el ETL.

-- Ventas por categoría
SELECT p.Categoria, SUM(f.ImporteBruto) AS ImporteTotal
FROM dbo.FactVentas AS f
JOIN dbo.DimProducto AS p ON p.ProductoKey = f.ProductoKey
GROUP BY p.Categoria
ORDER BY ImporteTotal DESC;

-- Ventas por ciudad del cliente (NO ciudad de transacción)
SELECT c.Ciudad, SUM(f.ImporteBruto) AS ImporteTotal
FROM dbo.FactVentas AS f
JOIN dbo.DimCliente AS c ON c.ClienteKey = f.ClienteKey
GROUP BY c.Ciudad
ORDER BY ImporteTotal DESC;

-- Evolución mensual
SELECT d.Anio, d.Mes, SUM(f.ImporteBruto) AS ImporteTotal
FROM dbo.FactVentas AS f
JOIN dbo.DimFecha AS d ON d.FechaKey = f.FechaKey
GROUP BY d.Anio, d.Mes
ORDER BY d.Anio, d.Mes;

-- Verificación de duplicados de claves de origen (esperado: ninguna fila)
SELECT IdVentaOrigen, COUNT(*) AS Repeticiones
FROM dbo.FactVentas
GROUP BY IdVentaOrigen
HAVING COUNT(*) > 1;

-- Conciliación: comparar con los totales de filas aceptadas por el ETL
SELECT COUNT_BIG(*) AS LineasCargadas,
       SUM(CAST(Cantidad AS BIGINT)) AS Unidades,
       SUM(ImporteBruto) AS ImporteBrutoTotal
FROM dbo.FactVentas;
*/
GO

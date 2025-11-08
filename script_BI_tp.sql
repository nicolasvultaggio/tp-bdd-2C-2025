USE GD2C2025;
GO


-- DIMENSIONES 

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Sede (
    sede_codigo BIGINT PRIMARY KEY,
    sede_nombre NVARCHAR(255) NOT NULL,
    localidad_nombre NVARCHAR(255),
    provincia_nombre NVARCHAR(255),
    sede_mail NVARCHAR(255),
    institucion_cuit NVARCHAR(255),
    institucion_nombre NVARCHAR(255),
    institucion_razon NVARCHAR(255),
    FOREIGN KEY (sede_codigo) REFERENCES LOS_LINDOS.Sede(codigo)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno (
    rango_etario_alumno_id TINYINT PRIMARY KEY,
    rango_desc VARCHAR(10) NOT NULL CHECK (rango_desc IN ('<25', '25-35', '35-50', '>50'))
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor (
    rango_etario_profesor_id TINYINT PRIMARY KEY,
    rango_desc VARCHAR(10) NOT NULL CHECK (rango_desc IN ('25-35', '35-50', '>50'))
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Turno (
    turno_codigo BIGINT PRIMARY KEY,
    turno_nombre VARCHAR(255) NOT NULL,
    FOREIGN KEY (turno_codigo) REFERENCES LOS_LINDOS.Turno(codigo)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Categoria_Curso (
    categoria_codigo BIGINT PRIMARY KEY,
    categoria_nombre VARCHAR(255) NOT NULL,
    FOREIGN KEY (categoria_codigo) REFERENCES LOS_LINDOS.Categoria(codigo)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Medio_Pago (
    medio_pago_codigo BIGINT PRIMARY KEY,
    medio_pago_nombre NVARCHAR(50) NOT NULL,
    FOREIGN KEY (medio_pago_codigo) REFERENCES LOS_LINDOS.Medio_Pago(codigo)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion (
    bloque_satisfaccion_id TINYINT PRIMARY KEY,
    bloque_desc VARCHAR(15) NOT NULL CHECK (bloque_desc IN ('Satisfecho', 'Neutral', 'Insatisfecho')),
    nota_min TINYINT NOT NULL,
    nota_max TINYINT NOT NULL
);
GO
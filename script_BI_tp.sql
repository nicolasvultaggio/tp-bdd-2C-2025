USE GD2C2025;
GO


-- Dimensiones

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Sede (
    codigo_sede         BIGINT,
    nombre              NVARCHAR(255) NOT NULL,
    localidad           NVARCHAR(255),
    provincia           NVARCHAR(255),
    mail                NVARCHAR(255),
    cuit_institucion    NVARCHAR(255),
    nombre_institucion  NVARCHAR(255),
    razon_institucion   NVARCHAR(255)
    PRIMARY KEY (codigo_sede)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno (
    codigo_rango        BIGINT IDENTITY(1,1),
    descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('<25', '25-35', '35-50', '>50')),
    PRIMARY KEY (codigo_rango)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor (
    codigo_rango        BIGINT IDENTITY(1,1),
    descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('25-35', '35-50', '>50')),
    PRIMARY KEY (codigo_rango)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Turno (
    codigo_turno        BIGINT,
    nombre              VARCHAR(255) NOT NULL,
    PRIMARY KEY (codigo_turno)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Categoria_Curso (
    codigo_categoria    BIGINT,
    nombre              VARCHAR(255) NOT NULL,
    PRIMARY KEY (codigo_categoria)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Medio_Pago (
    codigo_medio_pago   BIGINT,
    descripcion         NVARCHAR(50) NOT NULL,
    PRIMARY KEY (codigo_medio_pago)
);
GO

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion (
    codigo_bloque       BIGINT IDENTITY(1,1),
    descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('satisfechos', 'neutrales', 'insatisfechos')),
    PRIMARY KEY (codigo_bloque)
);
GO


--Tablas de hechos

/*
1. Categorías y turnos más solicitados. Las 3 categorías de cursos y turnos con 
mayor cantidad de inscriptos por año por sede. 

Está bien que agrupe por turno y categoría porque se pide top 3 agrupados por categorias Y turnos.
*/
select distinct year(fecha) from LOS_LINDOS.Inscripcion_Curso

CREATE TABLE LOS_LINDOS.BI_FACT_Inscripciones_Por_Categoria_Turno (
    anio                     INT NOT NULL CHECK(anio in (2019,2020,2021,2022,2023,2024)),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    codigo_turno             BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Turno(codigo_turno),
    codigo_categoria         BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    cantidad_inscripciones   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, codigo_sede, codigo_turno, codigo_categoria)
);
GO

/*
2. Tasa de rechazo de inscripciones: Porcentaje de inscripciones rechazadas por 
mes por sede (sobre el total de inscripciones). 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Rechazos_Inscripciones (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    mes                      INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    cantidad_inscripciones_rechazadas      INT NOT NULL DEFAULT  0,
    cantidad_inscripciones_total           INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, mes, codigo_sede)
);
GO

/*
3.Comparación de desempeño de cursada por sede:
Porcentaje de aprobación de cursada por sede, por año. 
Se considera aprobada la cursada de un alumno cuando tiene nota mayor o igual a 4 en todos los módulos y el TP. 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Desempenio_Cursada (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    cantidad_aprobados       INT NOT NULL DEFAULT 0,
    cantidad_desaprobados    INT NOT NULL DEFAULT 0,
    cantidad_cursadas        INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, codigo_sede)
);
GO

/*
4.Tiempo promedio de finalización de curso: Tiempo promedio entre el inicio del curso y la aprobación del final según la categoría de los cursos, por año. (Tener en cuenta el año de inicio del curso) 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Tiempo_Promedio_Finalizacion (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    codigo_categoria         BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    tiempo_promedio_dias     DECIMAL(10,2) NULL,
    PRIMARY KEY (anio, codigo_categoria)
);
GO

/*
5. Nota promedio de finales. Promedio de nota de finales según el rango etario del 
alumno y la categoría del curso por semestre. 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Nota_Promedio_Finales (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    cuatrimestre             INT NOT NULL CHECK (cuatrimestre IN (1,2)),
    codigo_categoria         BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    codigo_rango_alumno      BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno(codigo_rango),
    promedio_nota            DECIMAL(5,2) NULL,
    PRIMARY KEY (anio, cuatrimestre, codigo_categoria, codigo_rango_alumno)
);
GO

/*
6. Tasa de ausentismo finales: Porcentaje de ausentes a finales (sobre la cantidad 
de inscriptos) por semestre por sede. 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Ausentismo_Finales (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    cuatrimestre             INT NOT NULL CHECK (cuatrimestre IN (1,2)),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    cantidad_ausentes        INT NOT NULL DEFAULT 0,
    cantidad_inscriptos      INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, cuatrimestre, codigo_sede)
);
GO

/*
7. Desvío de pagos: Porcentaje de pagos realizados fuera de término por semestre.
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Pagos_Fuera_Termino (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    cuatrimestre             INT NOT NULL CHECK (cuatrimestre IN (1,2)),
    cantidad_fuera_termino   INT NOT NULL DEFAULT 0,
    cantidad_total_pagos     INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, cuatrimestre)
);
GO

/*
8. Tasa de Morosidad Financiera mensual. Se calcula teniendo en cuenta el total 
de importes adeudados sobre facturación esperada en el mes. El monto adeudado se obtiene a partir de las facturas que no tengan pago registrado en dicho mes. 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Morosidad_Mensual (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    mes                      INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    monto_adeudado           DECIMAL(18,2) NOT NULL DEFAULT 0,
    facturacion_esperada     DECIMAL(18,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, mes)
);
GO

/*
9. Ingresos por categoría de cursos: Las 3 categorías de cursos que generan 
mayores ingresos por sede, por año. 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Ingresos_Por_Categoria (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    codigo_categoria         BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    ingresos                 DECIMAL(18,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, codigo_sede, codigo_categoria)
);
GO

/*
10. Índice de satisfacción. Índice de satisfacción anual, según rango etario de los 
profesores y sede. El índice de satisfacción es igual a ((% satisfechos %insatisfechos) +100)/2. 
Teniendo en cuenta que 
Satisfechos: Notas entre 7 y 10 
Neutrales: Notas entre 5 y 6 
Insatisfechos: Notas entre 1 y 4 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Indice_Satisfaccion (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024)),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    codigo_rango_profesor    BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor(codigo_rango),
    codigo_bloque            BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion(codigo_bloque),
    cantidad_finales_bloque_satisfaccion          INT NOT NULL DEFAULT 0,
    cantidad_total_finales                        INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, codigo_sede, codigo_rango_profesor, codigo_bloque)
);
GO

-- Migración de tablas de dimensiones


INSERT INTO LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno VALUES
(1, '<25'), (2, '25-35'), (3, '35-50'), (4, '>50');

INSERT INTO LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor VALUES
(1, '25-35'), (2, '35-50'), (3, '>50');

INSERT INTO LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion VALUES
(1, 'Satisfecho', 7, 10),
(2, 'Neutral', 5, 6),
(3, 'Insatisfecho', 1, 4);



-- Migracion de tablas de hechos




-- Creación de vistas


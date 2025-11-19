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

INSERT INTO LOS_LINDOS.BI_DIMENSION_Sede
SELECT
    s.codigo,
    s.nombre,
    l.nombre,
    p.nombre,
    s.mail,
    s.cuit_institucion,
    i.nombre,
    i.razon
FROM LOS_LINDOS.Sede s
         JOIN LOS_LINDOS.Localidad l ON l.codigo=s.codigo_localidad
         JOIN LOS_LINDOS.Provincia p ON p.codigo=s.codigo_provincia
         JOIN LOS_LINDOS.Institucion i ON i.cuit=s.cuit_institucion


CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno (
    codigo_rango        BIGINT IDENTITY(1,1),
    descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('<25', '25-35', '35-50', '>50')),
    PRIMARY KEY (codigo_rango)
);
GO


INSERT INTO LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno (descripcion) VALUES ('<25'), ('25-35'), ('35-50'), ('>50');

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor (
    codigo_rango        BIGINT IDENTITY(1,1),
    descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('25-35', '35-50', '>50')),
    PRIMARY KEY (codigo_rango)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor (descripcion) VALUES ('25-35'), ('35-50'), ('>50');


CREATE TABLE LOS_LINDOS.BI_DIMENSION_Turno (
    codigo_turno        BIGINT,
    nombre              VARCHAR(255) NOT NULL,
    PRIMARY KEY (codigo_turno)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Turno
    SELECT * FROM LOS_LINDOS.Turno;

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Categoria_Curso (
    codigo_categoria    BIGINT,
    nombre              VARCHAR(255) NOT NULL,
    PRIMARY KEY (codigo_categoria)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Categoria_Curso
SELECT DISTINCT
    c.codigo_categoria,
    ca.nombre
FROM LOS_LINDOS.Curso c
         JOIN LOS_LINDOS.Categoria ca ON c.codigo_categoria=ca.codigo


CREATE TABLE LOS_LINDOS.BI_DIMENSION_Medio_Pago (
    codigo_medio_pago   BIGINT,
    descripcion         NVARCHAR(50) NOT NULL,
    PRIMARY KEY (codigo_medio_pago)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Medio_Pago
    SELECT * FROM LOS_LINDOS.Medio_Pago

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion (
     codigo_bloque       BIGINT IDENTITY(1,1),
     descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('Satisfechos', 'Neutrales', 'Insatisfechos')),
     nota_minima         BIGINT,
     nota_maxima         BIGINT
     PRIMARY KEY (codigo_bloque)
);
GO


INSERT INTO LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion (descripcion,nota_minima,nota_maxima) VALUES
('Satisfechos', 7, 10),
('Neutrales', 5, 6),
('Insatisfechos', 0, 4);


--Tablas de hechos

/*
1. Categorias y turnos mas solicitados. Las 3 categorias de cursos y turnos con 
mayor cantidad de inscriptos por anio por sede. 

Esta bien que agrupe por turno y categoria porque se pide top 3 agrupados por categorias Y turnos.
*/


CREATE TABLE LOS_LINDOS.BI_FACT_Inscripciones_Por_Categoria_Turno (
    anio                     INT NOT NULL CHECK(anio in (2019,2020,2021,2022,2023,2024,2025)),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    codigo_turno             BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Turno(codigo_turno),
    codigo_categoria         BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    cantidad_inscripciones   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, codigo_sede, codigo_turno, codigo_categoria)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Inscripciones_Por_Categoria_Turno (anio,codigo_sede,codigo_turno,codigo_categoria, cantidad_inscripciones)
SELECT
    YEAR(ic.fecha) as anio,
    c.codigo_sede,
    c.codigo_turno,
    c.codigo_categoria,
    COUNT (*) AS cant_inscripciones
    FROM LOS_LINDOS.Inscripcion_Curso ic
        JOIN LOS_LINDOS.Curso c ON c.codigo=ic.curso_codigo
    GROUP BY YEAR(ic.fecha), c.codigo_sede, c.codigo_categoria, c.codigo_turno
GO

CREATE OR ALTER VIEW LOS_LINDOS.VISTA_Inscripciones_Por_Categoria_Turno_TOP3
AS
SELECT 
    f.anio,
    s.nombre AS sede,
    cat.nombre AS categoria,
    t.nombre AS turno,
    f.cantidad_inscripciones AS inscriptos
FROM LOS_LINDOS.BI_FACT_Inscripciones_Por_Categoria_Turno f
JOIN LOS_LINDOS.BI_DIMENSION_Sede s                 ON s.codigo_sede = f.codigo_sede
JOIN LOS_LINDOS.BI_DIMENSION_Categoria_Curso cat    ON cat.codigo_categoria = f.codigo_categoria
JOIN LOS_LINDOS.BI_DIMENSION_Turno t                ON t.codigo_turno = f.codigo_turno
WHERE EXISTS (
    SELECT *
    FROM (
        SELECT TOP 3 
               codigo_categoria, 
               codigo_turno
        FROM LOS_LINDOS.BI_FACT_Inscripciones_Por_Categoria_Turno f2
        WHERE f2.anio = f.anio AND f2.codigo_sede = f.codigo_sede
        ORDER BY cantidad_inscripciones DESC,
                 codigo_categoria ASC,
                 codigo_turno ASC
    ) top3
    WHERE top3.codigo_categoria = f.codigo_categoria AND top3.codigo_turno = f.codigo_turno
)


GO

-- Poner explicación en hoja de justificaciones
CREATE OR ALTER VIEW LOS_LINDOS.vw_Top3_Categorias_Turnos_Por_Anio_Sede
AS
WITH RankedCombinations AS (
    SELECT 
        f.anio,
        s.nombre sede_nombre,
        cat.nombre categoria_nombre,
        t.nombre turno_nombre,
        f.cantidad_inscripciones,
        ROW_NUMBER() OVER (
            PARTITION BY f.anio, f.codigo_sede 
            ORDER BY f.cantidad_inscripciones DESC, 
                     cat.nombre, 
                     t.nombre
        ) AS ranking
    FROM LOS_LINDOS.BI_FACT_Inscripciones_Por_Categoria_Turno f
    JOIN LOS_LINDOS.BI_DIMENSION_Sede s ON s.codigo_sede = f.codigo_sede
    JOIN LOS_LINDOS.BI_DIMENSION_Categoria_Curso cat ON cat.codigo_categoria = f.codigo_categoria
    JOIN LOS_LINDOS.BI_DIMENSION_Turno t ON t.codigo_turno = f.codigo_turno
)
SELECT 
    anio,
    sede_nombre AS sede,
    categoria_nombre AS categoria,
    turno_nombre AS turno,
    cantidad_inscripciones AS inscriptos,
    ranking AS posicion_top
FROM RankedCombinations
WHERE ranking <= 3;
GO

/*
2. Tasa de rechazo de inscripciones: Porcentaje de inscripciones rechazadas por 
mes por sede (sobre el total de inscripciones). 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Rechazos_Inscripciones (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)),
    mes                      INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    cantidad_inscripciones_rechazadas      INT NOT NULL DEFAULT  0,
    cantidad_inscripciones_total           INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, mes, codigo_sede)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Rechazos_Inscripciones
SELECT
    YEAR(i.fecha),
    MONTH(i.fecha),
    c.codigo_sede,
    COUNT(CASE WHEN e.nombre_tipo_estado = 'Rechazada' THEN 1 ELSE NULL END),
    COUNT(*)
FROM LOS_LINDOS.Inscripcion_Curso i
    JOIN LOS_LINDOS.Curso c ON c.codigo=i.curso_codigo
    JOIN LOS_LINDOS.Estado_de_Inscripción ei ON ei.numero_inscripcion_curso=i.numero
    JOIN LOS_LINDOS.Estado e ON e.codigo_estado=ei.codigo_estado
GROUP BY YEAR(i.fecha), MONTH(i.fecha), c.codigo_sede;
GO

CREATE VIEW LOS_LINDOS.VISTA_Rechazos_Inscripciones AS
    SELECT
        f.anio,
        f.mes,
        f.codigo_sede,
        s.nombre,
        f.cantidad_inscripciones_rechazadas,
        f.cantidad_inscripciones_total,
        CASE WHEN f.cantidad_inscripciones_total = 0 THEN 0
        ELSE CAST (f.cantidad_inscripciones_rechazadas AS DECIMAL (10,4))/f.cantidad_inscripciones_total
        END AS taza_de_rechazo
FROM LOS_LINDOS.BI_FACT_Rechazos_Inscripciones f
JOIN LOS_LINDOS.BI_DIMENSION_Sede s ON s.codigo_sede=f.codigo_sede
GO

/*
3.Comparacion de desempenio de cursada por sede:
Porcentaje de aprobacion de cursada por sede, por anio.
Se considera aprobada la cursada de un alumno cuando tiene nota mayor o igual a 4 en todos los modulos y el TP.
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Desempenio_Cursada (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)) ,
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    cantidad_aprobados       INT NOT NULL DEFAULT 0,
    cantidad_cursadas        INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, codigo_sede)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Desempenio_Cursada (anio, codigo_sede, cantidad_aprobados, cantidad_cursadas)
SELECT DISTINCT
    YEAR(c.fecha_inicio),
    c.codigo_sede,
    (SELECT COUNT(*)
    FROM LOS_LINDOS.Curso_x_Alumno ca
    JOIN LOS_LINDOS.Curso cc on cc.codigo = ca.codigo_curso
    WHERE YEAR(cc.fecha_inicio) = YEAR(c.fecha_inicio) AND cc.codigo_sede = c.codigo_sede AND
    (SELECT tp.nota FROM LOS_LINDOS.Trabajo_Practico tp WHERE tp.codigo_curso = ca.codigo_curso and tp.legajo_alumno =ca.legajo_alumno) > 3 AND
    (SELECT COUNT(*) FROM LOS_LINDOS.Parcial p WHERE p.codigo_curso = cc.codigo) = (SELECT COUNT(*) FROM LOS_LINDOS.Parcial_de_alumno pa JOIN LOS_LINDOS.Parcial p on p.codigo=pa.codigo_parcial WHERE p.codigo_curso = ca.codigo_curso AND ca.legajo_alumno = pa.legajo_alumno AND pa.nota >3 )
    ),
    (SELECT COUNT(*) FROM LOS_LINDOS.Curso_x_Alumno ca JOIN LOS_LINDOS.Curso cc ON cc.codigo = ca.codigo_curso WHERE YEAR(cc.fecha_inicio) = YEAR(c.fecha_inicio) AND cc.codigo_sede = c.codigo_sede)
FROM LOS_LINDOS.Curso c group by YEAR(c.fecha_inicio), c.codigo_sede
GO

CREATE VIEW LOS_LINDOS.VISTA_Desempenio_Cursada AS
    SELECT
        dc.anio,
        s.nombre,
        dc.cantidad_aprobados,
        cantidad_cursadas,
        CASE WHEN cantidad_cursadas = 0 THEN 0
        ELSE CAST (cantidad_aprobados AS DECIMAL(10,4)) / CAST(cantidad_cursadas AS DECIMAL(10,4))
        END AS porcentaje_de_aprobados
FROM LOS_LINDOS.BI_FACT_Desempenio_Cursada dc
        JOIN LOS_LINDOS.BI_DIMENSION_Sede s ON s.codigo_sede = dc.codigo_sede;
GO

SELECT * FROM LOS_LINDOS.VISTA_Desempenio_Cursada

/*
4.Tiempo promedio de finalizacion de curso: 
Tiempo promedio entre el inicio del curso 
y la aprobacion del final segun la categoria de los cursos, por anio.
(Tener en cuenta el anio de inicio del curso) 
*/

CREATE TABLE LOS_LINDOS.BI_FACT_Tiempo_Promedio_Finalizacion (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)),
    codigo_categoria         BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    tiempo_promedio_dias     DECIMAL(10,2) NULL,
    PRIMARY KEY (anio, codigo_categoria)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Tiempo_Promedio_Finalizacion (anio,codigo_categoria, tiempo_promedio_dias)
SELECT
    YEAR(c.fecha_inicio) AS anio,
    c.codigo_categoria,
    AVG(DATEDIFF (DAY,c.fecha_inicio,f.fecha)) AS tiempo_promedio_en_dias
FROM LOS_LINDOS.Curso c
JOIN LOS_LINDOS.Examen_final f ON f.codigo_curso=c.codigo
JOIN LOS_LINDOS.Examen_Final_de_Alumno fa ON fa.codigo_final=f.codigo WHERE fa.nota >=4
GROUP BY YEAR(c.fecha_inicio), c.codigo_categoria
GO

CREATE VIEW LOS_LINDOS.VISTA_Tiempo_Promedio_Finalizacion AS
    SELECT
        anio,
        c.nombre,
        tiempo_promedio_dias
    FROM LOS_LINDOS.BI_FACT_Tiempo_Promedio_Finalizacion tpf
            JOIN LOS_LINDOS.BI_DIMENSION_Categoria_Curso c on c.codigo_categoria = tpf.codigo_categoria
GO


/*
5. Nota promedio de finales. Promedio de nota de finales segun el rango etario del 
alumno y la categoria del curso por semestre. 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Nota_Promedio_Finales (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)),
    cuatrimestre             INT NOT NULL CHECK (cuatrimestre IN (1,2)),
    codigo_categoria         BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    codigo_rango_alumno      BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno(codigo_rango),
    promedio_nota            DECIMAL(5,2) NULL,
    PRIMARY KEY (anio, cuatrimestre, codigo_categoria, codigo_rango_alumno)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Nota_Promedio_Finales (anio,cuatrimestre, codigo_categoria, codigo_rango_alumno, promedio_nota)
SELECT
    YEAR(f.fecha) AS anio,
    CASE WHEN MONTH(f.fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    c.codigo_categoria,
    r.codigo_rango,
    AVG(fa.nota) AS promedio_nota
FROM LOS_LINDOS.Examen_Final_de_Alumno fa
JOIN LOS_LINDOS.Examen_Final f ON f.codigo=fa.codigo_final
JOIN LOS_LINDOS.Curso c on c.codigo=f.codigo_curso
JOIN LOS_LINDOS.Alumno a ON a.legajo=fa.legajo_alumno
JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno r ON
    (DATEDIFF (YEAR,a.fecha_nacimiento,f.fecha)<25 AND r.descripcion= '<25')
    OR
    (DATEDIFF (YEAR,a.fecha_nacimiento,f.fecha) BETWEEN 25 AND 35 AND r.descripcion= '25-35')
    OR
    (DATEDIFF (YEAR,a.fecha_nacimiento,f.fecha) BETWEEN 35 AND 50 AND r.descripcion= '35-50')
    OR
    (DATEDIFF (YEAR,a.fecha_nacimiento,f.fecha)>50 AND r.descripcion= '>50')
GROUP BY
    YEAR(f.fecha),
    CASE WHEN MONTH(f.fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    c.codigo_categoria,
    r.codigo_rango
GO

CREATE VIEW LOS_LINDOS.VISTA_Nota_Promedio_Finales AS
    SELECT
        anio,
        cuatrtimestre,
        codigo_categoria,
        codigo_rango_alumno,
        promedio_nota
        FROM LOS_LINDOS.BI_FACT_Nota_Promedio_Finales;
GO



/*
6. Tasa de ausentismo finales: Porcentaje de ausentes a finales (sobre la cantidad de inscriptos) por semestre por sede.
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Ausentismo_Finales (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)),
    cuatrimestre             INT NOT NULL CHECK (cuatrimestre IN (1,2)),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    cantidad_ausentes        INT NOT NULL DEFAULT 0,
    cantidad_inscriptos      INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, cuatrimestre, codigo_sede)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Ausentismo_Finales
SELECT
    YEAR(f.fecha),
    CASE WHEN MONTH(f.fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    c.codigo_sede,
    COUNT(CASE WHEN fa.presente=0 THEN 1 ELSE NULL END),
    COUNT(*)
FROM LOS_LINDOS.Examen_Final_de_Alumno fa
JOIN LOS_LINDOS.Examen_Final f ON f.codigo=fa.codigo_final
JOIN LOS_LINDOS.Curso c ON c.codigo=f.codigo_curso
GROUP BY YEAR(f.fecha), CASE WHEN MONTH(f.fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2 END, c.codigo_sede;

GO

CREATE VIEW LOS_LINDOS.VISTA_Ausentismo_Finales AS
SELECT
    anio,
    cuatrimestre,
    codigo_sede,
    CASE WHEN cantidad_inscriptos>0 THEN
        (CAST(cantidad_ausentes AS FLOAT)/cantidad_inscriptos)*100
    ELSE 0
    END cantidad_inscriptos
FROM LOS_LINDOS.BI_FACT_Ausentismo_Finales;

GO
                                                                               /*
7. Desv�o de pagos: Porcentaje de pagos realizados fuera de t�rmino por semestre.
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Pagos_Fuera_Termino (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)),
    cuatrimestre             INT NOT NULL CHECK (cuatrimestre IN (1,2)),
    cantidad_fuera_termino   INT NOT NULL DEFAULT 0,
    cantidad_total_pagos     INT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, cuatrimestre)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Pagos_Fuera_Termino
SELECT
    YEAR(p.fecha),
    CASE WHEN MONTH(p.fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    COUNT(CASE WHEN p.fecha>f.fecha_vencimiento THEN 1 ELSE NULL END),
    COUNT(*)
FROM LOS_LINDOS.Pago p
JOIN LOS_LINDOS.Factura f ON f.numero=p.numero_factura
GROUP BY YEAR(p.fecha), CASE WHEN MONTH(p.fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2 END;

GO

CREATE VIEW LOS_LINDOS.VISTA_Pagos_Fuera_Termino AS
SELECT
    anio,
    cuatrimestre,
    CASE WHEN cantidad_total_pagos >0
    THEN
        (CAST(cantidad_fuera_termino AS FLOAT)/cantidad_total_pagos)*100
    ELSE 0
    END AS porcentaje_fuera_de_termino
FROM LOS_LINDOS.BI_FACT_Pagos_Fuera_Termino;

GO
/*
8. Tasa de Morosidad Financiera mensual. Se calcula teniendo en cuenta el total 
de importes adeudados sobre facturaci�n esperada en el mes. El monto adeudado se obtiene a partir de las facturas que no tengan pago registrado en dicho mes. 
*/
CREATE TABLE LOS_LINDOS.BI_FACT_Morosidad_Mensual (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)),
    mes                      INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    monto_adeudado           DECIMAL(18,2) NOT NULL DEFAULT 0,
    facturacion_esperada     DECIMAL(18,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, mes)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Morosidad_Mensual (anio, mes, monto_adeudado, facturacion_esperada)
SELECT
    YEAR(f.fecha_emision) AS anio_emision,
    MONTH(f.fecha_emision) AS mes_emision,
    SUM(CASE WHEN p.numero_factura IS NULL THEN f.importe_total ELSE 0 END) AS monto_adeudado,
    SUM(f.importe_total) AS facturacion_esperada
FROM LOS_LINDOS.Factura f
    LEFT JOIN (SELECT DISTINCT numero_factura, YEAR(fecha)as anio, MONTH(fecha) as mes FROM LOS_LINDOS.PAGO) p
ON p.numero_factura=f.numero AND p.anio=YEAR(f.fecha_emision) AND p.mes=MONTH(f.fecha_emision)
WHERE YEAR(f.fecha_emision) BETWEEN 2019 AND 2025
GROUP BY YEAR(f.fecha_emision), MONTH (f.fecha_emision)
ORDER BY anio_emision, mes_emision;

GO

CREATE VIEW LOS_LINDOS.VISTA_Morosidad_Mensual AS
    SELECT
        anio,
        mes,
        monto_adeudado,
        facturacion_esperada
    FROM LOS_LINDOS.BI_FACT_Morosidad_Mensual;
GO


/*
9. Ingresos por categoria de cursos: Las 3 categor�as de cursos que generan mayores ingresos por sede, por anio.
*/
CREATE TABLE LOS_LINDOS.  (
    anio                     INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)),
    codigo_sede              BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    codigo_categoria         BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    ingresos                 DECIMAL(18,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, codigo_sede, codigo_categoria)
);
GO

INSERT INTO LOS_LINDOS.BI_FACT_Ingresos_Por_Categoria
SELECT
    YEAR(c.fecha_inicio),
    c.codigo_sede,
    c.codigo_categoria,
    SUM(df.importe)
FROM LOS_LINDOS.Curso c
JOIN LOS_LINDOS.Detalle_Factura df ON c.codigo=df.codigo_curso
GROUP BY YEAR(c.fecha_inicio), c.codigo_sede, c.codigo_categoria;

GO

CREATE VIEW LOS_LINDOS.VISTA_Ingresos_Por_Categoria AS
SELECT
    i.anio,
    i.codigo_sede,
    i.codigo_categoria,
    i.ingresos
FROM LOS_LINDOS.BI_FACT_Ingresos_Por_Categoria i
WHERE (
      SELECT
          COUNT(*)
      FROM LOS_LINDOS.BI_FACT_Ingresos_Por_Categoria i2
      WHERE i2.anio=i.anio AND i2.codigo_sede=i.codigo_sede AND i2.ingresos>i.ingresos
      ) < 3
ORDER BY i.anio, i.codigo_sede, i.codigo_categoria;

GO


/*
10. Indice de satisfaccion. indice de satisfaccion anual, segun rango etario de los
profesores y sede. El indice de satisfaccion es igual a ((% satisfechos %insatisfechos) +100)/2.
Teniendo en cuenta que 
Satisfechos: Notas entre 7 y 10 
Neutrales: Notas entre 5 y 6 
Insatisfechos: Notas entre 1 y 4 
*/

CREATE TABLE LOS_LINDOS.BI_FACT_Indice_Satisfaccion (
    anio                                    INT NOT NULL CHECK (anio in (2019,2020,2021,2022,2023,2024,2025)),
    codigo_sede                             BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Sede(codigo_sede),
    codigo_rango_profesor                   BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor(codigo_rango),
    codigo_bloque                           BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion(codigo_bloque),
    porcentaje                              FLOAT NOT NULL DEFAULT 0,
    PRIMARY KEY (anio, codigo_sede, codigo_rango_profesor, codigo_bloque)
);
GO

-- solucion 1
INSERT INTO LOS_LINDOS.BI_FACT_Indice_Satisfaccion (anio,codigo_sede,codigo_rango_profesor,codigo_bloque,porcentaje)
SELECT
    YEAR(e.fecha_registro),
    c.codigo_sede,
    re.codigo_rango,
    bs.codigo_bloque,
    COUNT(*) / (SELECT COUNT(*) FROM LOS_LINDOS.Encuesta ee
                            JOIN LOS_LINDOS.Respuesta rr ON rr.codigo_encuesta = ee.codigo
                            JOIN LOS_LINDOS.Curso cc ON cc.codigo = ee.codigo_curso
                            JOIN LOS_LINDOS.Profesor pp ON pp.codigo = cc.codigo_profesor
                            JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno rere ON
                                        (DATEDIFF (YEAR,pp.fecha_nacimiento,ee.fecha_registro)<25 AND rere.descripcion= '<25')
                                        OR
                                        (DATEDIFF (YEAR,pp.fecha_nacimiento,ee.fecha_registro) BETWEEN 25 AND 35 AND rere.descripcion= '25-35')
                                        OR
                                        (DATEDIFF (YEAR,pp.fecha_nacimiento,ee.fecha_registro) BETWEEN 35 AND 50 AND rere.descripcion= '35-50')
                                        OR
                                        (DATEDIFF (YEAR,pp.fecha_nacimiento,ee.fecha_registro)>50 AND rere.descripcion= '>50') 
                  WHERE cc.codigo_sede = c.codigo_sede AND rere.codigo_rango = re.codigo_rango 
                  )
FROM LOS_LINDOS.Encuesta e
    JOIN LOS_LINDOS.Respuesta r ON r.codigo_encuesta = e.codigo
    JOIN LOS_LINDOS.Curso c ON c.codigo = e.codigo_curso
    JOIN LOS_LINDOS.Profesor p ON p.codigo = c.codigo_profesor
    JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno re ON
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro)<25 AND re.descripcion= '<25')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro) BETWEEN 25 AND 35 AND re.descripcion= '25-35')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro) BETWEEN 35 AND 50 AND re.descripcion= '35-50')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro)>50 AND re.descripcion= '>50')
    JOIN LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion bs ON r.respuesta >= bs.nota_minima AND r.respuesta<= bs.nota_maxima
GROUP BY c.codigo_sede,YEAR(e.fecha_registro),re.codigo_rango, bs.codigo_bloque

--solucion 2

INSERT INTO LOS_LINDOS.BI_FACT_Indice_Satisfaccion (anio,codigo_sede,codigo_rango_profesor,codigo_bloque,porcentaje)
SELECT
    YEAR(e.fecha_registro),
    c.codigo_sede,
    re.codigo_rango,
    (SELECT bs.codigo_bloque FROM LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion bs WHERE bs.descripcion = 'Satisfechos'),
    (COUNT( CASE WHEN r.respuesta >= 7 THEN 1 END))/COUNT(*)
FROM LOS_LINDOS.Encuesta e
    JOIN LOS_LINDOS.Respuesta r ON r.codigo_encuesta = e.codigo
    JOIN LOS_LINDOS.Curso c ON c.codigo = e.codigo_curso
    JOIN LOS_LINDOS.Profesor p ON p.codigo = c.codigo_profesor
    JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno re ON
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro)<25 AND re.descripcion= '<25')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro) BETWEEN 25 AND 35 AND re.descripcion= '25-35')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro) BETWEEN 35 AND 50 AND re.descripcion= '35-50')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro)>50 AND re.descripcion= '>50')
GROUP BY c.codigo_sede,YEAR(e.fecha_registro),re.codigo_rango
UNION
SELECT
    YEAR(e.fecha_registro),
    c.codigo_sede,
    re.codigo_rango,
    (SELECT bs.codigo_bloque FROM LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion bs WHERE bs.descripcion = 'Neutrales'),
    (COUNT( CASE WHEN r.respuesta >= 5 and r.respuesta <= 6 THEN 1 END))/COUNT(*)
FROM LOS_LINDOS.Encuesta e
    JOIN LOS_LINDOS.Respuesta r ON r.codigo_encuesta = e.codigo
    JOIN LOS_LINDOS.Curso c ON c.codigo = e.codigo_curso
    JOIN LOS_LINDOS.Profesor p ON p.codigo = c.codigo_profesor
    JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno re ON
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro)<25 AND re.descripcion= '<25')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro) BETWEEN 25 AND 35 AND re.descripcion= '25-35')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro) BETWEEN 35 AND 50 AND re.descripcion= '35-50')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro)>50 AND re.descripcion= '>50')
UNION
SELECT
    YEAR(e.fecha_registro),
    c.codigo_sede,
    re.codigo_rango,
    (SELECT bs.codigo_bloque FROM LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion bs WHERE bs.descripcion = 'Insatisfechos'),
    (COUNT( CASE WHEN r.respuesta <= 4 THEN 1 END))/COUNT(*)
FROM LOS_LINDOS.Encuesta e
    JOIN LOS_LINDOS.Respuesta r ON r.codigo_encuesta = e.codigo
    JOIN LOS_LINDOS.Curso c ON c.codigo = e.codigo_curso
    JOIN LOS_LINDOS.Profesor p ON p.codigo = c.codigo_profesor
    JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno re ON
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro)<25 AND re.descripcion= '<25')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro) BETWEEN 25 AND 35 AND re.descripcion= '25-35')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro) BETWEEN 35 AND 50 AND re.descripcion= '35-50')
    OR
    (DATEDIFF (YEAR,p.fecha_nacimiento,e.fecha_registro)>50 AND re.descripcion= '>50')

--El orden es así
-- Creacion de dimension
-- Migracion de dimension
-- Creacion de tabla de hechos
-- Migracion de tabla de hechos
-- Creacion de vista para esa tabla de hechos




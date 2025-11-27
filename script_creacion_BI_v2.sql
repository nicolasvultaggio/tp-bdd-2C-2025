USE GD2C2025;
GO

/*

Dimensiones:

AÑO
SEMESTRE
MES
SEDE
RANGO ETARIO DE ALUMNO
RANGO ETARIO DE PROFESOR
TURNO
CATEGORÍA DE CURSOS
MEDIO DE PAGO
BLOQUE DE SATISFACCIÓN

*/

-- TIEMPO


CREATE TABLE LOS_LINDOS.BI_DIMENSION_TIEMPO
(
    ID               BIGINT IDENTITY(1,1) PRIMARY KEY,
    ANIO             INT NOT NULL,
    SEMESTRE         INT NOT NULL CHECK (SEMESTRE IN (1,2)),   -- 1 o 2
    MES              INT NOT NULL CHECK ( 1<=MES AND MES<=13),   -- 1 al 12
    NOMBRE_MES       VARCHAR(50),
    NOMBRE_SEMESTRE  VARCHAR(50),
    COMPLETO         VARCHAR(50),
    CONSTRAINT CK_TIEMPO_Semestre_Correcto 
        CHECK ( (SEMESTRE = 1 AND MES <= 6) OR (SEMESTRE = 2 AND MES >= 7) )
);
GO


INSERT INTO LOS_LINDOS.BI_DIMENSION_TIEMPO (Anio, Semestre, Mes, Nombre_Mes, Nombre_Semestre, Completo)
SELECT 
    a.Anio,
    CASE WHEN m.Mes <= 6 THEN 1 ELSE 2 END,
    m.Mes,
    CASE m.Mes
        WHEN 1  THEN 'Enero'
        WHEN 2  THEN 'Febrero'
        WHEN 3  THEN 'Marzo'
        WHEN 4  THEN 'Abril'
        WHEN 5  THEN 'Mayo'
        WHEN 6  THEN 'Junio'
        WHEN 7  THEN 'Julio'
        WHEN 8  THEN 'Agosto'
        WHEN 9  THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END,
    CASE WHEN m.Mes <= 6 THEN '1er Semestre' ELSE '2do Semestre' END,
    CASE m.Mes
        WHEN 1  THEN 'Enero '     + CAST(a.Anio AS VARCHAR(4))
        WHEN 2  THEN 'Febrero '   + CAST(a.Anio AS VARCHAR(4))
        WHEN 3  THEN 'Marzo '     + CAST(a.Anio AS VARCHAR(4))
        WHEN 4  THEN 'Abril '     + CAST(a.Anio AS VARCHAR(4))
        WHEN 5  THEN 'Mayo '      + CAST(a.Anio AS VARCHAR(4))
        WHEN 6  THEN 'Junio '     + CAST(a.Anio AS VARCHAR(4))
        WHEN 7  THEN 'Julio '     + CAST(a.Anio AS VARCHAR(4))
        WHEN 8  THEN 'Agosto '    + CAST(a.Anio AS VARCHAR(4))
        WHEN 9  THEN 'Septiembre '+ CAST(a.Anio AS VARCHAR(4))
        WHEN 10 THEN 'Octubre '   + CAST(a.Anio AS VARCHAR(4))
        WHEN 11 THEN 'Noviembre ' + CAST(a.Anio AS VARCHAR(4))
        WHEN 12 THEN 'Diciembre ' + CAST(a.Anio AS VARCHAR(4))
    END 
FROM 
    (VALUES (2019),(2020),(2021),(2022),(2023),(2024),(2025)) AS a(Anio)
    CROSS JOIN 
    (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(Mes);
GO

-- Sede

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Sede ( --> Creacion de la tabla de dimensión
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

INSERT INTO LOS_LINDOS.BI_DIMENSION_Sede --> Migro el contenido desde el esquema transaccional, obtengo todas las sedes
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


-- Rango etario de alumno

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno ( --> Creacion de la tabla de dimensión
    codigo_rango        BIGINT IDENTITY(1,1),
    descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('<25', '25-35', '35-50', '>50')),
    edad_minima         INT NULL, --> EDAD MINIMA ADMITIDA
    edad_maxima         INT NULL --> EDAD MAXIMA ADMITIDA
    PRIMARY KEY (codigo_rango)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno (descripcion, edad_minima,edad_maxima)
VALUES ('<25',0,24), ('25-35',25,34), ('35-50',35,50), ('>50',51,150); --> Inserto posibles valores


-- Rango etario de profesor

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor (
    codigo_rango        BIGINT IDENTITY(1,1),
    descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('25-35', '35-50', '>50')), --> Creacion de tabla de dimension
    edad_minima         INT NULL, --> EDAD MINIMA ADMITIDA
    edad_maxima         INT NULL --> EDAD MAXIMA ADMITIDA
    PRIMARY KEY (codigo_rango)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor (descripcion,edad_minima,edad_maxima)
VALUES ('25-35',25,34), ('35-50',35,50), ('>50',51,150); --> Inserto posibles valores


-- Turno

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Turno (
    codigo_turno        BIGINT,
    nombre              VARCHAR(255) NOT NULL, --> Creo dimensión turno
    PRIMARY KEY (codigo_turno)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Turno --> Inserto los posibles valores desde el esquema transaccional
    SELECT * FROM LOS_LINDOS.Turno;


-- Categoría de curso


CREATE TABLE LOS_LINDOS.BI_DIMENSION_Categoria_Curso ( --> Creo dimensión Categoria de curso
    codigo_categoria    BIGINT,
    nombre              VARCHAR(255) NOT NULL,
    PRIMARY KEY (codigo_categoria)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Categoria_Curso --> Inserto los posibles valores desde el esquema transaccional
SELECT DISTINCT
    c.codigo_categoria,
    ca.nombre
FROM LOS_LINDOS.Curso c
            JOIN LOS_LINDOS.Categoria ca ON c.codigo_categoria=ca.codigo


-- Medio de pago


CREATE TABLE LOS_LINDOS.BI_DIMENSION_Medio_Pago ( --> Genero tabla de dimensión para los medios de pago
    codigo_medio_pago   BIGINT,
    descripcion         NVARCHAR(50) NOT NULL,
    PRIMARY KEY (codigo_medio_pago)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Medio_Pago --> Inserto los medios de pago desde el esquema transaccional
    SELECT * FROM LOS_LINDOS.Medio_Pago


-- Bloque de satisfacción

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion (
        codigo_bloque       BIGINT IDENTITY(1,1),
        descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('Satisfechos', 'Neutrales', 'Insatisfechos')),
        nota_minima         BIGINT, --> nota minima admitida
        nota_maxima         BIGINT --> nota maxima admitida
        PRIMARY KEY (codigo_bloque) ---> Genero tabla de dimensión para los bloques de satisfacción
);
GO


INSERT INTO LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion (descripcion,nota_minima,nota_maxima) VALUES
('Satisfechos', 7, 10),
('Neutrales', 5, 6),
('Insatisfechos', 0, 4); --> Inserto justamente los bloques de satisfacción


-- Tablas de hechos

CREATE TABLE LOS_LINDOS.BI_FACT_INSCRIPCIONES(
tiempo                      BIGINT,
sede                        BIGINT,
rango_etario_alumno         BIGINT,
rango_etario_profesor       BIGINT,
turno                       BIGINT,
categoria_curso             BIGINT,
cantidad_inscripciones      INT,
inscripciones_rechazadas    INT,
inscripciones_aceptadas     INT
PRIMARY KEY(tiempo,sede, rango_etario_alumno, rango_etario_profesor,turno,categoria_curso)
);

INSERT INTO LOS_LINDOS.BI_FACT_INSCRIPCIONES (tiempo,sede, rango_etario_alumno,rango_etario_profesor,turno,categoria_curso,cantidad_inscripciones,inscripciones_rechazadas,inscripciones_aceptadas)
SELECT 
    t.ID,
    c.codigo_sede,
    rea.codigo_rango,
    rep.codigo_rango,
    c.codigo_turno,
    c.codigo_categoria,
    COUNT(*),
    COUNT(case e.nombre_tipo_estado when 'Rechazada' then 1 end),
    COUNT(case e.nombre_tipo_estado when 'Confirmada' then 1 end)
    FROM LOS_LINDOS.Inscripcion_Curso ic 
        JOIN LOS_LINDOS.Curso c ON c.codigo = ic.curso_codigo
        JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t on YEAR(c.fecha_inicio) = t.ANIO AND MONTH(c.fecha_inicio) = t.MES
        JOIN LOS_LINDOS.Alumno a on a.legajo = ic.legajo_alumno
        JOIN LOS_LINDOS.Profesor p on c.codigo_profesor = p.codigo
        JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno rea on  DATEDIFF(YEAR, a.fecha_nacimiento, c.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima
        JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor rep on DATEDIFF(YEAR, p.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
        JOIN LOS_LINDOS.Estado_de_Inscripción ei on ei.numero_inscripcion_curso = ic.numero
        JOIN LOS_LINDOS.Estado e on e.codigo_estado = ei.codigo_estado
        GROUP BY t.ID,c.codigo_sede,rea.codigo_rango,rep.codigo_rango,c.codigo_turno,c.codigo_categoria;

-- SELECT * FROM LOS_LINDOS.BI_FACT_INSCRIPCIONES WHERE inscripciones_rechazadas + inscripciones_aceptadas = cantidad_inscripciones para chequeo

/*
1. Categorías y turnos más solicitados. Las 3 categorías de cursos y turnos con 
mayor cantidad de inscriptos por año por sede. 
*/
GO

CREATE OR ALTER VIEW LOS_LINDOS.VISTA_TOP3_CATEGORIA_CURSO
AS
WITH RankedDuplas AS (
    SELECT 
        t.ANIO,
        s.nombre        AS Nombre_Sede,
        s.provincia     AS Provincia_Sede,
        s.localidad     AS Localidad_Sede,
        cat.nombre      AS Categoria_Curso,
        tur.nombre      AS Turno,
        SUM(f.cantidad_inscripciones) AS Total_Inscriptos,
        
        -- Ranking dentro de cada Año + Sede
        ROW_NUMBER() OVER (
            PARTITION BY t.ANIO, f.sede 
            ORDER BY SUM(f.cantidad_inscripciones) DESC
        ) AS Ranking

    FROM LOS_LINDOS.BI_FACT_INSCRIPCIONES f
        JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t          ON f.tiempo = t.ID
        JOIN LOS_LINDOS.BI_DIMENSION_Sede s           ON f.sede = s.codigo_sede
        JOIN LOS_LINDOS.BI_DIMENSION_Categoria_Curso cat ON f.categoria_curso = cat.codigo_categoria
        JOIN LOS_LINDOS.BI_DIMENSION_Turno tur        ON f.turno = tur.codigo_turno

    GROUP BY 
        t.ANIO, 
        f.sede, 
        s.nombre, 
        s.provincia,
        s.localidad,
        cat.nombre, 
        tur.nombre
)
SELECT 
    ANIO 'Año',
    Nombre_Sede 'Sede',
    Provincia_Sede 'Provincia',
    Localidad_Sede 'Localidad',
    Categoria_Curso 'Categoría de curso',
    Turno 'Turno',
    Total_Inscriptos 'Cantidad de inscriptos',
    Ranking 'Ranking'
FROM RankedDuplas
WHERE Ranking <= 3


GO

/*
2. Tasa de rechazo de inscripciones: Porcentaje de inscripciones rechazadas por 
mes por sede (sobre el total de inscripciones). 
*/

CREATE OR ALTER VIEW LOS_LINDOS.VISTA_TASA_RECHAZO
AS
SELECT 
    t.COMPLETO        AS 'Período completo', 
    s.nombre          AS 'Sede',
    s.provincia       AS 'Provincia',
    s.localidad       AS 'Localidad',
    SUM(f.cantidad_inscripciones)          AS 'Total de inscripciones',
    SUM(f.inscripciones_rechazadas)        AS 'Inscripciones rechazadas',
    SUM(f.inscripciones_aceptadas)         AS 'Inscripciones confirmadas',
    CONCAT(
        FORMAT(
            (100.00 * SUM(f.inscripciones_rechazadas)) / NULLIF(SUM(f.cantidad_inscripciones), 0),
            'N2'
        ),
        '%'
    ) AS 'Porcentaje de rechazo',
    CONCAT(
        FORMAT(
            (100.00 * SUM(f.inscripciones_aceptadas)) / NULLIF(SUM(f.cantidad_inscripciones), 0),
            'N2'
        ),
        '%'
    ) AS 'Porcentaje de confirmación'
FROM LOS_LINDOS.BI_FACT_INSCRIPCIONES f
    JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON f.tiempo = t.ID
    JOIN LOS_LINDOS.BI_DIMENSION_Sede s  ON f.sede = s.codigo_sede
GROUP BY 
    t.ANIO,
    t.MES,
    t.NOMBRE_MES,
    t.COMPLETO,
    s.nombre,
    s.provincia,
    s.localidad
GO



CREATE TABLE LOS_LINDOS.BI_FACT_CURSADAS(
tiempo                      BIGINT,
sede                        BIGINT,
rango_etario_alumno         BIGINT,
rango_etario_profesor       BIGINT,
turno                       BIGINT,
categoria_curso             BIGINT,
cantidad_aprobados          INT,
cantidad_desaprobados       INT,
cantidad_cursadas           INT,
promedio_finalizacion_dias  FLOAT
PRIMARY KEY(tiempo,sede, rango_etario_alumno, rango_etario_profesor,turno,categoria_curso)
);

GO

INSERT INTO LOS_LINDOS.BI_FACT_CURSADAS
SELECT 
    t.ID,
    c.codigo_sede,
    rea.codigo_rango,
    rep.codigo_rango,
    c.codigo_turno,
    c.codigo_categoria,
    (
    SELECT COUNT(*) FROM LOS_LINDOS.Curso_x_Alumno ca 
            JOIN LOS_LINDOS.Curso cc ON cc.codigo = ca.codigo_curso 
            JOIN LOS_LINDOS.Alumno aa ON aa.legajo = ca.legajo_alumno
            JOIN LOS_LINDOS.Profesor pp ON pp.codigo = cc.codigo_profesor
            WHERE YEAR(cc.fecha_inicio) = t.ANIO AND MONTH(cc.fecha_inicio) = t.MES 
              AND cc.codigo_sede=c.codigo_sede
              AND DATEDIFF(YEAR, aa.fecha_nacimiento, cc.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima --> SUBQUERY OBTIENE LA CANTIDAD DE CURSADAS APROBADAS EN ESE MES, AÑO, RANGO DE PROFESOR, RANGO DE ALUMNO, TURNO Y CATEGORIA DE CURSO
              AND DATEDIFF(YEAR, p.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
              AND cc.codigo_categoria = c.codigo_categoria
              AND cc.codigo_turno = c.codigo_turno
              AND (SELECT tp.nota FROM LOS_LINDOS.Trabajo_Practico tp WHERE tp.codigo_curso = ca.codigo_curso and tp.legajo_alumno =ca.legajo_alumno) >= 4
              AND (SELECT COUNT(*) FROM LOS_LINDOS.Parcial par WHERE par.codigo_curso = cc.codigo) = (SELECT COUNT(*) FROM LOS_LINDOS.Parcial_de_alumno paralu JOIN LOS_LINDOS.Parcial par on par.codigo=paralu.codigo_parcial WHERE par.codigo_curso = ca.codigo_curso AND ca.legajo_alumno = paralu.legajo_alumno AND paralu.nota >=4 )
     --                    CANTIDAD DE PARCIALES DE ESE CURSO                                      =                          CANTIDAD DE PARCIALES DE APROBADOS DE ESE ALUMNO PARA ESE CURSO
     ) AS cantidad_aprobados,
    (
    SELECT COUNT(*) FROM LOS_LINDOS.Curso_x_Alumno ca 
            JOIN LOS_LINDOS.Curso cc ON cc.codigo = ca.codigo_curso 
            JOIN LOS_LINDOS.Alumno aa ON aa.legajo = ca.legajo_alumno
            JOIN LOS_LINDOS.Profesor pp ON pp.codigo = cc.codigo_profesor
            WHERE YEAR(cc.fecha_inicio) = t.ANIO AND MONTH(cc.fecha_inicio) = t.MES 
              AND cc.codigo_sede=c.codigo_sede
              AND DATEDIFF(YEAR, aa.fecha_nacimiento, cc.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima  --> SUBQUERY OBTIENE LA CANTIDAD DE CURSADAS DESAPROBADAS EN ESE MES, AÑO, RANGO DE PROFESOR, RANGO DE ALUMNO, TURNO Y CATEGORIA DE CURSO, SE PODRÍA HABER OBTENIDO RESTANDO DEL TOTAL LA CANTIDAD APROBADA, PERO DE ESTA MANERA VEMOS QUE EL PROCEDIMIENTO ES CORRECTO AL %100, YA QUE DE TODAS FORMAS APROBADOS + DESAPROBADOS = TOTAL
              AND DATEDIFF(YEAR, p.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
              AND cc.codigo_categoria = c.codigo_categoria
              AND cc.codigo_turno = c.codigo_turno
              AND (
                        (SELECT tp.nota FROM LOS_LINDOS.Trabajo_Practico tp WHERE tp.codigo_curso = ca.codigo_curso and tp.legajo_alumno =ca.legajo_alumno) < 4
                            OR 
                        (SELECT COUNT(*) FROM LOS_LINDOS.Parcial par WHERE par.codigo_curso = cc.codigo) > (SELECT COUNT(*) FROM LOS_LINDOS.Parcial_de_alumno paralu JOIN LOS_LINDOS.Parcial par on par.codigo=paralu.codigo_parcial WHERE par.codigo_curso = ca.codigo_curso AND ca.legajo_alumno = paralu.legajo_alumno AND paralu.nota >=4 )
                  )
      --                    CANTIDAD DE PARCIALES DE ESE CURSO                                           >                     CANTIDAD DE PARCIALES APROBADOS DE ESE ALUMNO PARA ESE CURSO
     ) AS cantidad_desaprobados,
    (
    SELECT COUNT(*) FROM LOS_LINDOS.Curso_x_Alumno ca 
            JOIN LOS_LINDOS.Curso cc ON cc.codigo = ca.codigo_curso 
            JOIN LOS_LINDOS.Alumno aa ON aa.legajo = ca.legajo_alumno
            JOIN LOS_LINDOS.Profesor pp ON pp.codigo = cc.codigo_profesor
            WHERE YEAR(cc.fecha_inicio) = t.ANIO AND MONTH(cc.fecha_inicio) = t.MES 
              AND cc.codigo_sede=c.codigo_sede
              AND DATEDIFF(YEAR, aa.fecha_nacimiento, cc.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima   --> SUBQUERY OBTIENE LA CANTIDAD DE CURSADAS EN ESE MES, AÑO, RANGO DE PROFESOR, RANGO DE ALUMNO, TURNO Y CATEGORIA DE CURSO
              AND DATEDIFF(YEAR, p.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
              AND cc.codigo_categoria = c.codigo_categoria
              AND cc.codigo_turno = c.codigo_turno
     ) AS cantidad_cursadas,
     AVG(DATEDIFF (DAY,c.fecha_inicio,ef.fecha)) AS tiempo_promedio_de_finalizacion_en_dias   --> OBTIENE EL PROMEDIO DE FINALIZACION DE CURSADAS EN ESE MES, AÑO, RANGO DE PROFESOR, RANGO DE ALUMNO, TURNO Y CATEGORÍA DE PROFESOR
    FROM LOS_LINDOS.Curso c
         JOIN LOS_LINDOS.Curso_x_Alumno ca on ca.codigo_curso =c.codigo
         JOIN LOS_LINDOS.Alumno a on a.legajo = ca.legajo_alumno
         JOIN LOS_LINDOS.Profesor p on p.codigo = c.codigo_profesor
         JOIN LOS_LINDOS.Examen_Final ef on ef.codigo_curso = c.codigo
         JOIN LOS_LINDOS.Examen_Final_de_Alumno efa on efa.codigo_final = ef.codigo AND efa.legajo_alumno = a.legajo
         JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t on YEAR(c.fecha_inicio) = t.ANIO AND MONTH(c.fecha_inicio) = t.MES
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno rea on  DATEDIFF(YEAR, a.fecha_nacimiento, c.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor rep on DATEDIFF(YEAR, p.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
         GROUP BY t.id,t.anio,t.mes,c.codigo_sede,rea.codigo_rango,rea.edad_minima,rea.edad_maxima,rep.codigo_rango,rep.edad_minima,rep.edad_maxima,c.codigo_turno,c.fecha_inicio,c.codigo_categoria,p.fecha_nacimiento --> la mitad de estos group by estan nada más par que no rompa el codigo, en realidad no agrupan nada, es simplemente para trabajar con la informacion que proporcionan en las subqueries

GO


/*
SELECT DATEDIFF(DAY,c.fecha_inicio,ef.fecha) FROM LOS_LINDOS.Curso_x_Alumno ca 
         JOIN LOS_LINDOS.Curso c on c.codigo=ca.codigo_curso
         JOIN LOS_LINDOS.Examen_Final ef on ef.codigo_curso = c.codigo
         JOIN LOS_LINDOS.Examen_Final_de_Alumno efa on efa.codigo_final = ef.codigo AND efa.legajo_alumno = ca.legajo_alumno and efa.nota>=4   -->proba esta consulta para ver el tiempo de finalizacion de cada cursada

SELECT c.codigo,ca.legajo_alumno, c.fecha_inicio, ef.fecha FROM LOS_LINDOS.Curso_x_Alumno ca 
         JOIN LOS_LINDOS.Curso c on c.codigo=ca.codigo_curso
         JOIN LOS_LINDOS.Examen_Final ef on ef.codigo_curso = c.codigo
         JOIN LOS_LINDOS.Examen_Final_de_Alumno efa on efa.codigo_final = ef.codigo AND efa.legajo_alumno = ca.legajo_alumno and efa.nota>=4   -->proba esta consulta para ver el tiempo de finalizacion de cada cursada

 Hay cursadas que duran 200 días, otras que duran poco más de dos meses, es muy variante
*/


/*
3. Comparación de desempeño de cursada por sede:. Porcentaje de aprobación de cursada por sede, por año. Se considera aprobada la cursada de un alumno cuando tiene nota mayor o igual a 4 en todos los módulos y el TP. 
*/ 

CREATE OR ALTER VIEW LOS_LINDOS.VISTA_PORCENTAJE_APROBACION_Y_DESAPROBACION
AS
SELECT 
    t.ANIO                                          AS 'Año',
    s.nombre                                        AS 'Sede',
    s.provincia                                     AS 'Provincia',
    s.localidad                                     AS 'Localidad',
    SUM(f.cantidad_cursadas)                        AS 'Total de cursadas',
    SUM(f.cantidad_aprobados)                       AS 'Cursadas aprobadas',
    SUM(f.cantidad_desaprobados)                    AS 'Cursadas desaprobadas',

    -- Porcentaje de aprobación con 2 decimales
    CONCAT(
        FORMAT(
            100.0 * SUM(f.cantidad_aprobados) / NULLIF(SUM(f.cantidad_cursadas), 0),
            'N2'
        ),
        '%'
    ) AS 'Porcentaje aprobación',

    -- Complemento para que siempre sume 100%
    CONCAT(
        FORMAT(
            100.0 * SUM(f.cantidad_desaprobados) / NULLIF(SUM(f.cantidad_cursadas), 0),
            'N2'
        ),
        '%'
    ) AS 'Porcentaje Desaprobación'

FROM LOS_LINDOS.BI_FACT_CURSADAS f
    JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t     ON f.tiempo = t.ID
    JOIN LOS_LINDOS.BI_DIMENSION_Sede s       ON f.sede = s.codigo_sede
GROUP BY 
    t.ANIO,
    s.codigo_sede,
    s.nombre,
    s.provincia,
    s.localidad
GO


/*
4. Tiempo promedio de finalización de curso: Tiempo promedio entre el inicio del curso y la aprobación del final según la categoría de los cursos, por año. (Tener en cuenta el año de inicio del curso) 
*/

/*

DROP VIEW IF EXISTS LOS_LINDOS.VISTA_TOP3_CATEGORIA_CURSO;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_TASA_RECHAZO;
DROP TABLE IF EXISTS LOS_LINDOS.BI_FACT_INSCRIPCIONES;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_TIEMPO;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_Sede;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_Turno;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_Categoria_Curso;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_Medio_Pago;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion;

*/











-- VISTAS


SELECT * FROM LOS_LINDOS.VISTA_TOP3_CATEGORIA_CURSO
SELECT * FROM LOS_LINDOS.VISTA_TASA_RECHAZO
SELECT * FROM LOS_LINDOS.VISTA_PORCENTAJE_APROBACION_Y_DESAPROBACION
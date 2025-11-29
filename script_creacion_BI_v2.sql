USE GD2C2025;
GO

/*

Dimensiones:

Anio
SEMESTRE
MES
SEDE
RANGO ETARIO DE ALUMNO
RANGO ETARIO DE PROFESOR
TURNO
CATEGORIA DE CURSOS
MEDIO DE PAGO
BLOQUE DE SATISFACCION

*/

-- TIEMPO


CREATE TABLE LOS_LINDOS.BI_DIMENSION_TIEMPO
(
    ID               BIGINT IDENTITY(1,1) PRIMARY KEY,
    ANIO             INT NOT NULL,
    SEMESTRE         INT NOT NULL CHECK (SEMESTRE IN (1,2)),   -- 1 o 2
    MES              INT NOT NULL CHECK ( 1<=MES AND MES<=12),   -- 1 al 12
    NOMBRE_SEMESTRE  VARCHAR(50),
    PERIODO          VARCHAR(50),
    CONSTRAINT CK_TIEMPO_Semestre_Correcto 
        CHECK ( (SEMESTRE = 1 AND MES <= 6) OR (SEMESTRE = 2 AND MES >= 7) ) --> Creo dimension tiempo
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_TIEMPO (Anio, Semestre, Mes, Nombre_Semestre, PERIODO)
SELECT 
    a.Anio,
    CASE WHEN m.Mes <= 6 THEN 1 ELSE 2 END,
    m.Mes,
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
    (VALUES (2019),(2020),(2021),(2022),(2023),(2024),(2025)) AS a(Anio) --> Inserto valores en dimension de tiempo
    CROSS JOIN 
    (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(Mes);
GO

-- Sede

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Sede ( --> Creacion de la tabla de dimension
    codigo_sede         BIGINT,
    nombre              NVARCHAR(255),
    localidad           NVARCHAR(255),
    provincia           NVARCHAR(255),
    direccion           NVARCHAR(255),
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
    d.nombre,
    s.mail,
    s.cuit_institucion,
    i.nombre,
    i.razon
FROM LOS_LINDOS.Sede s
            JOIN LOS_LINDOS.Localidad l ON l.codigo=s.codigo_localidad
            JOIN LOS_LINDOS.Provincia p ON p.codigo=s.codigo_provincia
            JOIN LOS_LINDOS.Direccion d ON d.codigo=s.codigo_direccion
            JOIN LOS_LINDOS.Institucion i ON i.cuit=s.cuit_institucion


-- Rango etario de alumno

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno ( --> Creacion de la tabla de dimension
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

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor (--> Creacion de tabla de dimension
    codigo_rango        BIGINT IDENTITY(1,1),
    descripcion         VARCHAR(20) NOT NULL CHECK (descripcion IN ('25-35', '35-50', '>50')), 
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
    nombre              VARCHAR(255) NOT NULL, --> Creo dimension turno
    PRIMARY KEY (codigo_turno)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Turno --> Inserto los posibles valores desde el esquema transaccional 
SELECT  
    codigo,
    nombre
FROM LOS_LINDOS.Turno ;


-- Categoría de curso


CREATE TABLE LOS_LINDOS.BI_DIMENSION_Categoria_Curso ( --> Creo dimension Categoria de curso
    codigo_categoria    BIGINT,
    nombre              VARCHAR(255) NOT NULL,
    PRIMARY KEY (codigo_categoria)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Categoria_Curso --> Inserto los posibles valores desde el esquema transaccional
SELECT
    codigo,
    nombre
FROM LOS_LINDOS.Categoria


-- Medio de pago


CREATE TABLE LOS_LINDOS.BI_DIMENSION_Medio_Pago ( --> Genero tabla de dimension para los medios de pago
    codigo_medio_pago   BIGINT,
    descripcion         NVARCHAR(50) NOT NULL,
    PRIMARY KEY (codigo_medio_pago)
);
GO

INSERT INTO LOS_LINDOS.BI_DIMENSION_Medio_Pago --> Inserto los medios de pago desde el esquema transaccional
SELECT 
    codigo,
    medio_pago
FROM LOS_LINDOS.Medio_Pago


-- Bloque de satisfaccion

CREATE TABLE LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion ( 
        codigo_bloque       BIGINT IDENTITY(1,1),
        descripcion         VARCHAR(20),
        nota_minima         BIGINT, --> nota minima admitida
        nota_maxima         BIGINT --> nota maxima admitida
        PRIMARY KEY (codigo_bloque) ---> Genero tabla de dimension para los bloques de satisfaccion
);
GO


INSERT INTO LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion (descripcion,nota_minima,nota_maxima) VALUES
('Satisfechos', 7, 10),
('Neutrales', 5, 6),
('Insatisfechos', 0, 4); --> Inserto justamente los bloques de satisfaccion


-- Tablas de hechos

CREATE TABLE LOS_LINDOS.BI_FACT_INSCRIPCIONES(
    tiempo                      BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_TIEMPO(ID),
    sede                        BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_SEDE(codigo_sede),
    rango_etario_alumno         BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno(codigo_rango),
    rango_etario_profesor       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor(codigo_rango),
    turno                       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Turno(codigo_turno),
    categoria_curso             BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
    cantidad_inscripciones      INT,
    inscripciones_rechazadas    INT,
    inscripciones_aceptadas     INT,
    PRIMARY KEY(tiempo, sede, rango_etario_alumno, rango_etario_profesor, turno, categoria_curso)
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
    SUM(case e.nombre_tipo_estado when 'Rechazada' then 1 else 0 end),
    SUM(case e.nombre_tipo_estado when 'Confirmada' then 1 else 0 end)
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
1. Categorias y turnos mis solicitados. Las 3 categorias de cursos y turnos con
mayor cantidad de inscriptos por anio por sede.
*/
GO

CREATE OR ALTER VIEW LOS_LINDOS.VISTA_TOP3_CATEGORIA_TURNO_INSCRIPCIONES
AS
WITH RankedDuplas AS (
    SELECT 
        t.ANIO,
        s.nombre                        AS Nombre_Sede,
        s.provincia                     AS Provincia_Sede,
        s.localidad                     AS Localidad_Sede,
        s.direccion                     AS Direccion_Sede,
        cat.nombre                      AS Categoria_Curso,
        tur.nombre                      AS Turno,
        SUM(f.cantidad_inscripciones)   AS Total_Inscriptos,
        
        -- Ranking dentro de cada Anio + Sede
        ROW_NUMBER() OVER (
            PARTITION BY t.ANIO, f.sede 
            ORDER BY SUM(f.cantidad_inscripciones) DESC
        ) AS Ranking

    FROM LOS_LINDOS.BI_FACT_INSCRIPCIONES f
        JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t                   ON f.tiempo = t.ID
        JOIN LOS_LINDOS.BI_DIMENSION_Sede s                     ON f.sede = s.codigo_sede
        JOIN LOS_LINDOS.BI_DIMENSION_Categoria_Curso cat        ON f.categoria_curso = cat.codigo_categoria
        JOIN LOS_LINDOS.BI_DIMENSION_Turno tur                  ON f.turno = tur.codigo_turno

    GROUP BY 
        t.ANIO, 
        f.sede, 
        s.nombre, 
        s.provincia,
        s.localidad,
        S.direccion,
        cat.nombre, 
        tur.nombre
)
SELECT 
    ANIO 'Año',
    Nombre_Sede 'Sede',
    Provincia_Sede 'Provincia',
    Localidad_Sede 'Localidad',
    Direccion_Sede 'Dirección',
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
    t.PERIODO                               AS 'Período', 
    s.nombre                                AS 'Sede',
    s.provincia                             AS 'Provincia',
    s.localidad                             AS 'Localidad',
    s.direccion                             AS 'Dirección',
    SUM(f.cantidad_inscripciones)           AS 'Total de inscripciones',
    SUM(f.inscripciones_rechazadas)         AS 'Inscripciones rechazadas',
    SUM(f.inscripciones_aceptadas)          AS 'Inscripciones confirmadas',
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
    t.PERIODO,
    s.nombre,
    s.provincia,
    s.localidad,
    s.direccion
GO



CREATE TABLE LOS_LINDOS. BI_FACT_CURSADAS(
tiempo                      BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_TIEMPO(ID),
sede                        BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_SEDE(codigo_sede),
rango_etario_alumno         BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno(codigo_rango),
rango_etario_profesor       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor(codigo_rango),
turno                       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Turno(codigo_turno),
categoria_curso             BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
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
              AND DATEDIFF(YEAR, aa.fecha_nacimiento, cc.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima --> SUBQUERY OBTIENE LA CANTIDAD DE CURSADAS APROBADAS EN ESE MES, A�O, RANGO DE PROFESOR, RANGO DE ALUMNO, TURNO Y CATEGORIA DE CURSO
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
              AND DATEDIFF(YEAR, aa.fecha_nacimiento, cc.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima  --> SUBQUERY OBTIENE LA CANTIDAD DE CURSADAS DESAPROBADAS EN ESE MES, ANIO, RANGO DE PROFESOR, RANGO DE ALUMNO, TURNO Y CATEGORIA DE CURSO, SE PODRIA HABER OBTENIDO RESTANDO DEL TOTAL LA CANTIDAD APROBADA, PERO DE ESTA MANERA VEMOS QUE EL PROCEDIMIENTO ES CORRECTO AL %100, YA QUE DE TODAS FORMAS APROBADOS + DESAPROBADOS = TOTAL
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
              AND DATEDIFF(YEAR, aa.fecha_nacimiento, cc.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima   --> SUBQUERY OBTIENE LA CANTIDAD DE CURSADAS EN ESE MES, ANIO, RANGO DE PROFESOR, RANGO DE ALUMNO, TURNO Y CATEGORIA DE CURSO
              AND DATEDIFF(YEAR, p.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
              AND cc.codigo_categoria = c.codigo_categoria
              AND cc.codigo_turno = c.codigo_turno
     ) AS cantidad_cursadas,
     AVG(DATEDIFF (DAY,c.fecha_inicio,ef.fecha)) AS tiempo_promedio_de_finalizacion_en_dias   --> OBTIENE EL PROMEDIO DE FINALIZACION DE CURSADAS EN ESE MES, ANIO, RANGO DE PROFESOR, RANGO DE ALUMNO, TURNO Y CATEGORiA DE PROFESOR
    FROM LOS_LINDOS.Curso c
         JOIN LOS_LINDOS.Curso_x_Alumno ca on ca.codigo_curso =c.codigo
         JOIN LOS_LINDOS.Alumno a on a.legajo = ca.legajo_alumno
         JOIN LOS_LINDOS.Profesor p on p.codigo = c.codigo_profesor
         JOIN LOS_LINDOS.Examen_Final ef on ef.codigo_curso = c.codigo
         JOIN LOS_LINDOS.Examen_Final_de_Alumno efa on efa.codigo_final = ef.codigo AND efa.legajo_alumno = a.legajo
         JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t on YEAR(c.fecha_inicio) = t.ANIO AND MONTH(c.fecha_inicio) = t.MES
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno rea on  DATEDIFF(YEAR, a.fecha_nacimiento, c.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor rep on DATEDIFF(YEAR, p.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
         GROUP BY t.id,t.anio,t.mes,c.codigo_sede,rea.codigo_rango,rea.edad_minima,rea.edad_maxima,rep.codigo_rango,rep.edad_minima,rep.edad_maxima,c.codigo_turno,c.fecha_inicio,c.codigo_categoria,p.fecha_nacimiento --> la mitad de estos group by estan nada mas par que no rompa el codigo, en realidad no agrupan nada, es simplemente para trabajar con la informacion que proporcionan en las subqueries

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

 Hay cursadas que duran 200 dias, otras que duran poco mas de dos meses, es muy variante
*/


/*
3. Comparacion de desempenio de cursada por sede:. Porcentaje de aprobacion de cursada por sede, por anio. Se considera aprobada la cursada de un alumno cuando tiene nota mayor o igual a 4 en todos los modulos y el TP.
*/ 
GO
CREATE OR ALTER VIEW LOS_LINDOS.VISTA_PORCENTAJE_APROBACION_Y_DESAPROBACION
AS
SELECT 
    t.ANIO                                          AS 'Año',
    s.nombre                                        AS 'Sede',
    s.provincia                                     AS 'Provincia',
    s.localidad                                     AS 'Localidad',
    s.direccion                                     AS 'Dirección',
    SUM(f.cantidad_cursadas)                        AS 'Total de cursadas',
    SUM(f.cantidad_aprobados)                       AS 'Cursadas aprobadas',
    SUM(f.cantidad_desaprobados)                    AS 'Cursadas desaprobadas',
    CONCAT(
        FORMAT(
            100.0 * SUM(f.cantidad_aprobados) / NULLIF(SUM(f.cantidad_cursadas), 0),
            'N2'
        ),
        '%'
    ) AS 'Porcentaje aprobación',
    CONCAT(
        FORMAT(
            100.0 * SUM(f.cantidad_desaprobados) / NULLIF(SUM(f.cantidad_cursadas), 0),
            'N2'
        ),
        '%'
    ) AS 'Porcentaje de desaprobación'

FROM LOS_LINDOS.BI_FACT_CURSADAS f
    JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t     ON f.tiempo = t.ID
    JOIN LOS_LINDOS.BI_DIMENSION_Sede s       ON f.sede = s.codigo_sede
GROUP BY 
    t.ANIO,
    s.codigo_sede,
    s.nombre,
    s.provincia,
    s.localidad,
    s.direccion
GO


/*
4. Tiempo promedio de finalización de curso: Tiempo promedio entre el inicio del curso y la aprobación del final según la categoría de los cursos, por año. (Tener en cuenta el año de inicio del curso) 
*/


CREATE OR ALTER VIEW LOS_LINDOS.VISTA_PROMEDIO_FINALIZACION
AS
SELECT TOP 35 -- SIEMPRE SERAN 35 YA QUE 7 AÑOS X 5 CATEGORÍAS = 35 FILAS
    t.ANIO                                                      AS 'Año',
    cat.nombre                                                  AS 'Categoría',
    CAST(AVG(f.promedio_finalizacion_dias)AS DECIMAL(10,0))     AS 'Tiempo promedio de finalización de cursada en días'
FROM LOS_LINDOS.BI_FACT_CURSADAS f
    JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t              ON f.tiempo = t.ID
    JOIN LOS_LINDOS.BI_DIMENSION_Categoria_Curso cat   ON f.categoria_curso = cat.codigo_categoria
GROUP BY 
    t.ANIO,
    cat.nombre
ORDER BY t.ANIO,cat.nombre
GO

--
CREATE TABLE LOS_LINDOS.BI_FACT_FINALES(
tiempo                      BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_TIEMPO(ID),
sede                        BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_SEDE(codigo_sede),
rango_etario_alumno         BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno(codigo_rango),
rango_etario_profesor       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor(codigo_rango),
turno                       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Turno(codigo_turno),
categoria_curso             BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
promedio_de_notas           FLOAT NULL,
cantidad_de_ausentes        INT,
cantidad_de_inscriptos      INT
PRIMARY KEY(tiempo,sede,rango_etario_alumno,rango_etario_profesor,turno,categoria_curso)
)
GO

INSERT INTO LOS_LINDOS.BI_FACT_FINALES
SELECT
    t.ID,
    c.codigo_sede,
    rea.codigo_rango,
    rep.codigo_rango,
    c.codigo_turno,
    c.codigo_categoria,
    ROUND(AVG(CAST(fa.nota AS FLOAT)), 2),
    SUM(CASE WHEN fa.presente = 0 THEN 1 ELSE 0 END),
    COUNT(*)
FROM LOS_LINDOS.Examen_Final f
JOIN LOS_LINDOS.Curso c ON c.codigo=f.codigo_curso
JOIN LOS_LINDOS.Examen_Final_de_Alumno fa ON fa.codigo_final=f.codigo
JOIN LOS_LINDOS.Alumno a ON a.legajo=fa.legajo_alumno
JOIN LOS_LINDOS.Profesor p on p.codigo=fa.codigo_profesor
JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON t.ANIO=YEAR(f.fecha) AND t.MES=MONTH(f.fecha)
JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno rea on DATEDIFF(YEAR, a.fecha_nacimiento, f.fecha) BETWEEN rea.edad_minima AND rea.edad_maxima
JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor rep on DATEDIFF(YEAR, p.fecha_nacimiento, f.fecha) BETWEEN rep.edad_minima AND rep.edad_maxima
GROUP BY t.ID, c.codigo_sede, rea.codigo_rango, rep.codigo_rango, c.codigo_turno, c.codigo_categoria;

/*
5. Nota promedio de finales. Promedio de nota de finales según el rango etario del
alumno y la categoría del curso por semestre.
*/
GO

CREATE OR ALTER VIEW LOS_LINDOS.VISTA_PROMEDIO_NOTAS_FINALES
AS
SELECT
    t.ANIO                                                                                      AS 'Año',
    t.NOMBRE_SEMESTRE                                                                           AS 'Semestre',
    rea.descripcion                                                                             AS 'Rango etario de alumno',
    cat.nombre                                                                                  AS 'Categoría de curso',
    SUM(f.cantidad_de_inscriptos)                                                               AS 'Cantidad de inscripciones',
    SUM(f.cantidad_de_ausentes)                                                                 AS 'Cantidad de ausentes',
    COALESCE(FORMAT(AVG(f.promedio_de_notas),'N2'),'Nadie se presentó' )                        AS 'Nota promedio'
FROM LOS_LINDOS.BI_FACT_FINALES f
         JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t                  ON f.tiempo = t.ID
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno rea   ON f.rango_etario_alumno = rea.codigo_rango
         JOIN LOS_LINDOS.BI_DIMENSION_Categoria_Curso cat       ON f.categoria_curso = cat.codigo_categoria
GROUP BY
    t.ANIO,
    t.NOMBRE_SEMESTRE,
    rea.descripcion,
    cat.nombre


GO

/*
6. Tasa de ausentismo finales: Porcentaje de ausentes a finales (sobre la cantidad
de inscriptos) por semestre por sede.
*/


CREATE OR ALTER VIEW LOS_LINDOS.VISTA_TASA_AUSENTISMO_FINALES
AS
SELECT
    t.ANIO                                          AS 'Año',
    t.NOMBRE_SEMESTRE                               AS 'Semestre',
    s.nombre                                        AS 'Sede',
    s.provincia                                     AS 'Provincia',
    s.localidad                                     AS 'Localidad',
    s.direccion                                     AS 'Direccion',
    SUM(f.cantidad_de_inscriptos)                   AS 'Total de inscriptos',
    SUM(f.cantidad_de_ausentes)                     AS 'Total de ausentes',
    CONCAT(
            FORMAT(
                    100.0 * SUM(f.cantidad_de_ausentes) / NULLIF(SUM(f.cantidad_de_inscriptos), 0),
                    'N2'
            ),
            '%'
    ) AS 'Porcentaje de ausentismo',
    CONCAT(
        FORMAT(
            100.0 - (100.0 * SUM(f.cantidad_de_ausentes) / NULLIF(SUM(f.cantidad_de_inscriptos), 0)),
            'N2'
        ),
        '%'
    ) AS 'Porcentaje de presentes'

FROM LOS_LINDOS.BI_FACT_FINALES f
    JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON f.tiempo = t.ID
    JOIN LOS_LINDOS.BI_DIMENSION_Sede s   ON f.sede = s.codigo_sede
GROUP BY
    t.ANIO,
    t.NOMBRE_SEMESTRE,
    s.nombre,
    s.provincia,
    s.localidad,
    s.direccion

GO


CREATE TABLE LOS_LINDOS.BI_FACT_PAGOS(
tiempo                              BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_TIEMPO(ID),
sede                                BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_SEDE(codigo_sede),
rango_etario_alumno                 BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno(codigo_rango),
rango_etario_profesor               BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor(codigo_rango),
turno                               BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Turno(codigo_turno),
categoria_curso                     BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
medio_de_pago                       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Medio_Pago(codigo_medio_pago),
cantidad_de_pagos                   INT,
cantidad_de_pagos_en_termino        INT,
cantidad_de_pagos_fuera_de_termino  INT,
ingresos_en_terminos                FLOAT,
ingresos_fuera_de_termino           FLOAT,
ingresos_totales                    FLOAT
PRIMARY KEY(tiempo,sede,rango_etario_alumno,rango_etario_profesor,turno,categoria_curso,medio_de_pago)
)

INSERT INTO LOS_LINDOS.BI_FACT_PAGOS 
SELECT
    t.ID,
    c.codigo_sede,
    rea.codigo_rango,
    rep.codigo_rango,
    c.codigo_turno,
    c.codigo_categoria,
    p.codigo_medio_pago,
    count(*),
    sum(case when p.fecha > f.fecha_vencimiento then 0 else 1 end),
    sum(case when p.fecha > f.fecha_vencimiento then 1 else 0 end),
    sum(case when p.fecha > f.fecha_vencimiento then 0 else p.importe end),
    sum(case when p.fecha > f.fecha_vencimiento then p.importe else 0 end),
    sum(p.importe)
FROM LOS_LINDOS.Factura f
         JOIN LOS_LINDOS.Detalle_Factura df ON df.numero_factura = f.numero
         JOIN LOS_LINDOS.Curso c ON c.codigo = df.codigo_curso
         JOIN LOS_LINDOS.Alumno a ON a.legajo = f.legajo_alumno
         JOIN LOS_LINDOS.Profesor prof ON prof.codigo = c.codigo_profesor
         JOIN LOS_LINDOS.Pago p ON f.numero = p.numero_factura --> NO ES LEFT JOIN YA QUE TOMAMOS LOS DATOS DE LAS FACTURAS QUE SÍ TIENEN PAGOS, NO DE LAS QUE NO TIENEN
         JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON YEAR(f.fecha_emision) = t.ANIO AND MONTH(f.fecha_emision) = t.MES
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno rea on  DATEDIFF(YEAR, a.fecha_nacimiento, c.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor rep on DATEDIFF(YEAR, prof.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
         GROUP BY t.id, c.codigo_sede,rea.codigo_rango, rep.codigo_rango,c.codigo_turno,c.codigo_categoria, p.codigo_medio_pago
GO

/*
7. Desvío de pagos: Porcentaje de pagos realizados fuera de término por semestre. 
*/
CREATE OR ALTER VIEW LOS_LINDOS.VISTA_DESVIO_DE_PAGOS
AS
SELECT 
    t.ANIO                                          AS 'Año',
    t.NOMBRE_SEMESTRE                               AS 'Semestre',
    SUM(f.cantidad_de_pagos)                        AS 'Cantidad de pagos',
    SUM(f.cantidad_de_pagos_fuera_de_termino)       AS 'Cantidad de pagos fuera de término',
    CONCAT(
        FORMAT(
            100.0 * SUM(f.cantidad_de_pagos_fuera_de_termino) / NULLIF(SUM(f.cantidad_de_pagos), 0),
            'N2'
        ),
        '%'
    ) AS 'Porcentaje de pagos realizados fuera de término',
    CONCAT(
        FORMAT(
            100.0 - (100.0 * SUM(f.cantidad_de_pagos_fuera_de_termino) / NULLIF(SUM(f.cantidad_de_pagos), 0)), --> este si lo sacamos por complemento ya que en la tabla de hechos no obtenemos los pagos que fueron realizados en termino
            'N2'
        ),
        '%'
    ) AS 'Porcentaje de pagos en término'
FROM LOS_LINDOS.BI_FACT_PAGOS f
    JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON f.tiempo = t.ID
GROUP BY 
    t.ANIO,
    t.NOMBRE_SEMESTRE
GO

/*
9.Ingresos por categoría de cursos: Las 3 categorías de cursos que generan 
mayores ingresos por sede, por año.
*/

CREATE OR ALTER VIEW LOS_LINDOS.VISTA_TOP3_CATEGORIAS_INGRESOS
AS
WITH Ranked AS (
    SELECT 
        t.ANIO                                          AS ANIO,
        s.nombre                                        AS SEDE,
        s.provincia                                     AS PROVINCIA,
        s.localidad                                     AS LOCALIDAD,
        s.direccion                                     AS DIRECCION,
        cat.nombre                                      AS CATEGORIA,
        CAST(SUM(f.ingresos_totales) AS DECIMAL(18,2))  AS INGRESOS,
        ROW_NUMBER() OVER (
            PARTITION BY t.ANIO, f.sede 
            ORDER BY SUM(f.ingresos_totales) DESC
        ) AS Ranking
    FROM LOS_LINDOS.BI_FACT_PAGOS f
        JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t               ON f.tiempo = t.ID
        JOIN LOS_LINDOS.BI_DIMENSION_Sede s                 ON f.sede = s.codigo_sede
        JOIN LOS_LINDOS.BI_DIMENSION_Categoria_Curso cat    ON f.categoria_curso = cat.codigo_categoria
    GROUP BY 
        t.ANIO,
        f.sede,
        s.nombre,
        s.provincia,
        s.localidad,
        s.direccion,
        cat.nombre
)
SELECT 
    ANIO,
    SEDE,
    PROVINCIA,
    LOCALIDAD,
    DIRECCION,
    CATEGORIA,
    INGRESOS,
    Ranking
FROM Ranked
WHERE Ranking <= 3
GO

CREATE TABLE LOS_LINDOS.BI_FACT_FACTURAS(
tiempo                              BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_TIEMPO(ID),
sede                                BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_SEDE(codigo_sede),
rango_etario_alumno                 BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno(codigo_rango),
rango_etario_profesor               BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor(codigo_rango),
turno                               BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Turno(codigo_turno),
categoria_curso                     BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
cantidad_de_facturas                INT,
cantidad_de_facturas_pagadas        INT,
cantidad_de_facturas_sin_pagar      INT,
facturacion_esperada                FLOAT,
importes_adeudados                  FLOAT,                  
importes_facturados                 FLOAT 
PRIMARY KEY(tiempo,sede,rango_etario_alumno,rango_etario_profesor,turno,categoria_curso)
)

INSERT INTO LOS_LINDOS.BI_FACT_FACTURAS (tiempo,sede,rango_etario_alumno,rango_etario_profesor,turno,categoria_curso,cantidad_de_facturas,cantidad_de_facturas_pagadas,cantidad_de_facturas_sin_pagar,facturacion_esperada,importes_adeudados,importes_facturados)
SELECT
    t.ID,
    c.codigo_sede,
    rea.codigo_rango,
    rep.codigo_rango,
    c.codigo_turno,
    c.codigo_categoria,
    count(*),
    sum(case when p.codigo IS NOT NULL THEN 1 ELSE 0 END),
    sum(case when p.codigo IS NULL THEN 1 ELSE 0 END),
    sum(f.importe_total),
    sum(case when p.codigo IS NOT NULL THEN f.importe_total END),
    sum(case when p.codigo IS NULL THEN f.importe_total END)
FROM LOS_LINDOS.Factura f
         JOIN LOS_LINDOS.Detalle_Factura df ON df.numero_factura = f.numero
         LEFT JOIN LOS_LINDOS.Pago p ON p.numero_factura = f.numero  --> left join porque queremos mantener las facturas que no tienen pago
         JOIN LOS_LINDOS.Curso c ON c.codigo = df.codigo_curso
         JOIN LOS_LINDOS.Alumno a ON a.legajo = f.legajo_alumno
         JOIN LOS_LINDOS.Profesor prof ON prof.codigo = c.codigo_profesor
         JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON YEAR(f.fecha_emision) = t.ANIO AND MONTH(f.fecha_emision) = t.MES
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno rea on  DATEDIFF(YEAR, a.fecha_nacimiento, c.fecha_inicio) BETWEEN rea.edad_minima AND rea.edad_maxima
         JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor rep on DATEDIFF(YEAR, prof.fecha_nacimiento, c.fecha_inicio) BETWEEN rep.edad_minima AND rep.edad_maxima
         GROUP BY t.id, c.codigo_sede,rea.codigo_rango, rep.codigo_rango,c.codigo_turno,c.codigo_categoria

/*
8. Tasa de Morosidad Financiera mensual. Se calcula teniendo en cuenta el total 
de importes adeudados sobre facturación esperada en el mes. El monto adeudado se obtiene a partir de las facturas que no tengan pago registrado en dicho mes. 
*/
GO

CREATE OR ALTER VIEW LOS_LINDOS.VISTA_TASA_DE_MOROSIDAD_MENSUAL
AS
SELECT 
    t.PERIODO                                      AS 'Período',
    SUM(f.cantidad_de_facturas)                     AS 'Facturas emitidas',
    SUM(f.cantidad_de_facturas_pagadas)             AS 'Facturas pagadas',
    SUM(f.cantidad_de_facturas_sin_pagar)           AS 'Facturas adeudadas',
    CAST(SUM(f.facturacion_esperada)      AS DECIMAL(18,2)) AS 'Facturacion esperada',
    CAST(SUM(f.importes_facturados)       AS DECIMAL(18,2)) AS 'Importe facturado',
    CAST(SUM(f.importes_adeudados)      AS DECIMAL(18,2)) AS 'Importe adeudado',
    CONCAT(
        FORMAT(
            100.0 * SUM(f.importes_adeudados) / NULLIF(SUM(f.facturacion_esperada),0),
            'N2'
        ),
        '%'
    ) AS 'Tasa de morosidad',
    CONCAT(
        FORMAT(
            100.0 * SUM(f.importes_facturados) / NULLIF(SUM(f.facturacion_esperada),0),
            'N2'
        ),
        '%'
    ) AS 'Tasa de facturación'
FROM LOS_LINDOS.BI_FACT_FACTURAS f
    JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON f.tiempo = t.ID
GROUP BY 
    t.ANIO,
    t.MES,
    t.PERIODO

GO

CREATE TABLE LOS_LINDOS.BI_FACT_ENCUESTA(
tiempo                      BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_TIEMPO(ID),
codigo_sede                 BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_SEDE(codigo_sede),
rango_etario_alumno         BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Alumno(codigo_rango),
rango_etario_profesor       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor(codigo_rango),
turno                       BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Turno(codigo_turno),
categoria_curso             BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Categoria_Curso(codigo_categoria),
bloque_satisfaccion         BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion(codigo_bloque),
cantidad                    INT
PRIMARY KEY (tiempo,codigo_sede,rango_etario_alumno,rango_etario_profesor,turno,categoria_curso,bloque_satisfaccion)
)

INSERT INTO LOS_LINDOS.BI_FACT_ENCUESTA
SELECT
    t.ID,
    c.codigo_sede,
    rep.codigo_rango,
    c.codigo_turno,
    c.codigo_categoria,
    bs.codigo_bloque,
    COUNT(*)
FROM LOS_LINDOS.Encuesta e
JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON t.ANIO=YEAR(e.fecha_registro) AND t.MES=MONTH(e.fecha_registro)
JOIN LOS_LINDOS.Curso c ON c.codigo=e.codigo_curso
JOIN LOS_LINDOS.Profesor p on p.codigo=c.codigo_profesor
JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor rep on DATEDIFF(YEAR, p.fecha_nacimiento, e.fecha_registro) BETWEEN rep.edad_minima AND rep.edad_maxima
JOIN LOS_LINDOS.Respuesta r ON r.codigo_encuesta=e.codigo
JOIN LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion bs on r.respuesta BETWEEN bs.nota_minima AND bs.nota_maxima
GROUP BY t.ID, c.codigo_sede, rep.codigo_rango, c.codigo_turno, c.codigo_categoria, bs.codigo_bloque;


GO


CREATE OR ALTER VIEW LOS_LINDOS.INDICE_DE_SATISFACCION AS
SELECT
    t.ANIO AS 'Anio',
    rep.descripcion AS 'Rango Etario de Profesor',
    s.nombre AS 'Nombre de Sede',
    ROUND(
            (
                (
                    (SUM(CASE WHEN bs.descripcion = 'Satisfechos' THEN fe.cantidad ELSE 0 END) * 100.0 / SUM(fe.cantidad))
                    -
                    (SUM(CASE WHEN bs.descripcion = 'Insatisfechos' THEN fe.cantidad ELSE 0 END) * 100.0 / SUM(fe.cantidad))
                )+100
            )/2,2)
    AS 'Indice de Satisfaccion'
FROM LOS_LINDOS.BI_FACT_ENCUESTA fe
JOIN LOS_LINDOS.BI_DIMENSION_TIEMPO t ON t.ID=fe.tiempo
JOIN LOS_LINDOS.BI_DIMENSION_Rango_Etario_Profesor rep ON rep.codigo_rango=fe.rango_etario_profesor
JOIN LOS_LINDOS.BI_DIMENSION_Sede s ON s.codigo_sede=fe.codigo_sede
JOIN LOS_LINDOS.BI_DIMENSION_Bloque_Satisfaccion bs ON bs.codigo_bloque=fe.bloque_satisfaccion
GROUP BY t.ANIO, rep.descripcion, s.nombre;

GO

/*

-- 1. VISTAS 
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_TOP3_CATEGORIA_TURNO_INSCRIPCIONES;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_TASA_RECHAZO;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_PORCENTAJE_APROBACION_Y_DESAPROBACION;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_PROMEDIO_FINALIZACION;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_PROMEDIO_NOTAS_FINALES;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_TASA_AUSENTISMO_FINALES;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_DESVIO_DE_PAGOS;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_TASA_DE_MOROSIDAD_MENSUAL;
DROP VIEW IF EXISTS LOS_LINDOS.VISTA_TOP3_CATEGORIAS_INGRESOS;
DROP VIEW IF EXISTS LOS_LINDOS.INDICE_DE_SATISFACCION;
GO

-- 2. TABLAS DE HECHOS 
DROP TABLE IF EXISTS LOS_LINDOS.BI_FACT_INSCRIPCIONES;
DROP TABLE IF EXISTS LOS_LINDOS.BI_FACT_CURSADAS;
DROP TABLE IF EXISTS LOS_LINDOS.BI_FACT_FINALES;
DROP TABLE IF EXISTS LOS_LINDOS.BI_FACT_PAGOS;
DROP TABLE IF EXISTS LOS_LINDOS.BI_FACT_FACTURAS;
DROP TABLE IF EXISTS LOS_LINDOS.BI_FACT_ENCUESTA;
GO

-- 3. TABLAS DE DIMENSIONES 
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_TIEMPO;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_SEDE;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_RANGO_ETARIO_ALUMNO;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_RANGO_ETARIO_PROFESOR;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_TURNO;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_CATEGORIA_CURSO;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_MEDIO_PAGO;
DROP TABLE IF EXISTS LOS_LINDOS.BI_DIMENSION_BLOQUE_SATISFACCION;
GO

PRINT 'Esquema BI de LOS_LINDOS eliminado completamente. Listo para volver a crear y migrar desde cero.';

*/


-- VISTAS


SELECT * FROM LOS_LINDOS.VISTA_TOP3_CATEGORIA_TURNO_INSCRIPCIONES; --> 1
SELECT * FROM LOS_LINDOS.VISTA_TASA_RECHAZO; --> 2
SELECT * FROM LOS_LINDOS.VISTA_PORCENTAJE_APROBACION_Y_DESAPROBACION; --> 3
SELECT * FROM LOS_LINDOS.VISTA_PROMEDIO_FINALIZACION; --> 4
SELECT * FROM LOS_LINDOS.VISTA_PROMEDIO_NOTAS_FINALES --> 5
SELECT * FROM LOS_LINDOS.VISTA_TASA_AUSENTISMO_FINALES --> 6
SELECT * FROM LOS_LINDOS.VISTA_DESVIO_DE_PAGOS --> 7
SELECT * FROM LOS_LINDOS.VISTA_TASA_DE_MOROSIDAD_MENSUAL--> 8
SELECT * FROM LOS_LINDOS.VISTA_TOP3_CATEGORIAS_INGRESOS--> 9
SELECT * FROM LOS_LINDOS.INDICE_DE_SATISFACCION--> 10




--aclarar que la informacion redundante no se obtiene realizando complementos, simplemente es para chequear que el procedimiento sea consistente
--aclarar que ponemos informacion de más en las vistas para toma de decisiones correcta
--aclarar que por "mes" entendimos un mes específico de un año determinado, o sea, no averiguamos el total de inscripciones que hayan sido en mayo, si no para mayo de 2019, mayo de 2020, y etc.
        -- lo mismo con los semestres
--poner todas las vistas al final
--borrar esta lista

-- por cada tabla, chequear:
    -- chequear foreign keys a las tablas de dimensiones
    -- chequear esten todas las dimensiones en la creacion y en la migracion

-- por cada vista, chequear
    -- esta informacion completa
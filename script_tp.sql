use GD2C2025;
go

create schema LOS_LINDOS;
go


--creacion de tablas

-- =============================================
-- NIVEL 1: Tablas sin FOREIGN KEYS
-- =============================================

CREATE TABLE LOS_LINDOS.Estado (
    codigo_estado BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre_tipo_estado VARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Dia_Semana (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL
);

GO

CREATE TABLE LOS_LINDOS.Turno (
   codigo BIGINT PRIMARY KEY IDENTITY(1,1),
   nombre VARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Categoria (
   codigo BIGINT PRIMARY KEY IDENTITY(1,1),
   nombre VARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Institucion (
  cuit NVARCHAR(255) PRIMARY KEY,
  nombre NVARCHAR(255),
  razon NVARCHAR(255)
);
GO

CREATE TABLE LOS_LINDOS.Provincia (
   codigo BIGINT PRIMARY KEY IDENTITY(1,1),
   nombre NVARCHAR(255)
);
GO

CREATE TABLE LOS_LINDOS.Localidad (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255)
);
GO


CREATE TABLE LOS_LINDOS.Direccion (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255)
);
GO

CREATE TABLE LOS_LINDOS.Medio_Pago (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    medio_pago NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Pregunta (
  codigo BIGINT PRIMARY KEY IDENTITY(1,1),
  enunciado VARCHAR(255) NOT NULL
);
GO

-- =============================================
-- NIVEL 2: Tablas que referencian NIVEL 1
-- =============================================


CREATE TABLE LOS_LINDOS.Sede (
  codigo BIGINT PRIMARY KEY IDENTITY(1,1),
  nombre NVARCHAR(255) NOT NULL,
  codigo_localidad BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Localidad(codigo),
  codigo_direccion BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Direccion(codigo),
  codigo_provincia BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Provincia(codigo),
  mail NVARCHAR(255),
  cuit_institucion NVARCHAR(255) FOREIGN KEY REFERENCES LOS_LINDOS.Institucion(cuit)
);
GO

CREATE TABLE LOS_LINDOS.Alumno (
    legajo BIGINT PRIMARY KEY,
    nombre NVARCHAR(255),
    apellido NVARCHAR(255),
    dni BIGINT,
    fecha_nacimiento DATETIME2(6),
    codigo_direccion BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Direccion(codigo),
    codigo_localidad BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Localidad(codigo),
    codigo_provincia BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Provincia(codigo),
    telefono NVARCHAR(255)
);
GO

CREATE TABLE LOS_LINDOS.Profesor (
   codigo BIGINT PRIMARY KEY IDENTITY(1,1),
   nombre NVARCHAR(255),
   apellido NVARCHAR(255),
   dni NVARCHAR(255),
   mail NVARCHAR(255),
   telefono NVARCHAR(255),
   codigo_direccion BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Direccion(codigo),
   codigo_localidad BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Localidad(codigo),
   codigo_provincia BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Provincia(codigo),
   fecha_nacimiento DATETIME2(6)
);
GO

CREATE TABLE LOS_LINDOS.Curso (
   codigo BIGINT PRIMARY KEY,
   codigo_sede BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Sede(codigo),
   codigo_profesor BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Profesor(codigo),
   nombre VARCHAR(255),
   descripcion VARCHAR(255),
   codigo_categoria BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Categoria(codigo),
   fecha_inicio DATETIME2(6),
   fecha_fin DATETIME2(6),
   duracion_meses BIGINT,
   codigo_turno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Turno(codigo),
   precio_mensual DECIMAL(38,2)
);
GO

CREATE TABLE LOS_LINDOS.Inscripcion_Curso(
    numero BIGINT PRIMARY KEY,
    legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
    curso_codigo BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
    fecha DATETIME2
);
GO

CREATE TABLE LOS_LINDOS.Estado_de_Inscripción (
   codigo_estado_inscripcion BIGINT PRIMARY KEY IDENTITY(1,1),
   codigo_estado BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.Estado(codigo_estado),
   numero_inscripcion_curso BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.Inscripcion_Curso(numero),
   fecha_de_respuesta DATETIME2(6)
);
GO


-- =============================================
-- NIVEL 3: Tablas que referencian NIVEL 2
-- =============================================


CREATE TABLE LOS_LINDOS.Factura (
    numero BIGINT PRIMARY KEY,
    fecha_emision DATETIME2,
    fecha_vencimiento DATETIME2,
    importe_total DECIMAL(18,2),
    legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo)
);
GO

-- =============================================
-- NIVEL 4: Tablas que referencian NIVEL 3
-- =============================================



CREATE TABLE LOS_LINDOS.Curso_x_Alumno (
     legajo_alumno BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
     codigo_curso BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
     PRIMARY KEY (legajo_alumno, codigo_curso)
);
GO

CREATE TABLE LOS_LINDOS.Curso_x_dia (
     codigo_dia_semana BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.Dia_Semana(codigo),
     codigo_curso BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
     PRIMARY KEY (codigo_dia_semana, codigo_curso)
);
GO


CREATE TABLE LOS_LINDOS.Trabajo_Practico (
   legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
   codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
   nota BIGINT,
   fecha_evaluacion DATETIME2,
   PRIMARY KEY (legajo_alumno, codigo_curso)
);
GO

CREATE TABLE LOS_LINDOS.Examen_Final (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
    fecha DATETIME2,
    hora VARCHAR(255),
    descripcion VARCHAR(255)
);
GO

CREATE TABLE LOS_LINDOS.Encuesta (
      codigo BIGINT PRIMARY KEY IDENTITY(1,1),
      codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
      fecha_registro DATETIME2,
      observaciones varchar(255)
);
GO

CREATE TABLE LOS_LINDOS.Detalle_Factura (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    periodo_mes BIGINT,
    importe DECIMAL(18,2),
    codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
    numero_factura BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Factura(numero),
    periodo_anio BIGINT
);
GO

CREATE TABLE LOS_LINDOS.Pago (
  codigo BIGINT PRIMARY KEY IDENTITY(1,1),
  fecha DATETIME2 NOT NULL,
  importe DECIMAL(18,2),
  codigo_medio_pago BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Medio_Pago(codigo),
  numero_factura BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Factura(numero)
);
GO

-- =============================================
-- NIVEL 5: Tablas que referencian NIVEL 4
-- =============================================


CREATE TABLE LOS_LINDOS.Parcial (
  codigo BIGINT PRIMARY KEY IDENTITY(1,1),
  fecha DATETIME2,
  codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
  nombre_modulo VARCHAR(255),
  descripcion_modulo VARCHAR(255)
);
GO

CREATE TABLE LOS_LINDOS.Inscripcion_de_final (
   nro_inscripcion BIGINT PRIMARY KEY,
   legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
   codigo_final BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Examen_Final(codigo),
   fecha_inscripción DATETIME2
);
GO


CREATE TABLE LOS_LINDOS.Respuesta (
   codigo BIGINT PRIMARY KEY IDENTITY(1,1),
   codigo_pregunta BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Pregunta(codigo),
   codigo_encuesta BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Encuesta(codigo),
   respuesta BIGINT NOT NULL
);
GO

-- =============================================
-- NIVEL 6: Tablas que referencian NIVEL 5
-- =============================================

CREATE TABLE LOS_LINDOS.Parcial_de_alumno (
     codigo_parcial BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Parcial(codigo),
     legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
     nota BIGINT,
     presente BIT,
     instancia BIGINT,
     PRIMARY KEY (codigo_parcial, legajo_alumno)
);
GO

CREATE TABLE LOS_LINDOS.Examen_Final_de_Alumno (
    codigo BIGINT IDENTITY(1,1),
    codigo_final BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Examen_Final(codigo),
    legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
    codigo_profesor BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Profesor(codigo),
    presente BIT,
    nota BIGINT
);
GO

-- --------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE LOS_LINDOS.Migrar_Estados
AS
BEGIN
    INSERT INTO LOS_LINDOS.Estado(nombre_tipo_estado)
    SELECT DISTINCT Inscripcion_Estado
    FROM gd_esquema.Maestra
    WHERE Inscripcion_Estado IS NOT NULL
END
GO


CREATE PROCEDURE LOS_LINDOS.Migrar_Dia_Semana
AS
BEGIN
    INSERT INTO LOS_LINDOS.Dia_Semana (nombre)
    SELECT DISTINCT Curso_Dia FROM gd_esquema.Maestra
    WHERE Curso_Dia IS NOT NULL;
END

GO


CREATE PROCEDURE LOS_LINDOS.Migrar_Categorias
AS
    BEGIN
        INSERT INTO LOS_LINDOS.Categoria (nombre)
        SELECT DISTINCT 
            Curso_Categoria 
            FROM gd_esquema.Maestra
        WHERE Curso_Categoria IS NOT NULL;
    END
GO

CREATE PROCEDURE LOS_LINDOS.Migrar_Turnos AS
BEGIN
INSERT INTO Turno (nombre)
SELECT DISTINCT Curso_Turno
    FROM gd_esquema.Maestra
    WHERE Curso_Turno IS NOT NULL;
END
GO


CREATE PROCEDURE LOS_LINDOS.Migrar_Instituciones
        AS
BEGIN
    INSERT INTO LOS_LINDOS.Institucion (cuit,nombre,razon)
    SELECT DISTINCT 
        Institucion_Cuit, 
        Institucion_Nombre, 
        Institucion_RazonSocial
    FROM gd_esquema.Maestra
    WHERE Institucion_Cuit IS NOT NULL 
END
GO


CREATE PROCEDURE LOS_LINDOS.Migrar_Provincias AS
BEGIN
    INSERT INTO Provincia (nombre)
    SELECT DISTINCT Sede_Provincia FROM gd_esquema.Maestra WHERE Sede_Provincia IS NOT NULL
    UNION
    SELECT DISTINCT Profesor_Provincia FROM gd_esquema.Maestra WHERE Profesor_Provincia IS NOT NULL
    UNION
    SELECT DISTINCT Alumno_Provincia FROM gd_esquema.Maestra WHERE Alumno_Provincia IS NOT NULL;
END
GO


-- localidades
CREATE PROCEDURE LOS_LINDOS.Migrar_Localidades AS
BEGIN
INSERT INTO Localidad (nombre)
SELECT DISTINCT Alumno_Localidad FROM gd_esquema.Maestra WHERE Alumno_Localidad IS NOT NULL
UNION
SELECT DISTINCT Profesor_Localidad FROM gd_esquema.Maestra WHERE Profesor_Localidad IS NOT NULL
UNION
SELECT DISTINCT Sede_Localidad FROM gd_esquema.Maestra WHERE Sede_Localidad IS NOT NULL;
END
GO



-- direcciones
CREATE PROCEDURE LOS_LINDOS.Migrar_Direcciones AS
BEGIN
INSERT INTO Direccion (nombre)
    SELECT DISTINCT Alumno_Direccion FROM gd_esquema.Maestra WHERE Alumno_Direccion IS NOT NULL
    UNION
    SELECT DISTINCT Profesor_Direccion FROM gd_esquema.Maestra WHERE Profesor_Direccion IS NOT NULL
    UNION
    SELECT DISTINCT Sede_Direccion FROM gd_esquema.Maestra WHERE Sede_Direccion IS NOT NULL;
END
GO

--- MEDIOS DE PAGO
CREATE PROCEDURE LOS_LINDOS.Migrar_Medio_Pago AS
BEGIN
INSERT INTO Medio_Pago (medio_pago)
    SELECT DISTINCT Pago_MedioPago FROM gd_esquema.Maestra
    WHERE Pago_MedioPago IS NOT NULL

END
GO

CREATE PROCEDURE LOS_LINDOS.Migrar_Preguntas AS
BEGIN
INSERT INTO Pregunta (enunciado)
SELECT DISTINCT Encuesta_Pregunta1 FROM gd_esquema.Maestra WHERE Encuesta_Pregunta1 IS NOT NULL
UNION
SELECT DISTINCT Encuesta_Pregunta2 FROM gd_esquema.Maestra WHERE Encuesta_Pregunta2 IS NOT NULL
UNION
SELECT DISTINCT Encuesta_Pregunta3 FROM gd_esquema.Maestra WHERE Encuesta_Pregunta3 IS NOT NULL
UNION
SELECT DISTINCT Encuesta_Pregunta4 FROM gd_esquema.Maestra WHERE Encuesta_Pregunta4 IS NOT NULL
END
GO


--sedes
CREATE PROCEDURE LOS_LINDOS.Migrar_Sedes AS
BEGIN
INSERT INTO Sede (nombre,codigo_provincia, codigo_direccion, codigo_localidad, mail, cuit_institucion)
    SELECT DISTINCT 
        m.Sede_Nombre,
        p.codigo,
        d.codigo,
        l.codigo,
        m.Sede_Mail,
        m.Institucion_Cuit
    FROM gd_esquema.Maestra m
    JOIN Provincia p ON p.nombre = m.Sede_Provincia AND m.Sede_Provincia IS NOT NULL
    JOIN Direccion d ON d.nombre = m.Sede_Direccion AND m.Sede_Direccion IS NOT NULL
    JOIN Localidad l ON l.nombre = m.Sede_Localidad AND m.Sede_Localidad IS NOT NULL
    WHERE m.Sede_Nombre IS NOT NULL and m.Sede_Provincia IS NOT NULL and m.Sede_Direccion IS NOT NULL AND m.Sede_Localidad IS NOT NULL AND m.Sede_Mail IS NOT NULL AND m.Institucion_Cuit IS NOT NULL 
END
GO


-- alumnos
CREATE PROCEDURE LOS_LINDOS.Migrar_Alumnos AS
BEGIN
INSERT INTO Alumno (legajo,nombre,apellido, dni,fecha_nacimiento, telefono, codigo_direccion, codigo_localidad,  codigo_provincia)
SELECT DISTINCT
    m.Alumno_Legajo,
    m.Alumno_Nombre,
    m.Alumno_Apellido,
    m.Alumno_Dni,
    m.Alumno_FechaNacimiento,
    m.Alumno_Telefono,
    d.codigo,
    l.codigo,
    p.codigo
FROM gd_esquema.Maestra m
         JOIN LOS_LINDOS.Provincia p ON p.nombre = m.Alumno_Provincia AND m.Alumno_Provincia IS NOT NULL
         JOIN Direccion d ON d.nombre = m.Alumno_Direccion AND m.Alumno_Direccion IS NOT NULL
         JOIN Localidad l ON l.nombre = m.Alumno_Localidad AND m.Alumno_Localidad IS NOT NULL
WHERE m.Alumno_Legajo IS NOT NULL;
END
GO

CREATE PROCEDURE LOS_LINDOS.Migrar_Profesores AS
BEGIN
INSERT INTO Profesor (nombre, apellido, dni, mail, telefono, codigo_direccion, codigo_localidad, codigo_provincia, fecha_nacimiento)
SELECT DISTINCT
    m.Profesor_nombre,
    m.Profesor_Apellido,
    m.Profesor_Dni,
    m.Profesor_Mail,
    m.Profesor_Telefono,
    d.codigo,
    l.codigo,
    p.codigo,
    m.Profesor_FechaNacimiento
FROM gd_esquema.Maestra m
JOIN Direccion d ON d.nombre=m.Profesor_Direccion AND m.Profesor_Direccion IS NOT NULL
JOIN Localidad l ON l.nombre=m.Profesor_Localidad AND m.Profesor_Localidad IS NOT NULL
JOIN Provincia p ON p.nombre=m.Profesor_Provincia AND m.Profesor_Provincia IS NOT NULL
WHERE
    m.Profesor_nombre IS NOT NULL
    AND
    m.Profesor_Apellido IS NOT NULL
    AND
    m.Profesor_Dni IS NOT NULL
    AND
    m.Profesor_Mail IS NOT NULL
    AND
    m.Profesor_Telefono IS NOT NULL
    AND
    m.Profesor_FechaNacimiento IS NOT NULL;
END
GO

CREATE PROCEDURE LOS_LINDOS.Migrar_Cursos AS
BEGIN
    INSERT INTO Curso (codigo ,codigo_sede, codigo_profesor, nombre, descripcion, codigo_categoria, fecha_inicio, fecha_fin, duracion_meses, codigo_turno, precio_mensual)
    SELECT DISTINCT 
        m.Curso_Codigo, 
        s.codigo, 
        p.codigo, 
        m.Curso_Nombre, 
        m.Curso_Descripcion, 
        c.codigo,
        m.Curso_FechaInicio,
        m.Curso_FechaFin, 
        m.Curso_DuracionMeses, 
        t.codigo, 
        m.Curso_PrecioMensual
    FROM gd_esquema.Maestra m
             JOIN LOS_LINDOS.Sede s on s.nombre = m.Sede_nombre and s.mail =m.Sede_Mail and s.cuit_institucion = m.Institucion_Cuit -- IMPORTANTISIMO: NO HAY COLUMNA "CURSO_SEDE", ENTONCES TENGO QUE ASIGNARLE UNA SEDE A UN CURSO SI LA FILA DE ESE "CURSO_CODIGO" TIENE LOS DATOS DE SEDE QUE COINCIDAN CON UNA FILA DE LA TABLA DE SEDES, alcanza con matchear los datos DESNORMALIZADOS de la sede ya que se asume que las demás tablas tienen datos consistentes
             JOIN LOS_LINDOS.Profesor p on p.nombre = m.Profesor_nombre and p.apellido = m.Profesor_apellido and p.telefono = m.Profesor_telefono and p.dni = m.Profesor_Dni and p.mail = m.Profesor_Mail and p.fecha_nacimiento = m.Profesor_FechaNacimiento -- IMPORTANTISIMO: NO HAY COLUMNA "CURSO_PROFESOR", ENTONCES TENGO QUE ASIGNARLE UN PROFESOR A UN CURSO SI LA FILA DE ESE "CURSO_CODIGO" TIENE LOS DATOS DE ESE PROFESOR QUE COINCIDAN CON UNA FILA DE LA TABLA DE PROFESORES
             JOIN LOS_LINDOS.Categoria c on c.nombre = m.Curso_Categoria
             JOIN LOS_LINDOS.Turno t on t.nombre = m.Curso_Turno
    WHERE 
        m.Curso_Codigo is not null  -- Si Curso_Codigo NO ES NULL => Tampoco lo son todas las filas que se usan para obtener informacion: Sede_nombre, Profesor_nombre, Profesor_apellido, Profesor_telefono, Profesor_Dni, Profesor_Mail, Profesor_FechaNacimiento, Curso_Categoria, Curso_Turno
    /*
    Capaz lo que nos dicen es que, si no hay una columna expícita que establezca la sede de un curso o el profesor de un curso, no intentemos obtener los valores de la tabla, si no que lo dejemos vacío.
    */
END
GO

 -- IMPORTANTISIMO: NO HAY COLUMNA "CURSO_PROFESOR", ENTONCES TENGO QUE ASIGNARLE UN PROFESOR A UN CURSO SI LA FILA DE ESE "CURSO_CODIGO" TIENE LOS DATOS DE ESE PROFESOR QUE COINCIDAN CON UNA FILA DE LA TABLA DE PROFESORES


CREATE PROCEDURE LOS_LINDOS.Migrar_Inscripciones_Cursos AS
BEGIN
    INSERT INTO Inscripcion_Curso (numero, legajo_alumno, curso_codigo,fecha)
    SELECT
        distinct m.Inscripcion_Numero,
        a.legajo,
        c.codigo,
        m.Inscripcion_Fecha
    FROM gd_esquema.Maestra m JOIN Alumno a on a.nombre = m.Alumno_Nombre and a.apellido = m.Alumno_Apellido and a.dni=m.Alumno_Dni and a.legajo = m.Alumno_Legajo and a.telefono = m.Alumno_Telefono 
                              JOIN Curso c on c.codigo = m.Curso_Codigo and c.descripcion = m.Curso_Descripcion and c.duracion_meses = m.Curso_DuracionMeses  and c.fecha_inicio = m.Curso_FechaInicio and c.fecha_fin = m.Curso_FechaFin and c.nombre = m.Curso_Nombre and c.precio_mensual = m.Curso_PrecioMensual                         
    WHERE m.Inscripcion_Numero IS NOT NULL
END
GO

-- Estado de Inscripcion
CREATE PROCEDURE LOS_LINDOS.Migrar_Estado_de_Inscripcion AS
BEGIN
INSERT INTO Estado_de_Inscripción (numero_inscripcion_curso, codigo_estado, fecha_de_respuesta)
SELECT distinct m.Inscripcion_Numero, e.codigo_estado, m.Inscripcion_FechaRespuesta
    FROM gd_esquema.Maestra m JOIN Estado e ON e.nombre_tipo_estado = m.inscripcion_Estado
    WHERE m.Inscripcion_Numero IS NOT NULL
END
GO

-- Factura
CREATE PROCEDURE LOS_LINDOS.Migrar_Facturas AS
BEGIN
INSERT INTO Factura (numero,fecha_emision,fecha_vencimiento,importe_total, legajo_alumno)
SELECT DISTINCT
    m.Factura_Numero,
    m.Factura_FechaEmision,
    m.Factura_FechaVencimiento,
    m.Factura_Total, --> dato normalizado
    a.legajo
    FROM gd_esquema.Maestra m JOIN Alumno a ON a.legajo= m.Alumno_Legajo AND m.Alumno_Legajo IS NOT NULL
WHERE
    m.Factura_Numero is not null;
END
GO

--Curso_x_alumno
CREATE PROCEDURE LOS_LINDOS.Migrar_Curso_x_Alumno AS
BEGIN
INSERT INTO Curso_x_Alumno (legajo_alumno,codigo_curso)
    select distinct Alumno_Legajo, Curso_Codigo 
        from gd_esquema.Maestra where Alumno_Legajo is not null and Curso_Codigo is not null
END
GO


--Curso_x_dia
CREATE PROCEDURE LOS_LINDOS.Migrar_Curso_x_Dia AS
BEGIN
INSERT INTO Curso_x_dia (codigo_curso,codigo_dia_semana)
    select distinct Curso_Codigo, ds.codigo 
        from gd_esquema.Maestra m
            join Dia_Semana ds on ds.nombre = m.Curso_Dia 
        where m.Curso_Dia is not null and m.Curso_Codigo is not null
END
GO

-- Trabajo Práctico

CREATE PROCEDURE LOS_LINDOS.Migrar_Trabajo_Practico AS
BEGIN
INSERT INTO Trabajo_Practico (legajo_alumno,codigo_curso,nota,fecha_evaluacion)
    select distinct Alumno_Legajo,Curso_Codigo,Trabajo_Practico_Nota,Trabajo_Practico_FechaEvaluacion from gd_esquema.Maestra where Trabajo_Practico_Nota is not null and Trabajo_Practico_FechaEvaluacion is not null;
END
GO


-- Examen_Final 
CREATE PROCEDURE LOS_LINDOS.Migrar_Examen_Final AS
BEGIN
INSERT INTO Examen_Final (codigo_curso, fecha, hora, descripcion)
    SELECT DISTINCT Curso_Codigo, Examen_Final_Fecha, Examen_Final_Hora, Examen_Final_Descripcion 
        from gd_esquema.Maestra 
            where Examen_Final_Fecha is not null 
                and Examen_Final_Hora is not null 
                and Examen_Final_Descripcion is not null
                and Curso_Codigo is not null
END
GO


--Encuesta
CREATE PROCEDURE LOS_LINDOS.Migrar_Encuesta AS
BEGIN
INSERT INTO Encuesta(codigo_curso,fecha_registro,observaciones)
    SELECT DISTINCT Curso_Codigo , Encuesta_FechaRegistro, Encuesta_Observacion 
        from gd_esquema.Maestra 
            where Curso_Codigo is not null 
            and Encuesta_FechaRegistro is not null
            and Encuesta_Observacion is not null
END
GO

--Detalle Factura

CREATE PROCEDURE LOS_LINDOS.Migrar_Detalle_Factura AS
BEGIN

INSERT INTO Detalle_Factura (importe,codigo_curso, periodo_mes,periodo_anio, numero_factura)
    SELECT DISTINCT Detalle_Factura_Importe, Curso_Codigo, Periodo_Mes, Periodo_Anio, Factura_Numero 
        from gd_esquema.Maestra 
            where Detalle_Factura_Importe is not null
                and Curso_Codigo is not null
                and Factura_Numero is not null
END
GO

--Pago

CREATE PROCEDURE LOS_LINDOS.Migrar_Pago AS
BEGIN 
   INSERT INTO Pago ( importe,fecha,codigo_medio_pago, numero_factura)
        select distinct m.Pago_Importe,m.Pago_Fecha,mp.codigo,m.Factura_Numero from gd_esquema.Maestra m
            join LOS_LINDOS.Medio_Pago mp on mp.medio_pago = m.Pago_MedioPago
        where m.Pago_Importe is not null and m.Pago_Fecha is not null and m.Pago_MedioPago is not null;
END
GO



--Parcial

CREATE PROCEDURE LOS_LINDOS.Migrar_Parcial AS
BEGIN
    INSERT INTO Parcial (fecha, codigo_curso, nombre_modulo, descripcion_modulo)
        SELECT DISTINCT Evaluacion_Curso_fechaEvaluacion, Curso_Codigo, Modulo_Nombre, Modulo_Descripcion 
            from gd_esquema.Maestra 
                where Evaluacion_Curso_fechaEvaluacion is not null -- DEVUELVE 4593 como cada modulo
                    and Modulo_Nombre is not null
                    and Modulo_Descripcion is not null
                    and Curso_Codigo is not null
END
GO  

-- Inscripcion a final

CREATE PROCEDURE LOS_LINDOS.Migrar_Inscripcion_de_final AS
BEGIN
    INSERT INTO Inscripcion_de_final (nro_inscripcion,legajo_alumno,codigo_final,fecha_inscripción)
        SELECT distinct Inscripcion_Final_nro,
                        Alumno_Legajo, 
                        f.codigo,
                        Inscripcion_Final_Fecha
            FROM gd_esquema.Maestra m
                join Examen_Final f on f.codigo_curso = m.Curso_Codigo 
                            and f.fecha = m.Examen_Final_Fecha 
                            and f.hora = m.Examen_Final_Hora 
                            and f.descripcion = m.Examen_Final_Descripcion
            where m.Inscripcion_Final_Nro is not null
                and m.Inscripcion_Final_Fecha is not null
                and m.Curso_Codigo is not null        
END  
GO

-- Parcial de alumno

CREATE PROCEDURE LOS_LINDOS.Migrar_Parcial_de_alumno AS
BEGIN
    INSERT INTO Parcial_de_alumno (codigo_parcial, legajo_alumno ,nota,presente,instancia)
    select distinct 
           p.codigo, 
           m.Alumno_Legajo, 
           m.Evaluacion_Curso_Nota, 
           m.Evaluacion_Curso_Presente, 
           m.Evaluacion_Curso_Instancia 
       from gd_esquema.Maestra m 
           join LOS_LINDOS.Parcial p on p.codigo_curso = m.Curso_Codigo 
            and p.nombre_modulo = m.Modulo_Nombre 
            and p.descripcion_modulo = m.Modulo_Descripcion 
            and p.fecha = m.Evaluacion_Curso_fechaEvaluacion
       where  m.Curso_Codigo is not null 
          and m.Evaluacion_Curso_fechaEvaluacion is not null 
          and m.Evaluacion_Curso_Instancia is not null
          and m.Evaluacion_Curso_Presente is not null
          -- and m.Evaluacion_Final_Nota is not null (!) ESTE NO, ya que hay filas que tienen este campo como nulleable
END
GO


CREATE PROCEDURE LOS_LINDOS.Migrar_Respuesta AS
BEGIN
    INSERT INTO Respuesta (codigo_pregunta, codigo_encuesta, respuesta)
    SELECT ps.codigo_pregunta, e.codigo, ps.respuesta
    FROM (
        SELECT DISTINCT
            m.Curso_Codigo,
            m.Encuesta_FechaRegistro,
            m.Encuesta_Observacion,
            p.codigo AS codigo_pregunta,
            m.Encuesta_Nota1 AS respuesta
        FROM gd_esquema.Maestra m JOIN Pregunta p ON p.enunciado = m.Encuesta_Pregunta1
        WHERE m.Curso_Codigo is not null
            and m.Encuesta_FechaRegistro is not null
            and m.Encuesta_Observacion is not null
            and m.Encuesta_Nota1 is not null
            

        UNION

        SELECT DISTINCT
            m.Curso_Codigo,
            m.Encuesta_FechaRegistro,
            m.Encuesta_Observacion,
            p.codigo AS codigo_pregunta,
            m.Encuesta_Nota2 AS respuesta
        FROM gd_esquema.Maestra m JOIN Pregunta p ON p.enunciado = m.Encuesta_Pregunta2
        WHERE m.Curso_Codigo is not null
            and m.Encuesta_FechaRegistro is not null
            and m.Encuesta_Observacion is not null
            and m.Encuesta_Nota2 is not null

        UNION

        SELECT DISTINCT
            m.Curso_Codigo,
            m.Encuesta_FechaRegistro,
            m.Encuesta_Observacion,
            p.codigo AS codigo_pregunta,
            m.Encuesta_Nota3 AS respuesta
        FROM gd_esquema.Maestra m JOIN Pregunta p ON p.enunciado = m.Encuesta_Pregunta3
        WHERE m.Curso_Codigo is not null
            and m.Encuesta_FechaRegistro is not null
            and m.Encuesta_Observacion is not null
            and m.Encuesta_Nota3 is not null

        UNION

        SELECT DISTINCT
            m.Curso_Codigo,
            m.Encuesta_FechaRegistro,
            m.Encuesta_Observacion,
            p.codigo AS codigo_pregunta,
            m.Encuesta_Nota4 AS respuesta
        FROM gd_esquema.Maestra m JOIN Pregunta p ON p.enunciado = m.Encuesta_Pregunta4
        WHERE m.Curso_Codigo is not null
            and m.Encuesta_FechaRegistro is not null
            and m.Encuesta_Observacion is not null
            and m.Encuesta_Nota4 is not null

    ) ps
    JOIN Encuesta e ON
        e.codigo_curso = ps.Curso_Codigo AND
        e.fecha_registro = ps.Encuesta_FechaRegistro AND
        e.observaciones = ps.Encuesta_Observacion;
END
GO

CREATE PROCEDURE LOS_LINDOS.Migrar_Examen_Final_de_Alumno AS
BEGIN
    INSERT INTO Examen_Final_de_Alumno  (codigo_final, legajo_alumno, codigo_profesor, presente, nota)
    SELECT DISTINCT
        f.codigo,
        m.Alumno_Legajo,
        p.codigo,
        m.Evaluacion_Final_Presente,
        m.Evaluacion_Final_Nota
    FROM gd_esquema.Maestra m
    JOIN Examen_Final f ON
        f.codigo_curso = m.Curso_Codigo AND
        f.fecha = m.Examen_Final_Fecha AND
        f.hora = m.Examen_Final_Hora AND
        f.descripcion = m.Examen_Final_Descripcion
    JOIN Profesor p ON
        p.nombre = m.Profesor_nombre AND
        p.apellido = m.Profesor_Apellido AND
        p.dni = m.Profesor_Dni AND
        p.mail = m.Profesor_Mail AND
        p.telefono = m.Profesor_Telefono AND
        p.fecha_nacimiento = m.Profesor_FechaNacimiento
    WHERE m.Evaluacion_Final_Presente is not null  
       -- and Evaluacion_Final_Nota is not null (!) -> NO PUEDE ir esta linea, ya que, hay casos de evaluaciones de final SIN NOTA, son los que no se presentó el alumno
          and m.Alumno_Legajo is not null
          and m.Curso_Codigo is not null
          and m.Examen_Final_Descripcion is not null
          and m.Examen_Final_Hora is not null
          and m.Examen_Final_Fecha is not null
          and m.Profesor_nombre is not null
          and m.Profesor_Apellido is not null
          and m.Profesor_Dni is not null
          and m.Profesor_Mail is not null
          and m.Profesor_Telefono is not null
          and m.Profesor_FechaNacimiento is not null
END
GO

BEGIN TRY
    BEGIN TRANSACTION;

    EXEC LOS_LINDOS.Migrar_Estados;
    PRINT 'Migrar_Estados completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Dia_Semana;
    PRINT 'Migrar_Dia_Semana completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Categorias;
    PRINT 'Migrar_Categorias completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Turnos;
    PRINT 'Migrar_Turnos completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Instituciones;
    PRINT 'Migrar_Instituciones completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Provincias;
    PRINT 'Migrar_Provincias completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Localidades;
    PRINT 'Migrar_Localidades completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Direcciones;
    PRINT 'Migrar_Direcciones completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Medio_Pago;
    PRINT 'Migrar_Medio_Pago completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Preguntas;
    PRINT 'Migrar_Preguntas completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Sedes;
    PRINT 'Migrar_Sedes completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Alumnos;
    PRINT 'Migrar_Alumnos completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Profesores;
    PRINT 'Migrar_Profesores completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Cursos;
    PRINT 'Migrar_Cursos completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Inscripciones_Cursos;
    PRINT 'Migrar_Inscripciones_Cursos completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Estado_de_Inscripcion;
    PRINT 'Migrar_Estado_de_Inscripcion completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Facturas;
    PRINT 'Migrar_Facturas completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Curso_x_Alumno;
    PRINT 'Migrar_Curso_x_Alumno completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Curso_x_Dia;
    PRINT 'Migrar_Curso_x_Dia completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Trabajo_Practico;
    PRINT 'Migrar_Trabajo_Practico completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Examen_Final;
    PRINT 'Migrar_Examen_Final completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Encuesta;
    PRINT 'Migrar_Encuesta completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Detalle_Factura;
    PRINT 'Migrar_Detalle_Factura completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Pago;
    PRINT 'Migrar_Pago completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Parcial;
    PRINT 'Migrar_Parcial completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Inscripcion_de_final;
    PRINT 'Migrar_Inscripcion_de_final completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Parcial_de_alumno;
    PRINT 'Migrar_Parcial_de_alumno completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Respuesta;
    PRINT 'Migrar_Respuesta completed successfully.';
    
    EXEC LOS_LINDOS.Migrar_Examen_Final_de_Alumno;
    PRINT 'Migrar_Examen_Final_de_Alumno completed successfully.';

    COMMIT TRANSACTION;
    PRINT 'All migrations completed successfully. Transaction committed.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred during migration:';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(10));
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
    PRINT 'All changes have been rolled back.';
END CATCH
GO


/*


DROP TABLE IF EXISTS LOS_LINDOS.Examen_Final_de_Alumno;
DROP TABLE IF EXISTS LOS_LINDOS.Parcial_de_alumno;
DROP TABLE IF EXISTS LOS_LINDOS.Respuesta;
DROP TABLE IF EXISTS LOS_LINDOS.Inscripcion_de_final;
DROP TABLE IF EXISTS LOS_LINDOS.Parcial;
DROP TABLE IF EXISTS LOS_LINDOS.Pago;
DROP TABLE IF EXISTS LOS_LINDOS.Detalle_Factura;
DROP TABLE IF EXISTS LOS_LINDOS.Encuesta;
DROP TABLE IF EXISTS LOS_LINDOS.Examen_Final;
DROP TABLE IF EXISTS LOS_LINDOS.Trabajo_Practico;
DROP TABLE IF EXISTS LOS_LINDOS.Curso_x_dia;
DROP TABLE IF EXISTS LOS_LINDOS.Curso_x_Alumno;
DROP TABLE IF EXISTS LOS_LINDOS.Factura;
DROP TABLE IF EXISTS LOS_LINDOS.Estado_de_Inscripción;
DROP TABLE IF EXISTS LOS_LINDOS.Inscripcion_Curso;
DROP TABLE IF EXISTS LOS_LINDOS.Curso;
DROP TABLE IF EXISTS LOS_LINDOS.Profesor;
DROP TABLE IF EXISTS LOS_LINDOS.Alumno;
DROP TABLE IF EXISTS LOS_LINDOS.Sede;

-- Eliminar tablas base (sin dependencias)
DROP TABLE IF EXISTS LOS_LINDOS.Pregunta;
DROP TABLE IF EXISTS LOS_LINDOS.Medio_Pago;
DROP TABLE IF EXISTS LOS_LINDOS.Direccion;
DROP TABLE IF EXISTS LOS_LINDOS.Localidad;
DROP TABLE IF EXISTS LOS_LINDOS.Provincia;
DROP TABLE IF EXISTS LOS_LINDOS.Institucion;
DROP TABLE IF EXISTS LOS_LINDOS.Categoria;
DROP TABLE IF EXISTS LOS_LINDOS.Turno;
DROP TABLE IF EXISTS LOS_LINDOS.Dia_Semana;
DROP TABLE IF EXISTS LOS_LINDOS.Estado;

-- Eliminar stored procedures
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Estados;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Dia_Semana;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Categorias;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Turnos;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Instituciones;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Provincias;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Localidades;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Direcciones;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Medio_Pago;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Preguntas;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Sedes;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Alumnos;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Profesores;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Cursos;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Inscripciones_Cursos;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Estado_de_Inscripcion;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Facturas;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Curso_x_Alumno;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Curso_x_Dia;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Trabajo_Practico;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Examen_Final;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Encuesta;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Detalle_Factura;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Pago;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Parcial;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Inscripcion_de_final;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Parcial_de_alumno;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Respuesta;
DROP PROCEDURE IF EXISTS LOS_LINDOS.Migrar_Examen_Final_de_Alumno;

-- Finalmente eliminar el schema
DROP SCHEMA IF EXISTS LOS_LINDOS;
GO

*/


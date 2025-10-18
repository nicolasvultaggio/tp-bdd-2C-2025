use GD2C2025;
go

create schema LOS_LINDOS;
go

drop schema LOS_LINDOS;
/*
creacion de tablas
*/

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
   nombre NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Localidad (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Direccion (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255) NOT NULL
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

CREATE TABLE LOS_LINDOS.Estado_de_inscripción (
   codigo_estado_inscripcion BIGINT PRIMARY KEY IDENTITY(1,1),
   codigo_estado BIGINT NOT NULL FOREIGN KEY REFERENCES LOS_LINDOS.Estado(codigo_estado),
   fecha_de_respuesta DATETIME2
);
GO

CREATE TABLE LOS_LINDOS.Sede (
  codigo BIGINT PRIMARY KEY IDENTITY(1,1),
  nombre NVARCHAR(255) NOT NULL,
  codigo_localidad BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Localidad(codigo),
  codigo_direccion BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Direccion(codigo),
  codigo_provincia BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Provinci(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Alumno (
    legajo BIGINT PRIMARY KEY,
    nombre NVARCHAR(255),
    apellido NVARCHAR(255),
    dni BIGINT,
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
   fecha_nacimiento DATETIME
);
GO

-- =============================================
-- NIVEL 3: Tablas que referencian NIVEL 2
-- =============================================

CREATE TABLE LOS_LINDOS.Curso (
   codigo BIGINT PRIMARY KEY,
   codigo_sede BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Sede(codigo),
   codigo_profesor BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Profesor(codigo),
   nombre VARCHAR(255),
   descripcion VARCHAR(255),
   codigo_categoria BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Categoria(codigo),
   fecha_inicio DATETIME2,
   fecha_fin DATETIME2,
   duracion_meses BIGINT,
   codigo_turno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Turno(codigo),
   precio_mensual DECIMAL(38,2)
);
GO

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

CREATE TABLE LOS_LINDOS.Inscripcion_Curso(
    numero BIGINT PRIMARY KEY,
    legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
    curso_codigo BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
    codigo_estado_inscripcion BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Estado_de_inscripción(codigo_estado_inscripcion),
    fecha DATETIME2,
    fecha_respuesta DATETIME2
);
GO

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

CREATE TABLE LOS_LINDOS.Modulo (
    codigo BIGINT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion BIGINT,
    codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Trabajo_Practico (
   codigo BIGINT PRIMARY KEY,
   codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
   fecha_de_entrega DATE
);
GO

CREATE TABLE LOS_LINDOS.Final (
    codigo BIGINT PRIMARY KEY,
    codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
    fecha DATETIME2,
    hora VARCHAR(255),
    descripcion VARCHAR(255)
);
GO

CREATE TABLE LOS_LINDOS.Encuesta (
      codigo BIGINT PRIMARY KEY IDENTITY(1,1),
      codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
      fecha_registro DATETIME2
);
GO

CREATE TABLE LOS_LINDOS.Factura_De_Curso (
    codigo BIGINT PRIMARY KEY,
    periodo BIGINT,
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
  codigo BIGINT PRIMARY KEY,
  fecha DATETIME2,
  codigo_modulo BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Modulo(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Inscripcion_de_final (
   nro_inscripcion BIGINT PRIMARY KEY,
   legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
   codigo_final BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Final(codigo),
   fecha_inscripción DATETIME2
);
GO

CREATE TABLE LOS_LINDOS.Trabajo_Practico_Alumno (
   codigo BIGINT PRIMARY KEY,
   codigo_curso BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
   legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
   nota BIGINT,
   fecha_evaluacion DATETIME2
);
GO

CREATE TABLE LOS_LINDOS.Observacion (
  codigo BIGINT PRIMARY KEY IDENTITY(1,1),
  observacion VARCHAR(255) NOT NULL,
  codigo_encuesta BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Encuesta(codigo)
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
     nota DATETIME2,
     presente BIT,
     instancia BIGINT
);
GO

CREATE TABLE LOS_LINDOS.Evaluacion_de_final (
    codigo BIGINT,
    codigo_final BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Final(codigo),
    legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
    codigo_profesor BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Profesor(codigo),
    presente BIT,
    nota BIGINT
);
GO

select * from gd_esquema.Maestra;

CREATE PROCEDURE LOS_LINDOS.Migrar_Estados
AS
    BEGIN
    INSERT INTO LOS_LINDOS.Estado_de_Inscripcion(estado)
    SELECT DISTINCT Inscripcion_Estado
    FROM gd_esquema.Maestra
    WHERE Inscripcion_Estado IS NOT NULL
    END
    GO


CREATE PROCEDURE LOS_LINDOS.Migrar_Dia_Semana
AS
BEGIN
    INSERT INTO LOS_LINDOS.Dia_Semana (nombre)
    SELECT distinct Curso_Dia FROM gd_esquema.Maestra
    WHERE Curso_Dia IS NOT NULL;
END

GO


CREATE PROCEDURE LOS_LINDOS.Migrar_Categorias
AS
BEGIN
    INSERT INTO LOS_LINDOS.Categoria (nombre)
    SELECT distinct Curso_Categoria FROM gd_esquema.Maestra
    WHERE Curso_Categoria IS NOT NULL;
END

GO

CREATE PROCEDURE LOS_LINDOS.Migrar_Turnos AS
BEGIN
INSERT INTO Turnos (nombre)
SELECT
    DISTINCT Curso_Turno
FROM gd_esquema.Maestra
WHERE Curso_Turno IS NOT NULL;
END
GO



CREATE PROCEDURE LOS_LINDOS.Migrar_Instituciones
        AS
BEGIN
INSERT INTO LOS_LINDOS.Institucion
SELECT Institucion_Nombre, Institucion_RazonSocial,DISTINCT Institucion_Cuit
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
SELECT DISTINCT Sede_Localidad FROM gd_esquema.Maestra WHERE Alumno_Provincia IS NOT NULL;
END
GO

-- localidades
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
INSERT INTO Medio_Pago (nombre)
SELECT DISTINCT Pago_MedioPago FROM gd_esquema.Maestra
    WHERE Pago_MedioPago IS NOT NULL
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

-- Estado de Inscripcion
CREATE PROCEDURE LOS_LINDOS.Migrar_Estado_de_Inscripcion AS
BEGIN
INSERT INTO Estado_de_Inscripcion(codigo_estado, fecha_respuesta)
SELECT estado.codigo_estado,m.Inscripcion_FechaRespuesta
    FROM gd_esquema.Maestra m
JOIN LOS_LINDOS.Estado estado ON estado.nombre_tipo_estado=m.inscripcion_Estado
WHERE m.inscripcion_estado IS NOT NULL
END
GO


--sedes
CREATE PROCEDURE LOS_LINDOS.Migrar_Sedes AS
BEGIN
INSERT INTO Sede (nombre,codigo_provincia, codigo_direccion, codigo_localidad)
    SELECT
        m.Sede_Nombre,
        p.codigo,
        d.codigo,
        l.codigo
    FROM gd_esquema.Maestra m
    JOIN Provincia p ON p.nombre = m.Sede_Provincia AND m.Sede_Provincia IS NOT NULL
    JOIN Direccion d ON d.nombre = m.Sede_Direccion AND m.Sede_Direccion IS NOT NULL
    JOIN Localidad l ON l.nombre = m.Sede_Localidad AND m.Sede_Localidad IS NOT NULL
    WHERE m.Sede_Nombre IS NOT NULL
END
GO

-- alumnos
CREATE PROCEDURE LOS_LINDOS.Migrar_Alumnos AS
BEGIN
INSERT INTO Alumno (nombre,apellido, dni, codigo_direccion, codigo_localidad, telefono, codigo_provincia)
SELECT
    m.Alumno_Nombre,
    m.Alumno_Apellido,
    m.Alumno_Dni,
    d.codigo,
    l.codigo,
    m.telefono,
    p.codigo
FROM gd_esquema.Maestra m
         JOIN LOS_LINDOS.Provincia p ON p.nombre = m.Alumno_Provincia AND m.Alumno_Provincia IS NOT NULL
         JOIN Direccion d ON d.nombre = m.Alumno_Direccion AND m.Alumno_Direccion IS NOT NULL
         JOIN Localidad l ON l.nombre = m.Alumno_Localidad AND m.Alumno_Localidad IS NOT NULL
WHERE m.Alumno_Nombre IS NOT NULL;
END
GO

CREATE PROCEDURE LOS_LINDOS.Migrar_Profesores AS
BEGIN
INSERT INTO Profesor (nombre, apellido, dni, mail, telefono, codigo_direccion, codigo_localidad, codigo_provincia, fecha_nacimiento)
SELECT
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
    m.Profesor_nombre IS NOT NULL AND
    m.Profesor_Apellido IS NOT NULL AND
    m.Profesor_Dni IS NOT NULL AND
    m.Profesor_Mail IS NOT NULL AND
    m.Profesor_Telefono IS NOT NULL
    m.Profesor_FechaNacimiento IS NOT NULL;
END
GO


-- Factura
CREATE PROCEDURE LOS_LINDOS.Migrar_Facturas AS
BEGIN
INSERT INTO Factura (fecha_emision,fecha_vencimiento,importe_total, legajo_alumno)
SELECT
    m.Factura_FechaEmision,
    m.Factura_FechaVencimiento,
    m.importe_total,
    a.legajo
    FROM gd_esquema.Maestra m
JOIN Alumno a ON a.legajo= m.Alumno_Legajo AND m.Alumno_Legajo IS NOT NULL
WHERE
    m.Factura_FechaEmision, IS NOT NULL,
    m.Factura_FechaVencimiento IS NOT NULL,
    m.importe_total IS NOT NULL,
    a.legajo IS NOT NULL
END
GO



/*
CREATE TABLE LOS_LINDOS.Cursos (
   codigo BIGINT PRIMARY KEY,
   codigo_sede BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Sedes(codigo),
   codigo_profesor BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Profesores(codigo),
   nombre VARCHAR(255),
   descripcion VARCHAR(255),
   codigo_categoria BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Categorias(codigo),
   fecha_inicio DATETIME2,
   fecha_fin DATETIME2,
   duracion_meses BIGINT,
   codigo_turno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Turnos(codigo),
   precio_mensual DECIMAL(38,2),
   codigo_dia_semana BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Dias_Semana(codigo),
   codigo_trabajo_practico BIGINT
);
GO
*/


CREATE PROCEDURE LOS_LINDOS.Migrar_Cursos AS
BEGIN
    INSERT INTO Cursos (codigo ,codigo_sede, codigo_profesor, nombre, descripcion, codigo_categoria, fecha_inicio, fecha_fin, duracion_meses, codigo_turno, precio_mensual)
    SELECT DISTINCT m.Curso_Codigo, s.codigo, p.codigo , m.Curso_Nombre, m.Curso_Descripcion, c.codigo, m.Curso_FechaInicio, m.Curso_FechaFin, m.Curso_DuracionMeses, t.codigo, m.Curso_PrecioMensual
    FROM gd_esquema.Maestra m
             JOIN LOS_LINDOS.Sede s on s.nombre = m.Sede_nombre -- IMPORTANTISIMO: NO HAY COLUMNA "CURSO_SEDE", ENTONCES TENGO QUE ASIGNARLE UNA SEDE A UN CURSO SI LA FILA DE ESE "CURSO_CODIGO" TIENE LOS DATOS DE SEDE QUE COINCIDAN CON UNA FILA DE LA TABLA DE SEDES, alcanza con matchear los datos DESNORMALIZADOS de la sede ya que se asume que las demás tablas tienen datos consistentes
             JOIN LOS_LINDOS.Profesor p on p.nombre = m.Profesor_nombre and p.apellido = m.Profesor_apellido and p.telefono = m.Profesor_telefono and p.dni = m.Profesor_Dni and p.mail = m.Profesor_Mail and p.fecha_nacimiento = m.Profesor_FechaNacimiento -- IMPORTANTISIMO: NO HAY COLUMNA "CURSO_PROFESOR", ENTONCES TENGO QUE ASIGNARLE UN PROFESOR A UN CURSO SI LA FILA DE ESE "CURSO_CODIGO" TIENE LOS DATOS DE ESE PROFESOR QUE COINCIDAN CON UNA FILA DE LA TABLA DE PROFESORES
             JOIN LOS_LINDOS.Categoria c on c.nombre = m.Curso_Categoria
             JOIN LOS_LINDOS.Turno t on t.nombre = m.Curso_Turno
    WHERE m.Curso_Codigo is not null ; -- Si Curso_Codigo NO ES NULL => Tampoco lo son todas las filas que se usan para obtener informacion: Sede_nombre, Profesor_nombre, Profesor_apellido, Profesor_telefono, Profesor_Dni, Profesor_Mail, Profesor_FechaNacimiento, Curso_Categoria, Curso_Turno

    /*
    Capaz lo que nos dicen es que, si no hay una columna expícita que establezca la sede de un curso o el profesor de un curso, no intentemos obtener los valores de la tabla, si no que lo dejemos vacío.
    */

END
GO


CREATE PROCEDURE LOS_LINDOS.Migrar_Inscripciones_Cursos AS
BEGIN
    INSERT INTO Inscripcion_Curso (legajo_alumno, curso_codigo, codigo_estado_inscripcion, fecha, fecha_respuesta)
    SELECT
        --yo tincho deje por acá
        x,
        y,
        z,
        m.Inscripcion_Fecha,
        m.Inscripcion_FechaRespuesta
    FROM gd_esquema.Maestra m
    WHERE m.Inscripcion_Fecha IS NOT NULL AND m.Inscripcion_FechaRespuesta IS NOT NULL
END
GO

/*
CREATE TABLE LOS_LINDOS.Inscripcion_Curso(
    numero BIGINT PRIMARY KEY,
    legajo_alumno BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Alumno(legajo),
    curso_codigo BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Curso(codigo),
    codigo_estado_inscripcion BIGINT FOREIGN KEY REFERENCES LOS_LINDOS.Estado_de_inscripción(codigo_estado_inscripcion),
    fecha DATETIME2,
    fecha_respuesta DATETIME2
);
GO*/
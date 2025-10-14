use GD2C2025;

go

create schema LOS_LINDOS;

go

drop schema LOS_LINDOS;
/*
creacion de tablas 
*/


CREATE TABLE LOS_LINDOS.Estados (
    codigo_estado BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre_tipo_estado VARCHAR(255) NOT NULL
);
GO


CREATE TABLE LOS_LINDOS.Estados_de_inscripción (
    codigo_estado_inscripcion BIGINT PRIMARY KEY IDENTITY(1,1),
    codigo_estado BIGINT NOT NULL,
    fecha_de_respuesta DATETIME2,
    CONSTRAINT FK_Estado_de_inscripcion_Estado 
        FOREIGN KEY (codigo_estado) 
        REFERENCES LOS_LINDOS.Estados(codigo_estado)
);
GO


CREATE TABLE LOS_LINDOS.Dias_Semana (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Turnos (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Categorias (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Instituciones (
    cuit NVARCHAR(255) PRIMARY KEY,
    nombre NVARCHAR(255),
    razon NVARCHAR(255) 
);
GO

CREATE TABLE LOS_LINDOS.Provincias (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255) NOT NULL
);
GO


CREATE TABLE LOS_LINDOS.Localidades (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Direcciones (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Sedes (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255) NOT NULL,
    codigo_localidad BIGINT,
    codigo_direccion BIGINT,
    codigo_provincia BIGINT,
    CONSTRAINT FK_Sede_Localidad
        FOREIGN KEY (codigo_localidad) 
        REFERENCES LOS_LINDOS.Localidades(codigo),
    CONSTRAINT FK_Sede_Direccion
        FOREIGN KEY (codigo_direccion) 
        REFERENCES LOS_LINDOS.Direcciones(codigo),
    CONSTRAINT FK_Sede_Provincia
        FOREIGN KEY (codigo_provincia) 
        REFERENCES LOS_LINDOS.Provincias(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Alumnos (
    legajo BIGINT PRIMARY KEY,
    nombre NVARCHAR(255),
    apellido NVARCHAR(255),
    dni BIGINT,
    codigo_direccion BIGINT,
    codigo_localidad BIGINT,
    codigo_provincia BIGINT,
    telefono NVARCHAR(255),
    CONSTRAINT FK_Alumno_Localidad
        FOREIGN KEY (codigo_localidad) 
        REFERENCES LOS_LINDOS.Localidades(codigo),
    CONSTRAINT FK_Alumno_Direccion
        FOREIGN KEY (codigo_direccion) 
        REFERENCES LOS_LINDOS.Direcciones(codigo),
    CONSTRAINT FK_Alumno_Provincia
        FOREIGN KEY (codigo_provincia) 
        REFERENCES LOS_LINDOS.Provincias(codigo)
);
GO


CREATE TABLE LOS_LINDOS.Profesores (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255),
    apellido NVARCHAR(255),
    dni NVARCHAR(255),
    mail NVARCHAR(255),
    telefono NVARCHAR(255),
    codigo_direccion BIGINT,
    codigo_localidad BIGINT,
    codigo_provincia BIGINT,
    fecha_nacimiento DATETIME,
    CONSTRAINT FK_Profesor_Localidad
        FOREIGN KEY (codigo_localidad) 
        REFERENCES LOS_LINDOS.Localidades(codigo),
    CONSTRAINT FK_Profesor_Direccion
        FOREIGN KEY (codigo_direccion) 
        REFERENCES LOS_LINDOS.Direcciones(codigo),
    CONSTRAINT FK_Profesor_Provincia
        FOREIGN KEY (codigo_provincia) 
        REFERENCES LOS_LINDOS.Provincias(codigo)
);
GO




CREATE TABLE LOS_LINDOS.Cursos (
    codigo BIGINT PRIMARY KEY,
    codigo_sede BIGINT,
    codigo_profesor BIGINT,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    codigo_categoria BIGINT,
    fecha_inicio DATETIME2,
    fecha_fin DATETIME2,
    duracion_meses BIGINT,
    codigo_turno BIGINT,
    precio_mensual DECIMAL(38,2),
    codigo_dia_semana BIGINT,
    codigo_trabajo_practico BIGINT,
    CONSTRAINT FK_Cursos_Sedes
        FOREIGN KEY (codigo_sede) 
        REFERENCES LOS_LINDOS.Sedes(codigo),
    CONSTRAINT FK_Cursos_Profesor
        FOREIGN KEY (codigo_profesor) 
        REFERENCES LOS_LINDOS.Profesores(codigo),
    CONSTRAINT FK_Cursos_Categorias
        FOREIGN KEY (codigo_categoria) 
        REFERENCES LOS_LINDOS.Categorias(codigo),
    CONSTRAINT FK_Cursos_Turnos
        FOREIGN KEY (codigo_turno) 
        REFERENCES LOS_LINDOS.Turnos(codigo),
    CONSTRAINT FK_Cursos_Dias_Semana
        FOREIGN KEY (codigo_dia_semana) 
        REFERENCES LOS_LINDOS.Dias_Semana(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Inscripciones_Cursos(
        numero BIGINT PRIMARY KEY,
        legajo_alumno BIGINT,
        curso_codigo BIGINT,
        codigo_estado_inscripcion BIGINT,
        fecha DATETIME2,
        fecha_respuesta DATETIME2,
        CONSTRAINT FK_Inscripciones_Cursos_Alumno
            FOREIGN KEY (legajo_alumno) 
            REFERENCES LOS_LINDOS.Alumnos(legajo),
        CONSTRAINT FK_Inscripciones_Cursos_Curso
            FOREIGN KEY (curso_codigo) 
            REFERENCES LOS_LINDOS.Cursos(codigo),
        CONSTRAINT FK_Inscripciones_Cursos_Estado
            FOREIGN KEY (codigo_estado_inscripcion) 
            REFERENCES LOS_LINDOS.Estados_de_inscripción(codigo_estado_inscripcion)

);

CREATE TABLE LOS_LINDOS.Cursos_x_Alumnos (
    legajo_alumnos BIGINT NOT NULL ,
    codigo_curso BIGINT NOT NULL,
    PRIMARY KEY (legajo_alumnos,codigo_curso),
    CONSTRAINT FK_Cursos_x_Alumnos_Alumnos
        FOREIGN KEY (legajo_alumnos) 
        REFERENCES LOS_LINDOS.Alumnos(legajo),
    CONSTRAINT FK_Cursos_x_Alumnos_Cursos
        FOREIGN KEY (codigo_curso) 
        REFERENCES LOS_LINDOS.Cursos(codigo)
  
);
GO



CREATE TABLE LOS_LINDOS.Cursos_x_dia (
    codigo_dia_semana BIGINT NOT NULL ,
    codigo_curso BIGINT NOT NULL,
    PRIMARY KEY (codigo_dia_semana,codigo_curso),
    CONSTRAINT FK_Cursos_x_dia_dia
        FOREIGN KEY (codigo_dia_semana) 
        REFERENCES LOS_LINDOS.Dias_Semana(codigo),
    CONSTRAINT FK_Cursos_x_dia_curso
        FOREIGN KEY (codigo_curso) 
        REFERENCES LOS_LINDOS.Cursos(codigo)
  
);
GO

CREATE TABLE LOS_LINDOS.Modulos (
    codigo BIGINT PRIMARY KEY ,
    nombre VARCHAR(255),
    descripcion BIGINT,
    codigo_curso BIGINT,
    CONSTRAINT FK_Modulos_Cursos
        FOREIGN KEY (codigo_curso) 
        REFERENCES LOS_LINDOS.Cursos(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Parciales (
    codigo BIGINT PRIMARY KEY ,
    fecha DATETIME2,
    codigo_modulo BIGINT,
    CONSTRAINT FK_Parciales_Modulos
        FOREIGN KEY (codigo_modulo) 
        REFERENCES LOS_LINDOS.Modulos(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Parciales_de_alumnos (
    codigo_parcial BIGINT,
    legajo_alumno BIGINT,
    nota DATETIME2,
    presente BIT,
    instancia BIGINT,
    CONSTRAINT FK_Parciales_De_Alumnos_Alumno
        FOREIGN KEY (legajo_alumno) 
        REFERENCES LOS_LINDOS.Alumnos(legajo),
     CONSTRAINT FK_Parciales_De_Alumnos_Parcial
        FOREIGN KEY (codigo_parcial) 
        REFERENCES LOS_LINDOS.Parciales(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Finales (
    codigo BIGINT PRIMARY KEY,
    codigo_curso BIGINT,
    fecha DATETIME2,
    hora VARCHAR(255),
    descripcion VARCHAR(255),
    CONSTRAINT FK_Final_Curso
        FOREIGN KEY (codigo_curso) 
        REFERENCES LOS_LINDOS.Cursos(codigo),
);
GO

CREATE TABLE LOS_LINDOS.Inscripciones_de_final (
    nro_inscripcion BIGINT PRIMARY KEY,
    legajo_alumno BIGINT,
    codigo_final BIGINT,
    fecha_inscripción DATETIME2,
    CONSTRAINT Inscripciones_de_final_Alumno
        FOREIGN KEY (legajo_alumno) 
        REFERENCES LOS_LINDOS.Alumnos(legajo),
    CONSTRAINT Inscripciones_de_final_Final
        FOREIGN KEY (codigo_final) 
        REFERENCES LOS_LINDOS.Finales(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Evaluacion_de_final (
    codigo BIGINT,
    codigo_final BIGINT,
    legajo_alumno BIGINT,
    codigo_profesor BIGINT,
    presente BIT,
    nota BIGINT
    CONSTRAINT FK_Evaluacion_de_final_Final
        FOREIGN KEY (codigo_final) 
        REFERENCES LOS_LINDOS.Finales(codigo),
    CONSTRAINT FK_Evaluacion_de_final_Alumno
        FOREIGN KEY (legajo_alumno) 
        REFERENCES LOS_LINDOS.Alumnos(legajo),
    CONSTRAINT FK_Evaluacion_de_final_Profesor
        FOREIGN KEY (codigo_profesor) 
        REFERENCES LOS_LINDOS.Profesores(codigo)
);
GO



CREATE TABLE LOS_LINDOS.Facturas (
    numero BIGINT PRIMARY KEY,
    fecha_emision DATETIME2,
    fecha_vencimiento DATETIME2,
    importe_total DECIMAL(18,2),
    legajo_alumno BIGINT,
    CONSTRAINT FK_Facturas_Alumnos
        FOREIGN KEY (legajo_alumno) 
        REFERENCES LOS_LINDOS.Alumnos(legajo),
  
);
GO

CREATE TABLE LOS_LINDOS.Trabajos_Practicos (
    codigo BIGINT PRIMARY KEY,
    codigo_curso BIGINT,
    fecha_de_entrega DATE
    CONSTRAINT FK_Trabajos_Practicos_Curso
        FOREIGN KEY (codigo_curso) 
        REFERENCES LOS_LINDOS.Cursos(codigo)
  
);
GO


CREATE TABLE LOS_LINDOS.Trabajos_Practicos_Alumnos (
    codigo BIGINT PRIMARY KEY,
    codigo_curso BIGINT,
    legajo_alumno BIGINT,
    nota BIGINT,
    fecha_evaluacion DATETIME2,
    CONSTRAINT FK_Trabajos_Practicos_Alumnos_Alumnos
        FOREIGN KEY (legajo_alumno) 
        REFERENCES LOS_LINDOS.Alumnos(legajo),
    CONSTRAINT FK_Trabajos_Practicos_Alumnos_Cursos
        FOREIGN KEY (codigo_curso) 
        REFERENCES LOS_LINDOS.Cursos(codigo)
  
);
GO


CREATE TABLE LOS_LINDOS.Medios_Pago (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    medio_pago NVARCHAR(50) NOT NULL
);
GO


CREATE TABLE LOS_LINDOS.Pagos (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    fecha DATETIME2 NOT NULL,
    importe DECIMAL(18,2),
    codigo_medio_pago BIGINT ,
    numero_factura BIGINT,
    CONSTRAINT FK_Pagos_Medios_Pago
        FOREIGN KEY (codigo_medio_pago) 
        REFERENCES LOS_LINDOS.Medios_Pago(codigo),
    CONSTRAINT FK_Pagos_Facturas
        FOREIGN KEY (numero_factura) 
        REFERENCES LOS_LINDOS.Facturas(numero),
);
GO

CREATE TABLE LOS_LINDOS.Facturas_De_Cursos (
    codigo BIGINT PRIMARY KEY,
    periodo BIGINT,
    importe DECIMAL(18,2),
    codigo_curso BIGINT,
    numero_factura BIGINT,
    periodo_anio BIGINT,
    CONSTRAINT FK_Facturas_De_Cursos_Facturas
        FOREIGN KEY (numero_factura) 
        REFERENCES LOS_LINDOS.Facturas(numero),
    CONSTRAINT FK_Facturas_De_Cursos_Cursos
        FOREIGN KEY (codigo_curso) 
        REFERENCES LOS_LINDOS.Cursos(codigo)
  
);
GO


CREATE TABLE LOS_LINDOS.Preguntas (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    enunciado VARCHAR(255) NOT NULL
);
GO

CREATE TABLE LOS_LINDOS.Encuestas (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    codigo_curso BIGINT,
    fecha_registro DATETIME2,
    CONSTRAINT FK_Encuestas_Cursos
        FOREIGN KEY (codigo_curso) 
        REFERENCES LOS_LINDOS.Cursos(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Observaciones (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    observacion VARCHAR(255) NOT NULL,
    codigo_encuesta BIGINT,
    CONSTRAINT FK_Observaciones_Encuestas
        FOREIGN KEY (codigo_encuesta) 
        REFERENCES LOS_LINDOS.Encuestas(codigo)
);
GO

CREATE TABLE LOS_LINDOS.Respuestas (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    codigo_pregunta BIGINT,
    codigo_encuesta BIGINT,
    respuesta BIGINT NOT NULL,
    CONSTRAINT FK_Respuestas_Preguntas
        FOREIGN KEY (codigo_pregunta) 
        REFERENCES LOS_LINDOS.Preguntas(codigo),
    CONSTRAINT FK_Respuestas_Encuestas
        FOREIGN KEY (codigo_encuesta) 
        REFERENCES LOS_LINDOS.Encuestas(codigo)
);
GO

select * from gd_esquema.Maestra;

/*
migracion de datos
usando SP en UNA sola transaccion
*/


SELECT Alumno_Legajo, Alumno_Nombre, Alumno_Apellido, Alumno_Dni, Alumno_FechaNacimiento, Alumno_Mail, Alumno_Telefono, Alumno_Provincia, Alumno_Localidad,Alumno_Direccion FROM gd_esquema.Maestra;


SELECT Alumno_Legajo, count(distinct Alumno_Nombre) ,count( distinct Alumno_Apellido) ,count( distinct Alumno_Dni) , count( distinct Alumno_FechaNacimiento), count( distinct Alumno_Mail), count( distinct Alumno_Telefono) , count( distinct Alumno_Provincia) , count( distinct Alumno_Localidad) , count( distinct Alumno_Direccion) FROM gd_esquema.Maestra group by Alumno_Legajo;


SELECT distinct Profesor_nombre, Profesor_Apellido, Profesor_Dni, Profesor_FechaNacimiento,Profesor_Mail,Profesor_Telefono, Profesor_Provincia, Profesor_Localidad, Profesor_Direccion FROM gd_esquema.Maestra;



SELECT Factura_Numero, Factura_FechaEmision, Factura_FechaVencimiento, Factura_Total, Detalle_Factura_Importe, Periodo_Anio, Periodo_Mes, Pago_Fecha, Pago_Importe, Pago_MedioPago from gd_esquema.Maestra;



SELECT DISTINCT Factura_Numero, count (DISTINCT COALESCE(Detalle_Factura_Importe, -1) ) FROM gd_esquema.Maestra group by Factura_Numero;
SELECT DISTINCT Factura_Numero, count (DISTINCT Detalle_Factura_Importe ) FROM gd_esquema.Maestra group by Factura_Numero

SELECT * FROM gd_esquema.Maestra where Detalle_Factura_Importe is not null and Alumno_Legajo is null;
SELECT * FROM gd_esquema.Maestra where Detalle_Factura_Importe is not null and Curso_Codigo is null;

SELECT Factura_Numero, Factura_FechaEmision, Factura_FechaVencimiento, Factura_Total, Detalle_Factura_Importe, Periodo_Anio, Periodo_Mes, Pago_Fecha, Pago_Importe, Pago_MedioPago  FROM gd_esquema.Maestra where Detalle_Factura_Importe is not null and Factura_Numero is null;

SELECT DISTINCT Factura_Numero, Factura_FechaEmision, Factura_FechaVencimiento, Factura_Total, Detalle_Factura_Importe, Periodo_Anio, Periodo_Mes, Pago_Fecha, Pago_Importe, Pago_MedioPago  FROM gd_esquema.Maestra where Factura_Numero is not null and Detalle_Factura_Importe is null;
	
SELECT DISTINCT Factura_Numero,Factura_Total, Detalle_Factura_Importe FROM gd_esquema.Maestra where Factura_Total != Detalle_Factura_Importe;

SELECT DISTINCT Factura_Numero,Factura_Total, Detalle_Factura_Importe FROM gd_esquema.Maestra where Curso_PrecioMensual != Factura_Total;
SELECT DISTINCT Factura_Numero,Factura_Total, Detalle_Factura_Importe FROM gd_esquema.Maestra where Curso_PrecioMensual != Detalle_Factura_Importe;




SELECT 
	Factura_Numero, 
	Factura_FechaEmision, 
	Factura_FechaVencimiento, 
	Factura_Total, 
	Detalle_Factura_Importe,
	Periodo_Anio, 
	Periodo_Mes, 
	Pago_Fecha, 
	Pago_Importe, 
	Pago_MedioPago  
FROM gd_esquema.Maestra;


/*
hay filas que se encargan de asociar a las columnas con los detalles

hay filas que se encargan de asociar a facturas con los pagos

si hay filas de facturas SIN DETALLES, es porque son filas que indican pagos

*/


-- para migrar curso x alumno
select Alumno_Legajo, count(distinct Curso_Codigo) from gd_esquema.Maestra group by Alumno_Legajo;

select distinct Alumno_Legajo, Curso_Codigo from gd_esquema.Maestra where Alumno_Legajo is not null and Curso_Codigo is not null


select Curso_Codigo,count(distinct Curso_Dia) from gd_esquema.Maestra group by Curso_Codigo;


-- TRABAJO PRACTICO

SELECT Trabajo_Practico_Nota, Trabajo_Practico_FechaEvaluacion from gd_esquema.Maestra where Trabajo_Practico_Nota is not null and Trabajo_Practico_FechaEvaluacion is null;
SELECT Trabajo_Practico_Nota, Trabajo_Practico_FechaEvaluacion from gd_esquema.Maestra where Trabajo_Practico_Nota is null and Trabajo_Practico_FechaEvaluacion is not null;

SELECT Trabajo_Practico_Nota, Trabajo_Practico_FechaEvaluacion from gd_esquema.Maestra where Trabajo_Practico_Nota is not null and Trabajo_Practico_FechaEvaluacion is not null and  (Curso_Codigo is null or Alumno_Legajo is null);
 
-- FINAL

SELECT DISTINCT Curso_Codigo, Examen_Final_Fecha, Examen_Final_Hora, Examen_Final_Descripcion from gd_esquema.Maestra where Examen_Final_Fecha is not null and Examen_Final_Hora is not null and Examen_Final_Descripcion IS NOT NULL
 
 --Encuesta

SELECT DISTINCT Curso_Codigo, Encuesta_FechaRegistro from gd_esquema.Maestra where Encuesta_FechaRegistro is not null
SELECT DISTINCT Curso_Codigo , count (distinct Encuesta_FechaRegistro) from gd_esquema.Maestra group by Curso_Codigo
SELECT DISTINCT Curso_Codigo , Encuesta_FechaRegistro, Encuesta_Observacion from gd_esquema.Maestra where Curso_Codigo is null and Encuesta_FechaRegistro is not null
SELECT DISTINCT Curso_Codigo , Encuesta_FechaRegistro, Encuesta_Observacion from gd_esquema.Maestra where Curso_Codigo is not null and Encuesta_FechaRegistro is null

--Detalle factura

select Curso_Codigo, Factura_Numero, Detalle_Factura_Importe from gd_esquema.Maestra where Detalle_Factura_Importe IS NOT NULL

select  Curso_Codigo, count (distinct Factura_Numero) ,count ( distinct Detalle_Factura_Importe) from gd_esquema.Maestra group by Curso_Codigo

--PAGO

select Factura_numero, Pago_Importe from gd_esquema.Maestra where Pago_Importe is not null;

select Pago_Importe,Pago_Fecha,Pago_MedioPago from gd_esquema.Maestra 

--PARCIAL y modulo

select Modulo_Nombre,Modulo_Descripcion,count(distinct Curso_Codigo) from gd_esquema.Maestra group by Modulo_Nombre, Modulo_Descripcion;

select distinct Modulo_Nombre,Modulo_Descripcion,Curso_Codigo from gd_esquema.Maestra;

select Modulo_Nombre,Modulo_Descripcion,Curso_Codigo from gd_esquema.Maestra where  Modulo_Nombre is not null and Modulo_Descripcion is not null and Curso_Codigo is null; ---BIEN DA NULL


SELECT Evaluacion_Curso_fechaEvaluacion, Curso_Codigo from gd_esquema.Maestra where Curso_Codigo is null and Evaluacion_Curso_fechaEvaluacion IS NOT NULL

-- Inscripcion de final

select * from gd_esquema.Maestra where Curso_Codigo is null and Inscripcion_Final_Nro is not null   

--pARCIAL DE ALUMNO

 select DISTINCT
		m.Curso_Codigo,
		m.Alumno_Legajo, 
        m.Evaluacion_Curso_Nota, 
        m.Evaluacion_Curso_Presente, 
		m.Evaluacion_Curso_Instancia,
		m.Evaluacion_Curso_fechaEvaluacion
		from gd_esquema.Maestra M
		where Curso_Codigo is not null and Evaluacion_Curso_fechaEvaluacion is not null

-- respuestas

SELECT DISTINCT
            m.Curso_Codigo,
            m.Encuesta_FechaRegistro,
            m.Encuesta_Observacion,
            m.Encuesta_Nota1 
        FROM gd_esquema.Maestra m
	
SELECT DISTINCT
        m.Alumno_Legajo,
        m.Evaluacion_Final_Presente,
        m.Evaluacion_Final_Nota,
        m.Examen_Final_Hora,
        m.Examen_Final_Fecha,
		m.Examen_Final_Descripcion
    FROM gd_esquema.Maestra m
	where Evaluacion_Final_Presente is not null 
    
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
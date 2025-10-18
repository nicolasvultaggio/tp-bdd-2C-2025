SELECT Alumno_Legajo, Alumno_Nombre, Alumno_Apellido, Alumno_Dni, Alumno_FechaNacimiento, Alumno_Mail, Alumno_Telefono, Alumno_Provincia, Alumno_Localidad,Alumno_Direccion FROM gd_esquema.Maestra;


SELECT Alumno_Legajo, count(distinct Alumno_Nombre) ,count( distinct Alumno_Apellido) ,count( distinct Alumno_Dni) , count( distinct Alumno_FechaNacimiento), count( distinct Alumno_Mail), count( distinct Alumno_Telefono) , count( distinct Alumno_Provincia) , count( distinct Alumno_Localidad) , count( distinct Alumno_Direccion) FROM gd_esquema.Maestra group by Alumno_Legajo;


SELECT distinct Profesor_nombre, Profesor_Apellido, Profesor_Dni, Profesor_FechaNacimiento,Profesor_Mail,Profesor_Telefono, Profesor_Provincia, Profesor_Localidad, Profesor_Direccion FROM gd_esquema.Maestra;



SELECT Factura_Numero, Factura_FechaEmision, Factura_FechaVencimiento, Factura_Total, Detalle_Factura_Importe, Periodo_Anio, Periodo_Mes, Pago_Fecha, Pago_Importe, Pago_MedioPago from gd_esquema.Maestra;



SELECT DISTINCT Factura_Numero, count (distinct Detalle_Factura_Importe) FROM gd_esquema.Maestra group by Factura_Numero;

SELECT * FROM gd_esquema.Maestra where Detalle_Factura_Importe is not null and Alumno_Legajo is null;
SELECT * FROM gd_esquema.Maestra where Detalle_Factura_Importe is not null and Curso_Codigo is null;

SELECT * FROM gd_esquema.Maestra where Detalle_Factura_Importe is not null and Factura_Numero is null;
SELECT * FROM gd_esquema.Maestra where Factura_Numero is not null and Detalle_Factura_Importe is null;
	--> esto puede ser en caso de que el detalle factura se emite solo si el alumno está en varios cursos

SELECT DISTINCT Factura_Numero,Factura_Total, Detalle_Factura_Importe FROM gd_esquema.Maestra where Factura_Total != Detalle_Factura_Importe;

SELECT DISTINCT Factura_Numero,Factura_Total, Detalle_Factura_Importe FROM gd_esquema.Maestra where Curso_PrecioMensual != Factura_Total;
SELECT DISTINCT Factura_Numero,Factura_Total, Detalle_Factura_Importe FROM gd_esquema.Maestra where Curso_PrecioMensual != Detalle_Factura_Importe;

--relacionadas: 
	-- numero de factura, fecha emision, fecha vencimiento y factura total 
	-- detalle factura importe, año y mes -->  ES EL PAGO DE UN CURSO POR UN ALUMNO EN UN MES Y AÑO DETERMINADOS
	-- fecha de pago, fecha de importe, medio de pago

/*
CUÁL ES LA RELACION ENTRE FACTURA Y DETALLE_FACTURA ?

CUANDO EL ALUMNO ESTÁ ANOTADO A UN SOLO CURSO, no se le genera un detalle_factura_importe, ya que la factura es lógicamente, sobre un solo curso.

CUANDO EL ALUMNO ESTÁ ANOTADO EN VARIOS CURSOS, se le genera UN SOLO detalle_factura_importe que, tiene siempre el total de lo que le cobraron todos los cursos, y lo asocia a UNO de los cursos.


*/
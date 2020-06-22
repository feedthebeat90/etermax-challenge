PROMPT lvn218

-- Comments start with -- or are between /* and */

-- Clean up previously created tables; ignore error saying that the table does not exist

DROP TABLE TableA;
DROP TABLE TableB;
DROP TABLE RespuestaB;
DROP TABLE TableC;
DROP TABLE RespuestaC;

-- Problema a)

/*

a- Generar una tabla, con el listado de todos los Movimientos, con el siguiente contenido :
. Fecha
. Descripción de Cliente
. Descripción de Proveedor
. Descripción de Producto
. Descripcion de Marca
. Cantidad
. Costo
. Venta
. Ganancia Neta

*/

-- Uso lowercase para los fields basandome en el diagrama
-- Data_Proveeedores en "Esquema de Tablas" tiene un error de tipeo

CREATE TABLE TableA
AS SELECT fecha, Data_Clientes.descripcion as cliente, Data_Proveedores.descripcion, 
				 Data_Productos.descripcion, Data_Marcas.descripcion, 
		  		 cantidad, costo, venta, venta - costo AS ganancia_neta
FROM Data_Movimientos, Data_Clientes, Data_Proveedores, Data_Productos, Data_Marcas
WHERE Data_Movimientos.cod_cliente = Data_Clientes.cod_cliente AND
	  Data_Movimientos.cod_prod = Data_Productos.cod_prod AND
	  Data_Proveedores.cod_proveedor = Data_Productos.cod_proveedor = AND
	  Data_Marcas.cod_marca = Data_Productos.cod_marca;


-- Problema b)

/*

b- Mostrar un listado de todas las Marcas que no tuvieron Ventas.

Idea general: 

	i) Generar un listado con todos los 'cod_marca' que tienen ventas registradas
	   Nota: voy a excluir ventas cuyo field 'venta' sea NULL (en caso de que existiesen)
	ii) Sustraer dicho listado de un listado completo que incluye todos los 'cod_marca' 

*/

-- Encontramos todas las marcas que registraron movimientos/ventas (no nulas)
CREATE TABLE TableB
AS SELECT DISTINCT Data_Marcas.cod_marca AS marcaID
FROM Data_Movimientos, Data_Productos, Data_Marcas
WHERE Data_Movimientos.cod_prod = Data_Productos.cod_prod AND
	  Data_Marcas.cod_marca = Data_Productos.cod_marca AND
	  venta IS NOT NULL;

-- Podemos usar operador EXCEPT o MINUS
CREATE TABLE RespuestaB
AS (SELECT cod_marca AS marcaID FROM Data_Marcas)
EXCEPT
(SELECT marcaID FROM TableB);

-- Para mostrar todos los 'cod_marca' sin ventas registradas 
SELECT * FROM RespuestaB;

-- De requerir tambien descripcion 
SELECT * FROM Data_Marcas
WHERE cod_marca IN (SELECT * FROM RespuestaB)

-- Problema c)

/*

En base a la tabla generada en a, consultar, 
ordenando por fecha y descripción del cliente:

. Fecha
. Descripción de Cliente
. Ganancia Neta Acumulada en las últimas 7 operaciones

La idea del punto c es, dado un cliente y una fecha de operación, mostrar la sumatoria de las
ganancias derivadas de las últimas siete operaciones que haya realizado.

*/

CREATE TABLE TableC
AS SELECT cliente, fecha, 
			SUM(ganancia_neta) 
				OVER(PARTITION BY cliente ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ganancia_neta_acumulada
FROM TableA
ORDER BY cliente, fecha;

SELECT * FROM TableC;

-- Alternativa eligiendo siempre el 'last_value' de la fecha en cuestion
-- OJO! No asegura sumar los ultimos 7 porque el orden no esta garantizado 
CREATE TABLE RespuestaC
AS SELECT DISTINCT cliente, fecha, LAST_VALUE(ganancia_neta_acumulada) OVER(PARTITION BY cliente, fecha) as gna
FROM (SELECT cliente, fecha, ganancia_neta, 
		SUM(ganancia_neta) OVER(PARTITION BY cliente ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ganancia_neta_acumulada
		FROM TableA
		ORDER BY cliente, fecha) auxTable
ORDER BY cliente, fecha;

SELECT * FROM RespuestaC;





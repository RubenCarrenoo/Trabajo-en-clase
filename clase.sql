-- funcion simple 
-- A = PI x R2
CREATE DATABASE funciones;
USE funciones;

DELIMITER //
CREATE FUNCTION calcular_area (radio DOUBLE)
RETURNS DOUBLE 
DETERMINISTIC
BEGIN
	DECLARE area DOUBLE;
    SET area = PI() * radio*radio;
    RETURN area;

END //
DELIMITER ;

SELECT calcular_area(3);

-- funcion para clasificar una pelicula
DELIMITER //
CREATE FUNCTION clasificar_pelicula (edad INT)
RETURNS VARCHAR(60)
DETERMINISTIC
BEGIN
	IF edad < 14 THEN
		RETURN "pelicula para niños";
	ELSEIF edad >= 18 THEN
		RETURN "Pelicula para adultos";
	ELSEIF edad < 18 THEN
		RETURN "Pelicula para adolescentes";
	END IF;
END //
DELIMITER ;

USE funciones;

SELECT clasificar_pelicula(13);
SELECT clasificar_pelicula(14);
SELECT clasificar_pelicula(15);
SELECT clasificar_pelicula(16);
SELECT clasificar_pelicula(17);
SELECT clasificar_pelicula(18);
SELECT clasificar_pelicula(20);
SELECT clasificar_pelicula(5);

-- funcion para la hora actual

DELIMITER //
CREATE FUNCTION hora_actual()
RETURNS VARCHAR(100)
NOT DETERMINISTIC
NO SQL
BEGIN
	RETURN CONCAT("la hora actual es: ", CURRENT_TIME());
END//
DELIMITER ;

SELECT hora_actual();

-- Con tablas
CREATE TABLE transacciones (
id INT AUTO_INCREMENT,
monto DECIMAL(10,2),
tasa DECIMAL(10,2),
PRIMARY KEY (id)
);

-- Datos de ejemplo (el documento no los incluye)
-- Ojo: incluyo un caso con tasa = 0 a propósito para probar el manejo de errores
INSERT INTO transacciones (monto, tasa)
VALUES (1000.00, 4), (500.00, 2), (300.00, 0);

USE transacciones;
-- Division entre 2 numeros
DELIMITER //
CREATE FUNCTION dividir_numeros(dividendo DECIMAL(10,2),divisor DECIMAL(10,2))
RETURNS DECIMAL (10,2)
DETERMINISTIC
BEGIN
	IF divisor = 0 THEN
		SIGNAL SQLSTATE "45000"
        SET MESSAGE_TEXT = "division por 0 no es posible";
	END IF;
    RETURN dividendo/divisor;
END//
DELIMITER ;

SELECT id, dividir_numeros(monto,tasa) AS resultado_division FROM transacciones;

-- funcion para calcular el iva de un producto
DELIMITER //
CREATE FUNCTION calcular_iva(precio DECIMAL(10,2))
RETURNS DECIMAL (10,2)
DETERMINISTIC
BEGIN
	DECLARE iva DECIMAL(10,2);
	SET iva = precio * 0.19;

	RETURN precio+iva;
    
END//
DELIMITER ;

SELECT calcular_iva(10000)


-- funcion para convertir de celsius a Farenheit
DROP FUNCTION convertir_farenheit;
DELIMITER //
CREATE FUNCTION convertir_farenheit(celsius DECIMAL(10,1))
RETURNS DECIMAL (10,1)
DETERMINISTIC
BEGIN
	DECLARE farenheit DECIMAL(10,1);
	SET farenheit = (celsius * 9/5) + 32;

	RETURN farenheit;
    
END//
DELIMITER ;

SELECT convertir_farenheit(30)


-- Funcion para calcular el descuento de un producto segun categoria, por ejemplo cuando es estandar, vip, palco
DELIMITER //
CREATE FUNCTION calcular_descuento(precio DECIMAL(10,2), categoria VARCHAR(20))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    IF categoria = 'Estandar' THEN
        RETURN precio * 0.95;
    ELSEIF categoria = 'VIP' THEN
        RETURN precio * 0.90;
    ELSEIF categoria = 'Palco' THEN
        RETURN precio * 0.80;
    ELSE
        RETURN precio;
    END IF;
END //
DELIMITER ;

SELECT calcular_descuento(100000, 'VIP');

-- Funcion para calcular el promedio de ventas de un vendedor en especifico (crear las tablas necesarias)
CREATE TABLE vendedores (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_vendedor INT NOT NULL,
    fecha DATE,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor)
);

-- Vendedores
INSERT INTO vendedores (nombre) VALUES
('Juan Pérez'),
('María Gómez'),
('Carlos Rodríguez'),
('Laura Martínez'),
('Andrés Torres');

-- Ventas
INSERT INTO ventas (id_vendedor, fecha, total) VALUES
(1, '2026-08-01', 250000.00),
(1, '2026-08-02', 180000.00),
(1, '2026-08-03', 320000.00),

(2, '2026-08-01', 450000.00),
(2, '2026-08-04', 380000.00),
(2, '2026-08-05', 410000.00),

(3, '2026-08-02', 150000.00),
(3, '2026-08-03', 210000.00),
(3, '2026-08-06', 195000.00),

(4, '2026-08-01', 520000.00),
(4, '2026-08-03', 610000.00),
(4, '2026-08-05', 490000.00),

(5, '2026-08-02', 300000.00),
(5, '2026-08-04', 280000.00),
(5, '2026-08-06', 350000.00);

DELIMITER //
CREATE FUNCTION calcular_ventas(idVend INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(10,2);
    
	SELECT AVG(total)
    INTO promedio
    FROM ventas
    WHERE id_vendedor = idVend;
    
    RETURN promedio;
END //
DELIMITER ;

SELECT calcular_ventas(2);


-- Funcion para darle la bienvenida a un cliente segun tablas
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

INSERT INTO clientes (nombre) VALUES
('Juan Pérez'),
('María Gómez'),
('Carlos Rodríguez'),
('Laura Martínez'),
('Andrés Torres'),
('Sofía Ramírez'),
('Camila Hernández'),
('Daniel López'),
('Valentina Castro'),
('Miguel Sánchez');

DELIMITER //
CREATE FUNCTION mensaje_bienvenida(nombre VARCHAR(50))
RETURNS VARCHAR(70)
DETERMINISTIC
BEGIN
    RETURN CONCAT("Hola", nombre, " bienvenido a la empresa");
    
END //
DELIMITER ;

SELECT mensaje_bienvenida('Juan Pérez');



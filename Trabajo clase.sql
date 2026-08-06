CREATE DATABASE IF NOT EXISTS bd_funciones
  CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;

USE bd_funciones;

-- ===================== TABLAS =====================
CREATE TABLE IF NOT EXISTS vendedores (
  id_vendedor INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS ventas (
  id_venta INT PRIMARY KEY AUTO_INCREMENT,
  id_vendedor INT,
  monto DECIMAL(10,2) NOT NULL,
  fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS clientes (
  id_cliente INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  nivel VARCHAR(20) DEFAULT 'nuevo'
);

CREATE TABLE IF NOT EXISTS paises (
  id_pais INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS ciudades (
  id_ciudad INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  id_pais INT,
  poblacion INT NOT NULL DEFAULT 0,
  FOREIGN KEY (id_pais) REFERENCES paises(id_pais) ON DELETE CASCADE
);

-- ============ DATOS (re-ejecutable, no duplica) ============
INSERT INTO vendedores (nombre, apellido)
SELECT * FROM (
  SELECT 'Juan','Pérez' UNION ALL SELECT 'María','González' UNION ALL SELECT 'Carlos','Ramírez'
) t WHERE NOT EXISTS (SELECT 1 FROM vendedores);

INSERT INTO ventas (id_vendedor, monto)
SELECT * FROM (
  SELECT 1,1500.00 UNION ALL SELECT 1,2300.00 UNION ALL SELECT 1,1800.00
  UNION ALL SELECT 2,3200.00 UNION ALL SELECT 2,2800.00 UNION ALL SELECT 3,4500.00
) t WHERE NOT EXISTS (SELECT 1 FROM ventas);

INSERT INTO clientes (nombre, nivel)
SELECT * FROM (
  SELECT 'Ana López','nuevo' UNION ALL SELECT 'Roberto Silva','regular'
  UNION ALL SELECT 'Laura Martínez','frecuente' UNION ALL SELECT 'Pedro Sánchez','premium'
) t WHERE NOT EXISTS (SELECT 1 FROM clientes);

INSERT INTO paises (nombre)
SELECT * FROM (
  SELECT 'México' UNION ALL SELECT 'Colombia'
  UNION ALL SELECT 'Argentina' UNION ALL SELECT 'España'
) t WHERE NOT EXISTS (SELECT 1 FROM paises);

INSERT INTO ciudades (nombre, id_pais, poblacion)
SELECT * FROM (
  SELECT 'Ciudad de México',1,9200000 UNION ALL SELECT 'Guadalajara',1,1400000
  UNION ALL SELECT 'Monterrey',1,1100000 UNION ALL SELECT 'Bogotá',2,7900000
  UNION ALL SELECT 'Medellín',2,2500000 UNION ALL SELECT 'Buenos Aires',3,3000000
  UNION ALL SELECT 'Madrid',4,3300000 UNION ALL SELECT 'Barcelona',4,1600000
) t WHERE NOT EXISTS (SELECT 1 FROM ciudades);

-- ============ LIMPIA VERSIONES ANTERIORES ============
DROP FUNCTION IF EXISTS calcular_iva;
DROP FUNCTION IF EXISTS celsius_a_fahrenheit;
DROP FUNCTION IF EXISTS calcular_descuento;
DROP FUNCTION IF EXISTS promedio_ventas_vendedor;
DROP FUNCTION IF EXISTS bienvenida_cliente;
DROP FUNCTION IF EXISTS poblacion_pais;
DROP FUNCTION IF EXISTS info_ciudades_hora;
DROP FUNCTION IF EXISTS dividir_numeros;

-- ========= FUNCIONES SIMPLES (un solo RETURN) =========
CREATE FUNCTION calcular_iva(precio DECIMAL(10,2))
RETURNS DECIMAL(10,2) DETERMINISTIC
RETURN precio * 0.16;

CREATE FUNCTION celsius_a_fahrenheit(celsius DECIMAL(6,2))
RETURNS DECIMAL(6,2) DETERMINISTIC
RETURN (celsius * 9 / 5) + 32;

CREATE FUNCTION promedio_ventas_vendedor(p_id INT)
RETURNS DECIMAL(10,2) READS SQL DATA
RETURN IFNULL((SELECT AVG(monto) FROM ventas WHERE id_vendedor = p_id), 0);

CREATE FUNCTION bienvenida_cliente(p_id INT)
RETURNS VARCHAR(255) READS SQL DATA
RETURN CONCAT('¡Hola ',
  IFNULL((SELECT nombre FROM clientes WHERE id_cliente = p_id), 'cliente no encontrado'), '! ',
  CASE (SELECT nivel FROM clientes WHERE id_cliente = p_id)
    WHEN 'nuevo'     THEN '¡Bienvenido(a)! Gracias por elegirnos.'
    WHEN 'regular'   THEN 'Gracias por seguir con nosotros.'
    WHEN 'frecuente' THEN '¡Qué gusto verte de nuevo!'
    WHEN 'premium'   THEN 'Tienes beneficios exclusivos.'
    ELSE ''
  END);

CREATE FUNCTION poblacion_pais(p_pais VARCHAR(100))
RETURNS INT READS SQL DATA
RETURN IFNULL((SELECT SUM(c.poblacion) FROM ciudades c
               JOIN paises p ON c.id_pais = p.id_pais
               WHERE p.nombre = p_pais), 0);

CREATE FUNCTION info_ciudades_hora()
RETURNS VARCHAR(255) READS SQL DATA
RETURN CONCAT('Hay ', (SELECT COUNT(*) FROM ciudades),
              ' ciudades. Hora actual: ', CURTIME());

-- ===== FUNCIONES CON BEGIN...END (con excepciones) =====
CREATE FUNCTION calcular_descuento(precio DECIMAL(10,2), categoria VARCHAR(20))
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE porcentaje DECIMAL(3,2);
    CASE categoria
        WHEN 'estandar' THEN SET porcentaje = 0.00;
        WHEN 'vip'      THEN SET porcentaje = 0.15;
        WHEN 'palco'    THEN SET porcentaje = 0.30;
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Categoría no válida (estandar, vip, palco)';
    END CASE;
    RETURN precio * porcentaje;
END;

CREATE FUNCTION dividir_numeros(dividendo DECIMAL(10,2), divisor DECIMAL(10,2))
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    IF divisor = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'División por cero NO permitida en este universo';
    END IF;
    RETURN dividendo / divisor;
END;

-- ===================== PRUEBAS =====================
SELECT calcular_iva(100.00) AS iva;                       -- 16.00
SELECT celsius_a_fahrenheit(25) AS fahrenheit;            -- 77.00
SELECT calcular_descuento(1000.00,'vip') AS desc_vip;     -- 150.00
SELECT calcular_descuento(1000.00,'palco') AS desc_palco; -- 300.00
SELECT promedio_ventas_vendedor(1) AS promedio_v1;        -- 1866.67
SELECT bienvenida_cliente(1) AS bienvenida_nuevo;
SELECT bienvenida_cliente(4) AS bienvenida_premium;
SELECT poblacion_pais('México') AS poblacion_mexico;      -- 11700000
SELECT info_ciudades_hora() AS info;
SELECT dividir_numeros(100,4) AS division_ok;             -- 25.00

DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral;
USE austral;
-- Tablas sin dependencias (autores, colecciones)
CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT,
    nombre   VARCHAR(80) NOT NULL,
    pais     VARCHAR(60),
    genero   ENUM('Cómic', 'Ensayo', 'Infantil', 'Novela', 'Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);
CREATE TABLE colecciones (
    id_coleccion      INT AUTO_INCREMENT,
    titulo            VARCHAR(120) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    PRIMARY KEY (id_coleccion)
);
CREATE TABLE libros (
    id_libro            INT AUTO_INCREMENT,
    id_autor            INT NOT NULL,
    id_coleccion        INT,
    titulo              VARCHAR(120) NOT NULL,
    paginas             INT,
    ejemplares_vendidos INT,
    anio                INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
);
CREATE TABLE pagos (
    id_pago    INT AUTO_INCREMENT,
    id_autor   INT NOT NULL,
    fecha_pago DATE NOT NULL,
    monto      DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);
-- =====================================================================
-- Elena=1, Harold=2, Rodrigo=3, Valentina=4, Nora=5, Kenji=6
-- =====================================================================
INSERT INTO autores (nombre, pais, genero) VALUES
    ('Elena Pizarro',     'Chile',          'Novela'),
    ('Harold Finch',      'Inglaterra',     'Ensayo'),
    ('Rodrigo Bahamonde', 'Chile',          'Poesía'),
    ('Valentina Correa',  'Argentina',      'Infantil'),
    ('Nora Keller',       'Estados Unidos', 'Novela'),
    ('Kenji Arakawa',     NULL,             'Cómic');

-- id_coleccion se omite: queda en NULL.
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
    (1, 'Cielo de Enero',      210, 1500, 2024),
    (1, 'Marea Baja',          185,  800, 2023),
    (1, 'El Norte',            200, 2200, 2024),
    (2, 'Estrellas que Caen',  240, 3000, 2022),
    (2, 'Máquinas',            215,  450, 2024),
    (3, 'Luz Artificial',      300, 1200, 2024),
    (3, 'Ruido Blanco',        280,  600, 2023),
    (4, 'El Barrio de Lila',   190, 5000, 2024),
    (4, 'Antes del Amanecer',  205, 2700, 2024),
    (4, 'La Calle 8',          175,  900, 2023),
    (5, 'Flor de Hierro',      195, 4100, 2024),
    (5, 'Hora Dorada',         220, 1800, 2022);


-- =====================================================================
-- ENTREGABLE 2: CONSULTAS
-- Las consultas 1 a 6 se ejecutan sobre la carga oficial, ANTES de 7 y 8.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Consulta 1: autores cuyo país no es Chile, incluyendo al que no tiene país
-- Explicación: pais <> 'Chile' devuelve NULL cuando pais es NULL,
-- porque comparar con un valor desconocido da desconocido, y WHERE solo deja
-- pasar las filas TRUE, por eso se agrega OR pais IS NULL para incluir a Kenji.
-- ---------------------------------------------------------------------
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;
-- ---------------------------------------------------------------------
-- Consulta 2: libros con entre 190 y 220 páginas (ambos incluidos), de menor a mayor
-- ---------------------------------------------------------------------
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas;
-- ---------------------------------------------------------------------
-- Consulta 3: una sola fila con las cinco métricas del catálogo
-- ---------------------------------------------------------------------
SELECT COUNT(*)                 AS total_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares,
       AVG(paginas)             AS promedio_paginas,
       MIN(anio)                AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS max_ejemplares
FROM libros;
-- ---------------------------------------------------------------------
-- Consulta 4: géneros distintos de los autores, en orden alfabético
-- ---------------------------------------------------------------------
SELECT DISTINCT genero
FROM autores
ORDER BY genero;
-- ---------------------------------------------------------------------
-- Consulta 5: autores con más de un libro publicado en 2024, y cuántos son
-- ---------------------------------------------------------------------
SELECT a.nombre, COUNT(*) AS libros_2024
FROM autores a
JOIN libros l ON a.id_autor = l.id_autor
WHERE l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre;
-- ---------------------------------------------------------------------
-- Consulta 6: libros de 2024 con más de 2000 ejemplares, de mayor a menor, solo 3
-- ---------------------------------------------------------------------
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;
-- ---------------------------------------------------------------------
-- Consulta 7: insertar 'Papel Mojado' y eliminarlo con DELETE filtrado por título
-- ---------------------------------------------------------------------
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);
SELECT * FROM libros WHERE titulo = 'Papel Mojado';
DELETE FROM libros WHERE titulo = 'Papel Mojado';
SELECT * FROM libros WHERE titulo = 'Papel Mojado';
-- ---------------------------------------------------------------------
-- Consulta 8: sumar 100 ejemplares a 'Cielo de Enero' (valor nuevo calculado desde el actual)
-- ---------------------------------------------------------------------
SELECT titulo, ejemplares_vendidos FROM libros WHERE titulo = 'Cielo de Enero';
UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';
SELECT titulo, ejemplares_vendidos FROM libros WHERE titulo = 'Cielo de Enero';
-- --------------------------------------------------------------------
-- Consulta 9: libro, colección y fecha de publicación de la colección
-- ---------------------------------------------------------------------
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
    ('Colección Voces del Sur',    '2024-03-15'),
    ('Colección Ideas y Palabras', '2024-09-01');
UPDATE libros SET id_coleccion = 1 WHERE id_libro BETWEEN 1 AND 6;
UPDATE libros SET id_coleccion = 2 WHERE id_libro BETWEEN 7 AND 12;
SELECT l.titulo AS libro,
       c.titulo AS coleccion,
       c.fecha_publicacion
FROM libros l
JOIN colecciones c ON l.id_coleccion = c.id_coleccion
ORDER BY l.id_libro;
-- ---------------------------------------------------------------------
-- Consulta 10 (dos sentencias): pagos con nombre del autor, y total pagado por autor
-- ---------------------------------------------------------------------
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
    (1, '2025-01-15', 450000.00),
    (1, '2025-03-15', 380000.50),
    (2, '2025-02-10', 520000.00),
    (4, '2025-02-28', 610000.75);
-- 10a) Lista de pagos
SELECT a.nombre, p.fecha_pago, p.monto
FROM pagos p
JOIN autores a ON p.id_autor = a.id_autor
ORDER BY a.nombre, p.fecha_pago;
-- 10b) Total pagado a cada autor
SELECT a.nombre, SUM(p.monto) AS total_pagado
FROM autores a
JOIN pagos p ON a.id_autor = p.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY a.nombre;

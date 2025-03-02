CREATE DATABASE CAFETERIA;
USE CAFETERIA;

CREATE TABLE CLIENTES (
    IDCliente INT PRIMARY KEY,
    NombreCliente VARCHAR(100) NOT NULL,
    CorreoElectronico VARCHAR(100),
    DNI INT(8)
);

CREATE TABLE PRODUCTOS (
    IDProducto INT (10) PRIMARY KEY,
    NombreProducto VARCHAR(100) NOT NULL,
    Categoria VARCHAR(50),
    Precio DECIMAL(10, 2),
    Proveedor VARCHAR(50)
);

CREATE TABLE PROVEEDORES (
    CUIT INT PRIMARY KEY,
    NombreProveedor VARCHAR(100) NOT NULL,
    IDProducto INT(10),
    FOREIGN KEY (IDProducto) REFERENCES PRODUCTOS(IDProducto) 
);

CREATE TABLE VENTAS (
    TicketDeVenta INT PRIMARY KEY,
	IDProducto INT(10) NOT NULL,
    IDCliente INT NOT NULL,
    FechaVenta DATE NOT NULL,
    Unidades INT (10),
    Monto DECIMAL(10, 2),
    FOREIGN KEY (IDProducto) REFERENCES PRODUCTOS(IDProducto),
    FOREIGN KEY (IDCliente) REFERENCES CLIENTES(IDCliente)
);

INSERT INTO Clientes (ID_cliente, nombre_cliente, correo_cliente, DNI) VALUES
(1, 'Marcos Lopez', 'mlopez@hotmail.com', '38727586'),
(2, 'Soledad Castillo', 'soledad.19@gmail.com', '29707591'),
(3, 'Javier Ferrari', 'j.ferrari@gmail.com', '41707688'),
(4, 'Pablo Lavalle', 'pablol@yahoo.com', '31717566'),
(5, 'Daniela Perez', 'dperez.24@gmail.com', '40704588'),
(6, 'Laura Fernandez', 'lau.fer@hotmail.com', '29767182');

INSERT INTO Proveedores (CUIT, nombre_proveedor, ID_producto) VALUES
('23-48392641-7', 'La Panera Rosa', 111),
('21-54789139-6', 'Pani', 112),
('20-38571947-1', 'Havanna', 113),
('24-74620195-5', 'Starbucks', 114),
('20-37236491-8', 'Terrabusi', 115),
('22-40576812-9', 'Freddo', 116);

INSERT INTO Productos (ID_producto, nombre_producto, categoria, precio, nombre_proveedor) VALUES
(111, 'Desayuno Continental', 'Pack', 10000, 'La Panera Rosa'),
(112, 'Box Cumpleaños', 'Pack', 20000, 'Pani'),
(113, 'Alfajor', 'Bakery', 1000, 'Havanna'),
(114, 'Café Helado', 'Cafeteria', 2000, 'Starbucks'),
(115, 'Cookie', 'Bakery', 500, 'Terrabusi'),
(116, 'Frappe', 'Cafeteria', 50000, 'Freddo');

INSERT INTO Ventas (ticket_venta, ID_producto, ID_cliente, fecha_venta, unidades, monto) VALUES
(229, 111, 6, '2024-10-10', 3, 30000),
(230, 113, 2, '2024-10-12', 4, 4000),
(231, 116, 3, '2024-10-20', 1, 5000),
(232, 114, 1, '2024-10-21', 3, 6000),
(233, 112, 5, '2024-10-25', 1, 20000),
(234, 115, 4, '2024-10-27', 2, 1000);

CREATE VIEW resumen_ventas_cliente AS
SELECT 
    c.nombre_cliente, 
    SUM(v.monto) AS total_compras
FROM Ventas v
JOIN Clientes c ON v.ID_cliente = c.ID_cliente
GROUP BY c.ID_cliente;

CREATE FUNCTION total_ventas_producto(product_id INT) 
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(monto) INTO total 
    FROM Ventas
    WHERE ID_producto = product_id;
    RETURN total;
END;

DELIMITER //

CREATE PROCEDURE registrar_venta(
    IN ticket INT,
    IN id_producto INT,
    IN id_cliente INT,
    IN fecha DATE,
    IN unidades INT
)
BEGIN
    DECLARE monto DECIMAL(10, 2);
    SELECT precio INTO monto FROM Productos WHERE ID_producto = id_producto;
    SET monto = monto * unidades;
    INSERT INTO Ventas (ticket_venta, ID_producto, ID_cliente, fecha_venta, unidades, monto)
    VALUES (ticket, id_producto, id_cliente, fecha, unidades, monto);
    
END //

DELIMITER ;

CREATE TRIGGER actualizar_stock AFTER INSERT ON Ventas
FOR EACH ROW
BEGIN
    UPDATE Productos
    SET stock = stock - NEW.unidades
    WHERE ID_producto = NEW.ID_producto;
    
END;

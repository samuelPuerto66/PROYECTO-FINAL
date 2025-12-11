-- Insertar especialidades médicas
INSERT INTO specialty (name) VALUES
('Cardiología'),
('Odontología'),
('Pediatría'),
('Dermatología'),
('Medicina General');

-- Insertar pacientes
INSERT INTO patient (full_name, email, phone) VALUES
('Daniel Torres', 'daniel.torres@example.com', '3001234567'),
('María López', 'maria.lopez@example.com', '3109876543'),
('Juan Pérez', 'juan.perez@example.com', '3115551234'),
('Sofía Ramírez', 'sofia.ramirez@example.com', '3204567890'),
('Carlos Ruiz', 'carlos.ruiz@example.com', '3159876543'),
('Valentina Gómez', 'valentina.gomez@example.com', '3147894561'),
('Andrés Martínez', 'andres.martinez@example.com', '3006549873'),
('Camila Herrera', 'camila.herrera@example.com', '3174561237'),
('Luis Díaz', 'luis.diaz@example.com', '3127894560'),
('Laura Sánchez', 'laura.sanchez@example.com', '3019876543');

-- Insertar doctores
INSERT INTO doctor (full_name, specialty_id) VALUES
('Dr. Fernando Castillo', 1),
('Dr. Paula Medina', 2),
('Dr. Ricardo Gómez', 3),
('Dra. Natalia Torres', 4),
('Dr. Santiago Pérez', 5);

-- Insertar servicios (PRECIOS CORREGIDOS: sin comas)
INSERT INTO service (service_name, price) VALUES
('Consulta general', 35000),
('Electrocardiograma', 90000),
('Limpieza dental', 50000),
('Consulta pediátrica', 45000),
('Control dermatológico', 60000),
('Radiografía', 75000),
('Toma de signos vitales', 15000),
('Consulta odontológica', 70000),
('Exámenes de laboratorio', 80000),
('Terapia respiratoria', 55000);

-- Insertar citas médicas
INSERT INTO appointment (patient_id, doctor_id, service_id, appointment_date, status) VALUES
(1, 5, 1, '2025-01-15 09:00:00', 'REALIZADA'),
(2, 1, 2, '2025-01-16 10:30:00', 'PENDIENTE'),
(3, 2, 3, '2025-01-17 14:00:00', 'REALIZADA'),
(4, 3, 4, '2025-01-18 08:00:00', 'CANCELADA'),
(5, 4, 5, '2025-01-19 15:30:00', 'PENDIENTE'),
(6, 5, 1, '2025-01-20 11:00:00', 'REALIZADA'),
(7, 1, 6, '2025-01-21 09:20:00', 'REALIZADA'),
(8, 2, 7, '2025-01-22 13:40:00', 'PENDIENTE'),
(9, 3, 8, '2025-01-23 16:10:00', 'REALIZADA'),
(10, 4, 9, '2025-01-24 12:50:00', 'REALIZADA'),
(3, 1, 2, '2025-01-25 10:20:00', 'REALIZADA'),
(6, 3, 4, '2025-01-26 11:15:00', 'PENDIENTE'),
(7, 5, 1, '2025-01-27 09:10:00', 'REALIZADA'),
(9, 4, 5, '2025-01-28 08:30:00', 'CANCELADA'),
(2, 2, 3, '2025-01-29 14:50:00', 'REALIZADA');

-- Insertar pagos (MONTO CORREGIDO: sin comas)
INSERT INTO payment (appointment_id, amount, payment_method) VALUES
(1, 35000, 'Efectivo'),
(2, 90000, 'Tarjeta'),
(3, 50000, 'PSE'),
(6, 35000, 'Efectivo'),
(7, 75000, 'Tarjeta'),
(9, 70000, 'Efectivo'),
(10, 80000, 'PSE'),
(11, 90000, 'Tarjeta'),
(13, 35000, 'Efectivo'),
(15, 50000, 'PSE');

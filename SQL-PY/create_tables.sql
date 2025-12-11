-- Eliminar tablas si existen (evita errores al ejecutar varias veces)
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS appointment CASCADE;
DROP TABLE IF EXISTS service CASCADE;
DROP TABLE IF EXISTS doctor CASCADE;
DROP TABLE IF EXISTS patient CASCADE;
DROP TABLE IF EXISTS specialty CASCADE;

-- 1. Tabla de Especialidades Médicas
CREATE TABLE specialty (
    specialty_id INT PRIMARY KEY AUTO_INCREMENT, 
    name VARCHAR(100) NOT NULL
);

-- 2. Tabla de Pacientes
CREATE TABLE patient (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

-- 3. Tabla de Doctores
CREATE TABLE doctor (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    specialty_id INT NOT NULL, 
    FOREIGN KEY (specialty_id) REFERENCES specialty(specialty_id)
);

-- 4. Tabla de Servicios Médicos
CREATE TABLE service (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(150) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- 5. Tabla de Citas Médicas (Debe ir antes de payment)
CREATE TABLE appointment (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    service_id INT NOT NULL,
    appointment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'PENDIENTE',
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id)
);

-- 6. Tabla de Pagos (NUEVA)
CREATE TABLE payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT UNIQUE NOT NULL, -- UNIQUE para asegurar que una cita solo se pague una vez
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
);
----------------------------------------------------------
-- 1. INNER JOIN: Listar citas con paciente, doctor y servicio
----------------------------------------------------------
SELECT 
    a.appointment_id,
    p.full_name AS paciente,
    d.full_name AS doctor,
    s.service_name AS servicio,
    a.appointment_date,
    a.status
FROM appointment a
INNER JOIN patient p ON a.patient_id = p.patient_id
INNER JOIN doctor d ON a.doctor_id = d.doctor_id
INNER JOIN service s ON a.service_id = s.service_id;


----------------------------------------------------------
-- 2. LEFT JOIN: Mostrar todas las citas aunque NO tengan pago
----------------------------------------------------------
SELECT 
    a.appointment_id,
    p.full_name AS paciente,
    s.service_name,
    pay.amount
FROM appointment a
LEFT JOIN payment pay ON a.appointment_id = pay.appointment_id
LEFT JOIN patient p ON a.patient_id = p.patient_id
LEFT JOIN service s ON a.service_id = s.service_id;


----------------------------------------------------------
-- 3. RIGHT JOIN: Mostrar pagos incluyendo pagos sin cita (si existieran)
----------------------------------------------------------
SELECT 
    pay.payment_id,
    pay.amount,
    a.appointment_id,
    p.full_name
FROM payment pay
RIGHT JOIN appointment a ON a.appointment_id = pay.appointment_id
LEFT JOIN patient p ON a.patient_id = p.patient_id;


----------------------------------------------------------
-- 4. FULL JOIN (solo en PostgreSQL)
----------------------------------------------------------
SELECT
    p.full_name AS paciente,
    pay.amount
FROM
    patient p
LEFT JOIN 
    appointment a ON p.patient_id = a.patient_id 
LEFT JOIN
    payment pay ON a.appointment_id = pay.appointment_id;
----------------------------------------------------------
-- 5. GROUP BY: Total de pagos sumados por método
----------------------------------------------------------
SELECT 
    payment_method,
    COUNT(*) AS cantidad_transacciones,
    SUM(amount) AS total_generado
FROM payment
GROUP BY payment_method;


----------------------------------------------------------
-- 6. HAVING: Métodos de pago que superan 100,000 en total
----------------------------------------------------------
SELECT 
    payment_method,
    SUM(amount) AS total
FROM payment
GROUP BY payment_method
HAVING SUM(amount) > 100000;


----------------------------------------------------------
-- 7. Subconsulta: Pacientes que tienen al menos una cita realizada
----------------------------------------------------------
SELECT full_name
FROM patient
WHERE patient_id IN (
    SELECT patient_id
    FROM appointment
    WHERE status = 'REALIZADA'
);


----------------------------------------------------------
-- 8. Subconsulta correlacionada: Total gastado por cada paciente
----------------------------------------------------------
SELECT 
    p.full_name,
    (
        SELECT SUM(pay.amount)
        FROM payment pay
        JOIN appointment a ON a.appointment_id = pay.appointment_id
        WHERE a.patient_id = p.patient_id
    ) AS total_gastado
FROM patient p;


----------------------------------------------------------
-- 9. CTE (WITH): Servicios más vendidos
----------------------------------------------------------
WITH conteo_servicios AS (
    SELECT 
        s.service_name,
        COUNT(*) AS veces_solicitado
    FROM appointment a
    JOIN service s ON a.service_id = s.service_id
    GROUP BY s.service_name
)
SELECT *
FROM conteo_servicios
ORDER BY veces_solicitado DESC;


----------------------------------------------------------
-- 10. CTE + JOIN: Doctor con mayor número de citas realizadas
----------------------------------------------------------
WITH citas_realizadas AS (
    SELECT 
        doctor_id,
        COUNT(*) AS total_citas
    FROM appointment
    WHERE status = 'REALIZADA'
    GROUP BY doctor_id
)
SELECT 
    d.full_name,
    c.total_citas
FROM citas_realizadas c
JOIN doctor d ON c.doctor_id = d.doctor_id
ORDER BY c.total_citas DESC;

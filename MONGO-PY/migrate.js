// migrate.js
import mysql from "mysql2/promise";
import { MongoClient } from "mongodb";
import dotenv from "dotenv";
dotenv.config();

// -------------------------------
// CREDENCIALES DESDE .env
// -------------------------------
const MYSQL_HOST = process.env.MYSQL_HOST || "localhost";
const MYSQL_PORT = process.env.MYSQL_PORT || 3307;
const MYSQL_USER = process.env.MYSQL_USER || "root";
const MYSQL_PASSWORD = process.env.MYSQL_PASSWORD || "12345";
const MYSQL_DB = process.env.MYSQL_DATABASE || "mysql";

const MONGO_HOST = process.env.MONGO_HOST || "localhost";
const MONGO_PORT = process.env.MONGO_PORT || 27018;
const MONGO_DB = process.env.MONGO_DB || "mongo_sistemas";

const REDIS_HOST = process.env.REDIS_HOST || 'localhost';
const REDIS_PORT = process.env.REDIS_PORT || 6379;

// -------------------------------
// CONEXIONES
// -------------------------------
async function connectMySQL() {
    return await mysql.createConnection({
        host: MYSQL_HOST,
        port: MYSQL_PORT,
        user: MYSQL_USER,
        password: MYSQL_PASSWORD,
        database: MYSQL_DB,
    });
}

async function connectMongo() {
    const client = new MongoClient(`mongodb://${MONGO_HOST}:${MONGO_PORT}`);
    await client.connect();
    return { client, db: client.db(MONGO_DB) };
}

const redis = require('redis');

async function connectRedis() {
    const client = redis.createClient({
        host: REDIS_HOST,
        port: REDIS_PORT,
    });

    client.on('error', (err) => console.log('Redis Client Error', err));

    await client.connect();
    console.log('✅ Conexión a Redis establecida.');
    return client;
}
// -------------------------------
// MIGRACIÓN PRINCIPAL
// -------------------------------
async function migrate() {
    const conn = await connectMySQL();
    const { client, db } = await connectMongo();

    try {
        console.log("\n===== INICIANDO MIGRACIÓN =====");

        // BORRAR COLECCIONES ANTES DE MIGRAR
        await db.collection("specialties").deleteMany({});
        await db.collection("patients").deleteMany({});
        await db.collection("doctors").deleteMany({});
        await db.collection("services").deleteMany({});
        await db.collection("appointments").deleteMany({});
        await db.collection("payments").deleteMany({});

        // -------------------------------
        // 1. MIGRAR SPECIALTY
        // -------------------------------
        const [specialties] = await conn.query(`
            SELECT specialty_id, name 
            FROM specialty
        `);
        await db.collection("specialties").insertMany(specialties);
        console.log(`Migradas ${specialties.length} especialidades`);

        // -------------------------------
        // 2. MIGRAR PATIENT
        // -------------------------------
        const [patients] = await conn.query(`
            SELECT patient_id, full_name, email, phone
            FROM patient
        `);
        await db.collection("patients").insertMany(patients);
        console.log(`Migrados ${patients.length} pacientes`);

        // -------------------------------
        // 3. MIGRAR DOCTOR
        // -------------------------------
        const [doctors] = await conn.query(`
            SELECT doctor_id, full_name, specialty_id
            FROM doctor
        `);
        await db.collection("doctors").insertMany(doctors);
        console.log(`Migrados ${doctors.length} doctores`);

        // -------------------------------
        // 4. MIGRAR SERVICE
        // -------------------------------
        const [services] = await conn.query(`
            SELECT service_id, service_name, price
            FROM service
        `);
        await db.collection("services").insertMany(services);
        console.log(`Migrados ${services.length} servicios`);

        // -------------------------------
        // 5. MIGRAR APPOINTMENTS
        // -------------------------------
        const [appointments] = await conn.query(`
            SELECT appointment_id, patient_id, doctor_id, service_id, appointment_date, status
            FROM appointment
        `);
        await db.collection("appointments").insertMany(appointments);
        console.log(`Migradas ${appointments.length} citas médicas`);

        // -------------------------------
        // 6. MIGRAR PAYMENTS
        // -------------------------------
        const [payments] = await conn.query(`
            SELECT payment_id, appointment_id, amount, payment_date, payment_method
            FROM payment
        `);
        await db.collection("payments").insertMany(payments);
        console.log(`Migrados ${payments.length} pagos`);

        console.log("\n===== MIGRACIÓN COMPLETA =====");

        // -------------------------------
        // CRUD DE EJEMPLO
        // -------------------------------

        const patientCol = db.collection("patients");

        // CREATE
        await patientCol.insertOne({
            patient_id: 999,
            full_name: "Paciente Prueba",
            email: "test@example.com",
            phone: "0000000"
        });

        // READ
        const pacienteTest = await patientCol.findOne({ patient_id: 999 });
        console.log("\nPaciente leído:", pacienteTest);

        // UPDATE
        await patientCol.updateOne(
            { patient_id: 999 },
            { $set: { phone: "1111111" } }
        );

        // DELETE (comentado si no quieres eliminar)
        // await patientCol.deleteOne({ patient_id: 999 });

        // -------------------------------
        // PIPELINES DE AGGREGATION
        // -------------------------------

        console.log("\n===== AGGREGATION 1: Total pagado por paciente =====");

        const agg1 = await db.collection("payments").aggregate([
            {
                $lookup: {
                    from: "appointments",
                    localField: "appointment_id",
                    foreignField: "appointment_id",
                    as: "appointment"
                }
            },
            { $unwind: "$appointment" },
            {
                $group: {
                    _id: "$appointment.patient_id",
                    totalPagado: { $sum: "$amount" },
                    cantidadPagos: { $sum: 1 }
                }
            },
            {
                $sort: { totalPagado: -1 }
            }
        ]).toArray();

        console.log(agg1);

        console.log("\n===== AGGREGATION 2: Información completa de citas =====");

        const agg2 = await db.collection("appointments").aggregate([
            {
                $lookup: {
                    from: "patients",
                    localField: "patient_id",
                    foreignField: "patient_id",
                    as: "patient"
                }
            },
            { $unwind: "$patient" },
            {
                $lookup: {
                    from: "doctors",
                    localField: "doctor_id",
                    foreignField: "doctor_id",
                    as: "doctor"
                }
            },
            { $unwind: "$doctor" },
            {
                $lookup: {
                    from: "services",
                    localField: "service_id",
                    foreignField: "service_id",
                    as: "service"
                }
            },
            { $unwind: "$service" },
            {
                $project: {
                    appointment_id: 1,
                    appointment_date: 1,
                    status: 1,
                    "patient.full_name": 1,
                    "doctor.full_name": 1,
                    "service.service_name": 1,
                    "service.price": 1
                }
            }
        ]).toArray();

        console.log(agg2);

    } catch (err) {
        console.error("ERROR EN MIGRACIÓN:", err);
    } finally {
        await conn.end();
        await client.close();
    }
}

async function demonstrateRedis() {
    const redisClient = await connectRedis();
    
    // Demostración: Contador de Visitas (STRING)
    console.log('\n--- Demostración de STRING (Contador) ---');
    await redisClient.set('visitas_home', 0); // Comando 1
    await redisClient.incr('visitas_home'); // Comando 2
    let visitas = await redisClient.get('visitas_home'); // Comando 3
    console.log(`Visitas actuales: ${visitas}`);

    // Demostración: Sesión con TTL (STRING con TTL)
    console.log('\n--- Demostración de STRING con TTL (Sesiones) ---');
    await redisClient.setEx('sesion:user:1234', 60, "token_abc123"); // Comando 4 (expira en 60 seg)
    let ttl = await redisClient.ttl('sesion:user:1234'); // Comando 5
    console.log(`TTL de la sesión: ${ttl} segundos`);

    // Demostración: Caché de Doctor (HASH)
    console.log('\n--- Demostración de HASH (Caché de Doctor) ---');
    await redisClient.hSet('doctor:d5f2a', { // Comando 7
        nombre: "Dr. Pérez", 
        especialidad: "Cardiología", 
        citas_hoy: 5
    });
    await redisClient.hIncrBy('doctor:d5f2a', 'citas_hoy', 1); // Comando 9
    let doctorData = await redisClient.hGetAll('doctor:d5f2a'); // Comando 8
    console.log('Datos en caché del Dr. Pérez:', doctorData);

    // ... Puedes continuar las demostraciones con LIST y ZSET aquí ...

    await redisClient.quit();
}

// Ejecutar
migrate();

import { createClient } from 'redis';
import dotenv from 'dotenv';
dotenv.config();

const REDIS_HOST = process.env.REDIS_HOST || 'localhost';
const REDIS_PORT = process.env.REDIS_PORT || 6379;

export async function connectRedis() {
  const url = `redis://${REDIS_HOST}:${REDIS_PORT}`;
  const client = createClient({ url });

  client.on('error', (err) => console.error('Redis Client Error', err));

  await client.connect();
  console.log('✅ Conexión a Redis establecida.');
  return client;
}

export async function demonstrateRedis() {
  const client = await connectRedis();

  console.log('\n--- Demostración de STRING (Contador) ---');
  await client.set('visitas_home', '0');
  await client.incr('visitas_home');
  let visitas = await client.get('visitas_home');
  console.log(`Visitas actuales: ${visitas}`);

  console.log('\n--- Demostración de HASH (Caché de Doctor) ---');
  await client.hSet('doctor:d5f2a', { nombre: 'Dr. Pérez', especialidad: 'Cardiología', citas_hoy: '5' });
  await client.hIncrBy('doctor:d5f2a', 'citas_hoy', 1);
  let doctorData = await client.hGetAll('doctor:d5f2a');
  console.log('Datos en caché del Dr. Pérez:', doctorData);

  await client.quit();
}

export default connectRedis;

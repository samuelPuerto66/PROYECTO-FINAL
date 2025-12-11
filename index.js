import { connectRedis } from "./redis.js";
import { connectMySQL } from "./migrate.js";

async function start() {
  console.log("\nIniciando conexiones...");

  await connectRedis();  
  await connectMySQL();   

  console.log("\n✅ Todos los servicios conectados correctamente");
}

start().catch(console.error);

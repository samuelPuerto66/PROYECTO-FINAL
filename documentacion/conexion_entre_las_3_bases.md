# Arquitectura de Conexión de Datos: MySQL, MongoDB y Redis

---

## 1. Componentes del Sistema de Datos

El sistema se conecta simultáneamente a tres bases de datos, cada una cumpliendo un rol específico:

| Base de Datos | Tipo | Rol Principal |
| :--- | :--- | :--- |
| **MySQL** | Relacional (SQL) | **Persistencia de Datos Transaccionales** (Integridad alta). |
| **MongoDB** | NoSQL (Documentos) | **Flexibilidad y Escalabilidad** (Colecciones como citas, doctores, servicios). |
| **Redis** | NoSQL (Clave-Valor) | **Caché y Alto Rendimiento** (Sesiones, Contadores, Colas y Rankings). |

### Conexiones en Código (`migrate.js`)

Las credenciales para cada base de datos se manejan mediante variables de entorno (`.env`):

* **MySQL:** `connectMySQL()`
* **MongoDB:** `connectMongo()`
* **Redis:** `connectRedis()`

---

## 2. Integración y Casos de Uso

La arquitectura políglota permite dirigir cada solicitud al motor más eficiente para esa tarea:

### Caso 1: Patrón de Caché de Lectura (Redis + MongoDB)

Este patrón evita consultar MongoDB en cada petición de datos frecuentes (ej. perfiles de doctor).

1.  **Búsqueda en Redis:** La aplicación intenta buscar el perfil (`doctor:<id>`) en **Redis** (`GET`).
2.  **Hit de Caché:** Si **existe**, se retorna inmediatamente.
3.  **Miss de Caché:** Si **no existe**, se consulta **MongoDB** (la fuente principal del dato).
4.  **Almacenamiento:** El resultado de MongoDB se guarda en **Redis** usando `SETEX` (o `SET` con la opción `EX`) con un **TTL** de 3600 segundos (1 hora).

### Caso 2: Actualización de Ranking en Tiempo Real (MongoDB + Redis)

* **Flujo:** Al registrar una nueva cita en la colección `appointments` de **MongoDB**, se ejecuta inmediatamente el comando `ZINCRBY` en **Redis** para incrementar la puntuación del doctor en el `ranking:doctores`. Esto mantiene la clasificación actualizada sin sobrecargar MongoDB con cálculos de ordenamiento.

### Caso 3: Colas Asíncronas (Redis para Tareas)


* **Flujo:** Cuando se crea una cita en **MongoDB**, la ID de la cita se añade a una **Cola LIST** en **Redis** (`LPUSH cola:recordatorios`). Un proceso de fondo independiente consume (`BRPOP`) esta cola para enviar recordatorios por email o SMS.






EJM CAPTURAS:

<img width="1379" height="838" alt="image" src="https://github.com/user-attachments/assets/c875e3ea-f9f5-47d9-8015-ef7a67f80620" />


<img width="639" height="516" alt="image" src="https://github.com/user-attachments/assets/70ee8a43-081e-4626-9a2c-e332fca672a0" />

<img width="706" height="626" alt="image" src="https://github.com/user-attachments/assets/ace784b4-2a74-4f73-932f-8e5f62573d3a" />



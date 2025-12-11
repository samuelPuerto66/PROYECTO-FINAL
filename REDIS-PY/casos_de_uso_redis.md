Casos de Uso Prácticos de Redis en `mongo_sistema`

Este documento describe la aplicación de las estructuras de datos de Redis para mejorar el rendimiento y la funcionalidad del sistema de gestión de citas médicas (`mongo_sistema`).

---

## 1. Caché de Objetos (Estructura: STRING con TTL)

**Escenario de Uso:** Optimizar la consulta frecuente a datos inmutables o de baja variación, como los perfiles de Doctores o la información de Servicios. **(Cumple con: Estados temporales / Registros con expiración)**

| Colección Impactada | Clave de Redis | TTL Sugerido | Lógica de Implementación |
| :--- | :--- | :--- | :--- |
| `doctors` | `doctor:<id_doctor>` | 3600 segundos (1 hora) | Al buscar un doctor, si no está en Redis, se consulta MongoDB y se almacena el JSON completo del doctor en la caché. |
| `services` | `service:<id_servicio>` | 86400 segundos (1 día) | Se utiliza para obtener rápidamente el costo o la descripción de un servicio sin golpear la BD. |

**Comandos Clave Demostrados:**

* `SET <key> <value> EX <seconds>` (Para almacenar el objeto serializado con expiración.)
* `GET <key>` (Para recuperar el objeto de la caché.)

---

## 2. Ranking y Reportes de Popularidad (Estructura: ZSET)

**Escenario de Uso:** Generar listados ordenados en tiempo real, como el top de doctores o especialidades más solicitadas.

| Colección Impactada | Clave de Redis | Operación | Lógica de Implementación |
| :--- | :--- | :--- | :--- |
| `appointments` | `ranking:doctores_citas` | Contador de citas | Cada vez que se crea una nueva cita en MongoDB, se incrementa la puntuación del doctor en el ZSET de Redis. |

**Comandos Clave Demostrados:**

* `ZINCRBY <key> <incremento> <member>` (Para aumentar el contador del doctor por cada cita.)
* `ZREVRANGE <key> 0 9 WITHSCORES` (Para obtener el top 10 de doctores más solicitados.)

---

## 3. Colas de Procesos Asíncronos (Estructura: LIST)

**Escenario de Uso:** Gestionar la entrega de tareas que no requieren respuesta inmediata, como el envío de recordatorios o el procesamiento de pagos. **(Cumple con: Colas de turnos)**

| Colección Impactada | Clave de Redis | Operación | Lógica de Implementación |
| :--- | :--- | :--- | :--- |
| `appointments` | `cola:recordatorios` | Encolar citas | Al crear una cita en `appointments`, se añade el ID de la cita a esta cola para que un worker externo la procese (ej. enviar email de recordatorio). |
| `payments` | `cola:procesar_pagos` | Procesamiento | Se utiliza para gestionar pagos que fallaron y necesitan ser reintentados posteriormente. |

**Comandos Clave Demostrados:**

* `LPUSH <key> <value>` (Para agregar un elemento a la cola.)
* `BRPOP <key> <timeout>` (Para que el proceso consumidor espere y extraiga un elemento de forma segura.)

---

## 4. Gestión de Estado de Usuario (Estructura: HASH y STRING)

**Escenario de Uso:** Almacenar datos de sesiones y perfiles de usuario. **(Cumple con: Estados temporales / Configuraciones en HASH)**

| Tipo de Dato | Clave de Redis | Estructura | Lógica de Implementación |
| :--- | :--- | :--- | :--- |
| **Tokens de Sesión** | `sesion:<id_usuario>` | STRING con TTL | Almacenar el token de autenticación del usuario, expirando automáticamente después de un tiempo de inactividad. |
| **Perfil de Paciente** | `patient:<id_paciente>` | HASH | Almacenar temporalmente las preferencias del paciente o su información de contacto (nombre, email, teléfono) para evitar múltiples consultas a la BD. |

**Comandos Clave Demostrados:**

* `SETEX <key> <seconds> <value>` (Para la sesión con TTL.)
* `HSET <key> <field> <value>` y `HGETALL <key>` (Para la gestión de datos del perfil del paciente.)
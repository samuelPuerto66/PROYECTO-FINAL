°consultas aggregation

-db.payments.aggregate([
  // 1) traer appointment relacionado
  { $lookup: {
      from: "appointments",
      localField: "appointment_id",
      foreignField: "appointment_id",
      as: "appointment"
  }},
  { $unwind: "$appointment" },                     // convertir arreglo a obj
  // 2) agrupar por patient_id dentro de la appointment
  { $group: {
      _id: "$appointment.patient_id",
      totalPagado: { $sum: "$amount" },
      pagosCount: { $sum: 1 }
  }},
  // 3) traer nombre del paciente (JOIN con patients)
  { $lookup: {
      from: "patients",
      localField: "_id",
      foreignField: "patient_id",
      as: "patient"
  }},
  { $unwind: { path: "$patient", preserveNullAndEmptyArrays: true } },
  // 4) proyectar campos limpios
  { $project: {
      _id: 0,
      patient_id: "$_id",
      patient_name: "$patient.full_name",
      totalPagado: 1,
      pagosCount: 1
  }},
  // 5) ordenar por totalPagado descendente
  { $sort: { totalPagado: -1 } }
]).pretty()
db.payments.aggregate([
  // 1) traer appointment relacionado
  { $lookup: {
      from: "appointments",
      localField: "appointment_id",
      foreignField: "appointment_id",
      as: "appointment"
  }},
  { $unwind: "$appointment" },                     // convertir arreglo a obj
  // 2) agrupar por patient_id dentro de la appointment
  { $group: {
      _id: "$appointment.patient_id",
      totalPagado: { $sum: "$amount" },
      pagosCount: { $sum: 1 }
  }},
  // 3) traer nombre del paciente (JOIN con patients)
  { $lookup: {
      from: "patients",
      localField: "_id",
      foreignField: "patient_id",
      as: "patient"
  }},
  { $unwind: { path: "$patient", preserveNullAndEmptyArrays: true } },
  // 4) proyectar campos limpios
  { $project: {
      _id: 0,
      patient_id: "$_id",
      patient_name: "$patient.full_name",
      totalPagado: 1,
      pagosCount: 1
  }},
  // 5) ordenar por totalPagado descendente
  { $sort: { totalPagado: -1 } }
]).pretty()




-db.appointments.aggregate([
  // Filtrar (opcional): solo FUTURAS o estado PENDIENTE
  { $match: { status: { $in: ["PENDIENTE", "ENTREGADO"] } } },

  // Lookup paciente
  { $lookup: {
      from: "patients",
      localField: "patient_id",
      foreignField: "patient_id",
      as: "patient"
  }},
  { $unwind: "$patient" },

  // Lookup doctor
  { $lookup: {
      from: "doctors",
      localField: "doctor_id",
      foreignField: "doctor_id",
      as: "doctor"
  }},
  { $unwind: "$doctor" },

  // Lookup service
  { $lookup: {
      from: "services",
      localField: "service_id",
      foreignField: "service_id",
      as: "service"
  }},
  { $unwind: "$service" },

  // Proyectar lo necesario
  { $project: {
      _id: 0,
      appointment_id: 1,
      appointment_date: 1,
      status: 1,
      "patient.full_name": 1,
      "patient.email": 1,
      "doctor.full_name": 1,
      "service.service_name": 1,
      "service.price": 1
  }},

  // Ordenar por fecha (más cercano primero)
  { $sort: { appointment_date: 1 } }
]).pretty()
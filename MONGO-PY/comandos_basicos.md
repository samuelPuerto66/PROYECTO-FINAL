db.specialties.insertMany([
  { specialty_id: 1, name: "Cardiología" },
  { specialty_id: 2, name: "Pediatría" }
]);


db.services.insertMany([
  { service_id: 1, service_name: "Consulta general", price: 30000.00 },
  { service_id: 2, service_name: "Consulta especializada", price: 60000.00 }
]);


db.patients.insertMany([
  { patient_id: 1, full_name: "Juan Perez", email: "juan@mail.com", phone: "3001112222", createdAt: new Date() },
  { patient_id: 2, full_name: "Luisa Gomez", email: "luisa@mail.com", phone: "3003334444", createdAt: new Date() }
]);


db.doctors.insertMany([
  { doctor_id: 1, full_name: "Dra. Ana Ruiz", specialty_id: 1 },
  { doctor_id: 2, full_name: "Dr. Carlos Lopez", specialty_id: 2 }
]);


db.appointments.insertMany([
  { appointment_id: 1, patient_id: 1, doctor_id: 1, service_id: 1, appointment_date: new Date("2025-12-01T09:00:00Z"), status: "ENTREGADO" },
  { appointment_id: 2, patient_id: 1, doctor_id: 2, service_id: 2, appointment_date: new Date("2025-12-05T11:00:00Z"), status: "PENDIENTE" },
  { appointment_id: 3, patient_id: 2, doctor_id: 2, service_id: 1, appointment_date: new Date("2025-12-02T10:30:00Z"), status: "ENTREGADO" }
]);


db.payments.insertMany([
  { payment_id: 1, appointment_id: 1, amount: 30000.00, payment_date: new Date(), payment_method: "TARJETA" },
  { payment_id: 2, appointment_id: 3, amount: 30000.00, payment_date: new Date(), payment_method: "EFECTIVO" }
]);




db.payments.insertMany([
  { payment_id: 1, appointment_id: 1, amount: 30000.00, payment_date: new Date(), payment_method: "TARJETA" },
  { payment_id: 2, appointment_id: 3, amount: 30000.00, payment_date: new Date(), payment_method: "EFECTIVO" }
]);







db.patients.findOne({ patient_id: 1 })           // un doc
db.appointments.find({ status: "PENDIENTE" }).pretty()  // varios


db.patients.updateOne({ patient_id: 10 }, { $set: { phone: "3000000000" } })


db.patients.deleteOne({ patient_id: 10 })

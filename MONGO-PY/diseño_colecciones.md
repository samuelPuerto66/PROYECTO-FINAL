°CREACION DE LAS COLECCIONES

-db.createCollection("patients", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["patient_id", "full_name", "email"],
      properties: {
        patient_id: { bsonType: "int" },
        full_name: { bsonType: "string" },
        email: { bsonType: "string", pattern: "^.+@.+\\..+$" },
        phone: { bsonType: "string" },
        createdAt: { bsonType: "date" }
      }
    }
  }
});

-db.patients.createIndex({ email: 1 }, { unique: true });
email_1
db.createCollection("doctors", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["doctor_id", "full_name", "specialty_id"],
      properties: {
        doctor_id: { bsonType: "int" },
        full_name: { bsonType: "string" },
        specialty_id: { bsonType: "int" }
      }
    }
  }
});

-db.createCollection("doctors", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["doctor_id", "full_name", "specialty_id"],
      properties: {
        doctor_id: { bsonType: "int" },
        full_name: { bsonType: "string" },
        specialty_id: { bsonType: "int" }
      }
    }
  }
});




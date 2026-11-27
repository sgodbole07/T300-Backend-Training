

// Task1
// Step 1: Select a Fresh Database
use("company_advanced");

// Step 2: Create the Validated Collection
db.createCollection("employees", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "departmentId", "experience", "active"],
        properties: {
        name: {
          bsonType: "string",
          description: "must be a string and is required"
        },
        departmentId: {
          bsonType: "int",
          description: "must be an integer and is required"
        },
        experience: {
          bsonType: "int",
          description: "must be an integer and is required"
        },
        active: {
          bsonType: "bool",
          description: "must be a boolean and is required"
        }
      }
    }
  }
});

// Step 3: Insert the Starting Dataset
db.employees.insertMany([
  {
    "_id": 1,
    "name": "John",
    "departmentId": 10,
    "skills": ["Java", "MongoDB"],
    "experience": 4,
    "active": true,
    "certifications": [
      {
        "name": "MongoDB",
        "status": "Expired",
        "expiryYear": 2026
      }
    ]
  },
  {
    "_id": 2,
    "name": "Alice",
    "departmentId": 10,
    "skills": ["Python", "MongoDB"],
    "experience": 6,
    "active": true,
    "certifications": [
      {
        "name": "MongoDB",
        "status": "Active",
        "expiryYear": 2028
      }
    ]
  },
  {
    "_id": 3,
    "name": "David",
    "departmentId": 20,
    "skills": ["Communication"],
    "experience": 3,
    "active": false,
    "certifications": [
      {
        "name": "Communication",
        "status": "Active",
        "expiryYear": 2027
      }
    ]
  }
]);

// Step 4: Test the Validation Rule

db.employees.insertOne(
    {
_id: 99,
name: 123,
departmentId: "HR",
experience: "one",
active: "yes"
}
)

// 2.1 Find One Matching Array Object

db.employees.find(
    {
        certifications: {
            $elemMatch: {
                name: "MongoDB",
                status: "Active"
            }
        }
    }
);


// 2.2 Update One Matching Array Element

db.employees.updateOne(
  {
    _id: 1,
    "certifications.name": "MongoDB"
  },
  {
    $set: { "certifications.$.status": "Active" }
  }
);
db.employees.findOne(
  {
    _id: 1,
    "certifications.name": "MongoDB"
  }
);

// 2.3 Update Selected Array Elements
db.employees.updateMany(
  {},
  { $set: { "certifications.$[elem].status": "Renewal Due" } },
  { arrayFilters: [{ "elem.expiryYear": { $lt: 2027 } }] }
);

db.employees.find(
  {
    certifications: {
      $elemMatch: {
        expiryYear: { $lt: 2027 }
      }
    }
  }
);  

db.employees.find();


// Task 3: Bulk Write Operations

// Increase John's experience by 1.

db.employees.updateOne(
  { name: "John" },
  { $inc: { experience: 1 } }
);

// Set Alice's active value to false.
db.employees.updateOne(
  { name: "Alice" },
  { $set: { active: false } }
);  

// Insert Emma using the document below.
db.employees.insertOne({
  _id: 4,
  name: "Emma",
  departmentId: 20,
  skills: ["Excel"],
  experience: 2,
  active: true,
  certifications: [
    { name: "Excel", status: "Active", expiryYear: 2026 }
  ]
})

db.employees.bulkWrite([
  {
    updateOne: {
      filter: { name: "John" },
      update: { $inc: { experience: 1 } }
    }
  },
  {
    updateOne: {
      filter: { name: "Alice" },
      update: { $set: { active: false } }
    }
  },
  {
    insertOne: {
      document: {
        _id: 4,
        name: "Emma",
        departmentId: 20,
        skills: ["Excel"],
        experience: 2,
        active: true,
        certifications: [
          { name: "Excel", status: "Active", expiryYear: 2026 }
        ]
      }
    }
  }
]);


// Task 4: Advanced Aggregation

// Step 1: Create the Departments Collection  


db.departments.insertMany([
  { _id: 10, name: "Engineering" },
  { _id: 20, name: "HR" }
]);

// 4.1 Join Employees with Departments
db.employees.aggregate([
  {
    $lookup: {
      from: "departments",
      localField: "departmentId",
      foreignField: "_id",
      as: "department"
    }
  },
  { $unwind: "$department" },
  {
    $project: {
      _id: 0,
      name: 1,
      departmentName: "$department.name"
    }
  },
  { $sort: { name: 1 } }
]);

// 4.2 Count Employees for Each Skill

db.employees.aggregate([
  { $unwind: "$skills" },
  {
    $group: {
      _id: "$skills",
      count: { $sum: 1 }
    }
  },
  { $sort: { count: -1, _id: 1 } }
]);


// 4.3 Return Active Employees and a Count
db.employees.aggregate([
  { $match: { active: true } },
  {
    $facet: {
      employees: [
        { $project: { _id: 0, name: 1 } },
        { $sort: { name: 1 } }
      ],
      totalActive: [
        { $count: "count" }
      ]
    }
  }
]);

// Task 5: Indexing and Query Performance
// 5.1 Create and Verify a Compound Index
db.employees.createIndex({ departmentId: 1, name: 1 }, { name: "departmentId_1_name_1" });


// 5.2 Read explain("executionStats")
db.employees.find({ departmentId: 10 }).sort({ name: 1 }).explain("executionStats");

// Output:
// totalKeysExamined: 2,
// totalDocsExamined: 2,
//     nReturned: 2,
//     stage: 'IXSCAN',


// 5.3 Create a TTL Index
db.createCollection("sessions");

db.sessions.insertOne({
  _id: 1,
  userName: "John",
  expiresAt: new Date(Date.now() + 600000)
});

db.sessions.createIndex(
  { expiresAt: 1 },
  { expireAfterSeconds: 0, name: "expiresAt_1" }
);

// Task 6: Backup and Restore
// 1. Back up company_advanced to company_advanced.archive using gzip.
mongodump --db company_advanced --archive=/tmp/company_advanced.archive --gzip

// 2. Restore it into a new database named company_advanced_restore.
mongorestore --archive=/tmp/company_advanced.archive --gzip --nsFrom="company_advanced.*" --nsTo="company_advanced_restore.*"

// 3. Verify the restored collection counts.
use company_advanced_restore;
db.employees.find().count();


// Task 7 MCQs
// Q1. Why is schema validation useful?
// B. It rejects documents that do not follow required fields or data types.

// Q2. What does $elemMatch help verify?
// B. Multiple conditions match the same array object.

// Q3. What is the purpose of arrayFilters?
// C. To update selected array elements that match a condition.

// Q4. When is bulkWrite() useful?
// A. When several write operations should be sent together.

// Q5. Which stage joins documents from another collection?
// C. $lookup

// Q6. What does IXSCAN usually indicate in explain() output?
// B. MongoDB used an index.

// Q7. What happens when abortTransaction() is called?
// C. Uncommitted transaction changes are rolled back.

// Q8. What does write concern w: "majority" mean?
// B. A majority of voting data-bearing replica-set members acknowledge the write.

// Q9. What normally happens when a replica-set Primary fails?
// C. Eligible members hold an election for a new Primary.

// Q10. Which is the best direction for choosing a shard key?
// A high-cardinality field that distributes traffic and matches common queries.

// Q11. What do Change Streams allow an application to do?
// A. Listen for inserts, updates, replacements, and deletes.

// Q12. Which is a good production-security practice?
// C. Use TLS, restricted network access, and least-privilege credentials.


/**
 * Database seeder for development.
 * Run with: npm run seed
 * Safe to re-run — clears collections before inserting fresh data.
 */

require('dotenv').config();

const mongoose = require('mongoose');

const { connectDB, disconnectDB } = require('../config/db');
const { INVOICE_STATUS, CURRENCY } = require('../config/constants');
const { calculateFeeForGrade } = require('../services/feeCalculatorService');

const Student = require('../models/Student');
const Invoice = require('../models/Invoice');
const Class = require('../models/Class');
const Section = require('../models/Section');

const CLASS_NAMES = ['Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
const SECTION_NAMES = ['Section A', 'Section B', 'Section C'];

const STUDENT_SEED_DATA = [
  {
    firstName: 'Ahmad',
    lastName: 'Khan',
    email: 'ahmad.khan@edustream.edu.pk',
    rollNumber: '2024-001',
    grade: 'Grade 10',
    section: 'Section A',
    parentName: 'Imran Khan',
    phone: '03001234567',
    parentEmail: 'imran.khan@gmail.com',
    avatarColor: '0xFFE3F2FD',
  },
  {
    firstName: 'Sara',
    lastName: 'Ahmed',
    email: 'sara.ahmed@edustream.edu.pk',
    rollNumber: '2024-002',
    grade: 'Grade 10',
    section: 'Section B',
    parentName: 'Ahmed Malik',
    phone: '03117654321',
    parentEmail: 'ahmed.malik@gmail.com',
    avatarColor: '0xFFE1F5FE',
  },
  {
    firstName: 'Zainab',
    lastName: 'Fatima',
    email: 'zainab.fatima@edustream.edu.pk',
    rollNumber: '2024-003',
    grade: 'Grade 9',
    section: 'Section A',
    parentName: 'Ali Raza',
    phone: '03229988776',
    parentEmail: 'ali.raza@yahoo.com',
    avatarColor: '0xFFE0F7FA',
  },
  {
    firstName: 'Hassan',
    lastName: 'Raza',
    email: 'hassan.raza@edustream.edu.pk',
    rollNumber: '2024-004',
    grade: 'Grade 11',
    section: 'Section B',
    parentName: 'Tariq Raza',
    phone: '03335551234',
    parentEmail: 'tariq.raza@gmail.com',
    avatarColor: '0xFFF3E5F5',
  },
  {
    firstName: 'Ayesha',
    lastName: 'Siddiqui',
    email: 'ayesha.siddiqui@edustream.edu.pk',
    rollNumber: '2024-005',
    grade: 'Grade 9',
    section: 'Section C',
    parentName: 'Khalid Siddiqui',
    phone: '03451239876',
    parentEmail: 'khalid.siddiqui@outlook.com',
    avatarColor: '0xFFE8F5E9',
  },
];

/**
 * Invoice seed definitions (resolved to student roll numbers after insert).
 */
const INVOICE_SEED_DATA = [
  { rollNumber: '2024-001', billingMonth: 'May 2024', status: INVOICE_STATUS.PAID },
  { rollNumber: '2024-001', billingMonth: 'June 2024', status: INVOICE_STATUS.PENDING },
  { rollNumber: '2024-002', billingMonth: 'May 2024', status: INVOICE_STATUS.PENDING },
  { rollNumber: '2024-002', billingMonth: 'June 2024', status: INVOICE_STATUS.PAID },
  { rollNumber: '2024-003', billingMonth: 'May 2024', status: INVOICE_STATUS.PAID },
  { rollNumber: '2024-003', billingMonth: 'June 2024', status: INVOICE_STATUS.PENDING },
  { rollNumber: '2024-004', billingMonth: 'May 2024', status: INVOICE_STATUS.PENDING },
  { rollNumber: '2024-004', billingMonth: 'June 2024', status: INVOICE_STATUS.PAID },
  { rollNumber: '2024-005', billingMonth: 'May 2024', status: INVOICE_STATUS.PAID },
  { rollNumber: '2024-005', billingMonth: 'June 2024', status: INVOICE_STATUS.PENDING },
];

async function clearCollections() {
  await Promise.all([
    Invoice.deleteMany({}),
    Student.deleteMany({}),
    Class.deleteMany({}),
    Section.deleteMany({}),
  ]);

  const counterCollection = mongoose.connection.collection('invoicecounters');
  await counterCollection.deleteMany({});

  console.log('Cleared: students, invoices, classes, sections, invoice counters');
}

async function seedClasses() {
  const classes = await Class.insertMany(CLASS_NAMES.map((name) => ({ name })));
  console.log(`Seeded ${classes.length} classes`);
  return classes;
}

async function seedSections() {
  const sections = await Section.insertMany(SECTION_NAMES.map((name) => ({ name })));
  console.log(`Seeded ${sections.length} sections`);
  return sections;
}

async function seedStudents() {
  const students = await Student.insertMany(STUDENT_SEED_DATA);
  console.log(`Seeded ${students.length} students`);
  return students;
}

async function seedInvoices(students) {
  const studentByRoll = Object.fromEntries(
    students.map((student) => [student.rollNumber, student])
  );

  const invoices = [];
  let invoiceSequence = 1;

  for (const item of INVOICE_SEED_DATA) {
    const student = studentByRoll[item.rollNumber];

    if (!student) {
      throw new Error(`Student not found for roll number ${item.rollNumber}`);
    }

    const amount = calculateFeeForGrade(student.grade);
    const invoiceNumber = `INV-2024-${String(invoiceSequence).padStart(3, '0')}`;
    invoiceSequence += 1;

    invoices.push({
      invoiceNumber,
      studentId: student._id,
      studentName: `${student.firstName} ${student.lastName}`,
      rollNumber: student.rollNumber,
      billingMonth: item.billingMonth,
      amount,
      currency: CURRENCY,
      status: item.status,
      paidAt: item.status === INVOICE_STATUS.PAID ? new Date() : null,
    });
  }

  const created = await Invoice.insertMany(invoices);
  console.log(`Seeded ${created.length} invoices`);
  return created;
}

async function seed() {
  console.log('EduStream SMS — database seeder started\n');

  await connectDB();

  await clearCollections();
  await seedClasses();
  await seedSections();
  const students = await seedStudents();
  await seedInvoices(students);

  console.log('\nSeeder finished successfully');
  await disconnectDB();
  process.exit(0);
}

seed().catch(async (err) => {
  console.error('Seeder failed:', err.message);
  try {
    await disconnectDB();
  } catch {
    // ignore disconnect errors
  }
  process.exit(1);
});

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          pw.Header(
            level: 0,
            child: pw.Text('Backend API Requirements - EduStream SMS', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Technology Stack: PHP Laravel', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          pw.Text('Target: Flutter App Integration (REST APIs)', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.SizedBox(height: 20),
          
          pw.Text('Project Overview', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          pw.SizedBox(height: 5),
          pw.Text('The frontend of the School Management System (EduStream) is built in Flutter. We need REST APIs to connect the frontend for live data storage and dashboard analytics. Note: Admin panel features will be discussed in a later phase. The current scope is limited to Students, Invoices, and Dashboard metrics.'),
          pw.SizedBox(height: 20),

          pw.Text('1. Dashboard Module', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          pw.SizedBox(height: 5),
          pw.Bullet(text: 'Endpoint to fetch real-time summary statistics.'),
          pw.Bullet(text: 'Metrics required: Total Students, Total Revenue (sum of all PAID invoices), and Total Pending Invoices (count of PENDING invoices).'),
          pw.SizedBox(height: 15),

          pw.Text('2. Students Module (CRUD)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          pw.SizedBox(height: 5),
          pw.Bullet(text: 'GET /students - Fetch all students (needs search query and filter by class/section).'),
          pw.Bullet(text: 'POST /students - Add a new student. Fields: firstName, lastName, email, rollNumber, grade, section, parentName, phone, parentEmail.'),
          pw.Bullet(text: 'PUT /students/{id} - Update student details.'),
          pw.Bullet(text: 'DELETE /students/{id} - Delete a student.'),
          pw.SizedBox(height: 15),

          pw.Text('3. Classes & Sections Module', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          pw.SizedBox(height: 5),
          pw.Bullet(text: 'GET /classes - List all available classes (e.g., Grade 9, Grade 10).'),
          pw.Bullet(text: 'POST /classes - Create a new class/section dynamically.'),
          pw.SizedBox(height: 15),

          pw.Text('4. Invoices & Fees Module', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          pw.SizedBox(height: 5),
          pw.Bullet(text: 'GET /invoices - Fetch all invoices. Must support filtering by student roll number, billing month, and status (PAID/PENDING).'),
          pw.Bullet(text: 'POST /invoices/batch - Generate invoices for a specific month for all active students. Logic: Grade 9 = PKR 5500, Grade 10 = PKR 6500, Others = PKR 5000.'),
          pw.Bullet(text: 'PUT /invoices/{id}/pay - Update invoice status from PENDING to PAID.'),
          pw.SizedBox(height: 20),

          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text('API Guidelines for Developer', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
          pw.Bullet(text: 'All responses should be in JSON format.'),
          pw.Bullet(text: 'Please include standard pagination for GET requests if possible.'),
          pw.Bullet(text: 'Use standard HTTP status codes (200 OK, 201 Created, 404 Not Found, etc.).'),
        ];
      },
    ),
  );

  final file = File('Laravel_Backend_Requirements.pdf');
  await file.writeAsBytes(await pdf.save());
  print('PDF generated successfully!');
}

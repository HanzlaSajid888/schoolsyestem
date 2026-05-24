import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/invoice_model.dart';
import '../../models/student_model.dart';

Future<Uint8List> generateInvoicePdf(Invoice invoice, Student student) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('EDUSTREAM', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('EXCELLENCE IN EDUCATION', style: pw.TextStyle(fontSize: 10, color: PdfColors.blue)),
                    pw.SizedBox(height: 16),
                    pw.Text('123 Education Square, Blue Area, Islamabad', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('+92 (51) 123-4567', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('billing@edustream.edu.pk', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                    pw.SizedBox(height: 8),
                    pw.Text('TRANSACTION ID: ${invoice.id}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            // Billing Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INVOICE TO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                    pw.SizedBox(height: 8),
                    pw.Text(invoice.studentName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('ID: ${student.rollNumber.replaceAll('Roll: ', '')}'),
                    pw.Text('Class: ${student.grade} | Section: ${student.section}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('SUBSCRIPTION PERIOD', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                    pw.SizedBox(height: 8),
                    pw.Text(invoice.billingMonth, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                    pw.SizedBox(height: 16),
                    pw.Text('Status: ${invoice.status.name.toUpperCase()}', style: pw.TextStyle(
                      color: invoice.status == InvoiceStatus.paid ? PdfColors.green : PdfColors.orange,
                      fontWeight: pw.FontWeight.bold,
                    )),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            // Fees Table
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                children: [
                  pw.Container(
                    color: PdfColors.blueGrey900,
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('DESCRIPTION OF FEES', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text('AMOUNT (PKR)', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Monthly Tuition Fee', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('ACADEMIC ITEM CODE: 101', style: pw.TextStyle(color: PdfColors.grey, fontSize: 8)),
                          ],
                        ),
                        pw.Text(invoice.amount.replaceAll('PKR ', ''), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 250,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Subtotal'),
                          pw.Text(invoice.amount.replaceAll('PKR ', '')),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Tax (Gov)'),
                          pw.Text('0.00'),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      pw.Container(
                        color: PdfColors.blue,
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL BALANCE', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                            pw.Text(invoice.amount, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            pw.Spacer(),
            
            // Footer
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(
              'Note: This is a system-generated invoice valid for the 2024 academic cycle. Please ensure payment is cleared before the due date to avoid late surcharges.',
              style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

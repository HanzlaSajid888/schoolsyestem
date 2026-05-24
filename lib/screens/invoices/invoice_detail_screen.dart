import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/invoice_model.dart';
import '../../../models/student_model.dart';
import '../../../core/utils/pdf_generator.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onBack;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Find the actual student to get class/section info safely
    Student? student;
    try {
      student = dummyStudents.firstWhere(
        (s) => s.rollNumber.replaceAll('Roll: ', '').trim() == invoice.rollNumber.replaceAll('Roll: ', '').trim(),
        orElse: () => Student(
          id: '',
          firstName: 'Unknown',
          lastName: 'Student',
          email: '',
          rollNumber: invoice.rollNumber,
          grade: 'N/A',
          section: 'N/A',
          parentName: '',
          phone: '',
          parentEmail: '',
          avatarColor: '0xFFE0F7FA',
        ),
      );
    } catch (e) {
      student = Student(
        id: '',
        firstName: 'Unknown',
        lastName: 'Student',
        email: '',
        rollNumber: invoice.rollNumber,
        grade: 'N/A',
        section: 'N/A',
        parentName: '',
        phone: '',
        parentEmail: '',
        avatarColor: '0xFFE0F7FA',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Bar
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 16,
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios, size: 14, color: AppColors.textPrimary),
                    label: Text('Back to List', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Printing.layoutPdf(
                            onLayout: (format) => generateInvoicePdf(invoice, student!),
                            name: 'Invoice_${invoice.id}',
                          );
                        },
                        icon: const Icon(Icons.print_outlined, size: 18),
                        label: const Text('Print Invoice'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final bytes = await generateInvoicePdf(invoice, student!);
                          await Printing.sharePdf(
                            bytes: bytes,
                            filename: 'Invoice_${invoice.id}.pdf',
                          );
                        },
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Invoice Card
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: EdgeInsets.all(isMobile ? 24 : 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Header
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        runSpacing: 24,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('E', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('EDUSTREAM', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary, letterSpacing: 1)),
                                      Text('EXCELLENCE IN EDUCATION', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildContactInfo(Icons.location_on_outlined, '123 Education Square, Blue Area, Islamabad'),
                              const SizedBox(height: 8),
                              _buildContactInfo(Icons.phone_outlined, '+92 (51) 123-4567'),
                              const SizedBox(height: 8),
                              _buildContactInfo(Icons.email_outlined, 'billing@edustream.edu.pk'),
                              const SizedBox(height: 8),
                              _buildContactInfo(Icons.language_outlined, 'www.edustream.edu.pk'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                            children: [
                              Text('INVOICE', style: TextStyle(color: AppColors.success, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                              const SizedBox(height: 8),
                              Text('TRANSACTION ID', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              Text(invoice.id, style: AppTextStyles.h3),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.divider),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('CERTIFIED REGULATORY', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                        Text('Standard Invoice System', style: TextStyle(color: AppColors.textPrimary, fontSize: 10)),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.verified_outlined, color: AppColors.divider, size: 24),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Billing Details
                      if (isMobile) ...[
                        _buildInvoiceTo(isMobile, student!),
                        const SizedBox(height: 32),
                        _buildSubscriptionPeriod(isMobile),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: _buildInvoiceTo(isMobile, student!)),
                            const Spacer(flex: 1),
                            Expanded(flex: 4, child: _buildSubscriptionPeriod(isMobile)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 48),

                      // Fees Table
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F172A), // Dark blue
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('DESCRIPTION OF FEES', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  Text('AMOUNT (PKR)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ],
                              ),
                            ),
                            // Table Items
                            _buildFeeRow('Monthly Tuition Fee', 'ACADEMIC ITEM CODE: 101', invoice.amount.replaceAll('PKR ', '')),
                            const Divider(height: 1, color: AppColors.divider),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Totals
                      if (isMobile) ...[
                        _buildTotals(isMobile),
                        const SizedBox(height: 24),
                        Text(
                          'Additional adjustments or scholarships not applied...',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.divider, fontStyle: FontStyle.italic),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Text(
                                'Additional adjustments or scholarships not applied...',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.divider, fontStyle: FontStyle.italic),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: _buildTotals(isMobile),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 64),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 24),

                      // Footer
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        runSpacing: 24,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.barcode_reader, size: 40, color: AppColors.textPrimary),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('DIGITAL SYNC', style: TextStyle(color: AppColors.textSecondary, fontSize: 8)),
                                      Text('ID: ${invoice.id}', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('SCAN FOR VERIFICATION', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                            children: [
                              Text('AUTHORIZED SIGNATORY', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              Text('EDUSTREAM ACADEMIC BOARD', style: TextStyle(color: AppColors.textSecondary, fontSize: 8)),
                              const SizedBox(height: 16),
                              Container(
                                constraints: const BoxConstraints(maxWidth: 300),
                                child: Text(
                                  'Note: This is a system-generated invoice valid for the 2024 academic cycle. Please ensure payment is cleared before the due date to avoid late surcharges.',
                                  textAlign: isMobile ? TextAlign.left : TextAlign.right,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 8, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInvoiceTo(bool isMobile, Student student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INVOICE TO', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(invoice.studentName, style: AppTextStyles.h2),
              Text('ID: ${invoice.rollNumber.replaceAll('Roll: ', '')}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class:', style: AppTextStyles.bodySmall),
                        Text(student.grade, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Section:', style: AppTextStyles.bodySmall),
                        Text(student.section, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPeriod(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text('SUBSCRIPTION PERIOD', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        Text(invoice.billingMonth, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 32,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.start : WrapAlignment.end,
          children: [
            Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text('ISSUED DATE', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('May 1, 2024', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text('DUE DATE', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('May 10, 2024', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildStatusBadge(invoice.status),
      ],
    );
  }

  Widget _buildTotals(bool isMobile) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.bodyMedium),
              Text(invoice.amount.replaceAll('PKR ', ''), style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax (Gov)', style: AppTextStyles.bodyMedium),
              Text('0.00', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL BALANCE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text(invoice.amount, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.bodySmall), // Removed Flexible to prevent layout crash
      ],
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case InvoiceStatus.paid:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'Status: PAID';
        break;
      case InvoiceStatus.pending:
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'Status: PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status == InvoiceStatus.paid ? Icons.check_circle_outline : Icons.error_outline, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String title, String subtitle, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          Text(amount, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

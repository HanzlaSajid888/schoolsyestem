import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/invoice_model.dart';
import '../../models/student_model.dart';
import 'widgets/invoice_summary_cards.dart';
import 'widgets/invoice_data_table.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  Invoice? _selectedInvoice;
  String _searchQuery = '';

  void _generateBatchInvoices() {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    final defaultMonth = '${months[now.month - 1]} ${now.year}';
    final controller = TextEditingController(text: defaultMonth);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Batch Invoices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the billing month for this batch:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., June 2024',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final month = controller.text.trim();
              if (month.isNotEmpty) {
                int generatedCount = 0;
                setState(() {
                  for (final student in dummyStudents) {
                    // Check if an invoice already exists for this student and month
                    final exists = dummyInvoices.any((inv) => inv.rollNumber.contains(student.rollNumber.replaceAll('Roll: ', '')) && inv.billingMonth == month);
                    
                    if (!exists) {
                      // Determine fee amount
                      String amount = '5,000.00'; // Default
                      if (student.grade.contains('9')) {
                        amount = '5,500.00';
                      } else if (student.grade.contains('10')) {
                        amount = '6,500.00';
                      }

                      // Create invoice
                      final newInvoice = Invoice(
                        id: '#INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                        studentName: student.fullName,
                        rollNumber: 'Roll: ${student.rollNumber}',
                        billingMonth: month,
                        amount: 'PKR $amount',
                        status: InvoiceStatus.pending,
                      );
                      
                      dummyInvoices.insert(0, newInvoice); // Add to top
                      generatedCount++;
                    }
                  }
                });
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Generated $generatedCount new invoices for $month.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If an invoice is selected, show the detail screen
    if (_selectedInvoice != null) {
      return InvoiceDetailScreen(
        invoice: _selectedInvoice!,
        onBack: () {
          setState(() {
            _selectedInvoice = null;
          });
        },
      );
    }

    // Otherwise show the list
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fees & Invoices', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    'Manage billing, payments, and automated invoice generation.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _generateBatchInvoices,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Generate Batch Invoices'),
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
          const SizedBox(height: 32),
          
          // Summary Cards Row
          const InvoiceSummaryCards(),
          const SizedBox(height: 32),
          
          // Data Table
          InvoiceDataTable(
            searchQuery: _searchQuery,
            onSearchChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            onInvoiceTap: (invoice) {
              setState(() {
                _selectedInvoice = invoice;
              });
            },
            onMarkAsPaid: (invoice) {
              setState(() {
                invoice.status = InvoiceStatus.paid;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invoice ${invoice.id} marked as paid!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

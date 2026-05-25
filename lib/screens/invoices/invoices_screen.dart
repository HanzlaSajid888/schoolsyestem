import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/invoice_model.dart';
import '../../core/api/invoice_api.dart';
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
  
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);
    try {
      final invoices = await InvoiceApi.getInvoices();
      if (mounted) {
        setState(() {
          _invoices = invoices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching invoices: $e')));
      }
    }
  }

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
            onPressed: () async {
              final month = controller.text.trim();
              if (month.isNotEmpty) {
                Navigator.pop(context); // Close dialog first
                try {
                  await InvoiceApi.generateBatchInvoices(month);
                  _fetchInvoices(); // Refresh list after batch generation
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Batch invoice generation requested for $month.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
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
            invoices: _invoices,
            isLoading: _isLoading,
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
            onMarkAsPaid: (invoice) async {
              try {
                await InvoiceApi.markAsPaid(invoice.id);
                _fetchInvoices(); // Refresh the list
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invoice ${invoice.id} marked as paid!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error marking as paid: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

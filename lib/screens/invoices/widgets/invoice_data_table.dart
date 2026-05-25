import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/invoice_model.dart';

class InvoiceDataTable extends StatelessWidget {
  final List<Invoice> invoices;
  final bool isLoading;
  final Function(Invoice) onInvoiceTap;
  final Function(Invoice)? onMarkAsPaid;
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;

  const InvoiceDataTable({
    super.key,
    required this.invoices,
    this.isLoading = false,
    required this.onInvoiceTap,
    this.onMarkAsPaid,
    this.searchQuery = '',
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
    }

    final filteredInvoices = invoices.where((invoice) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      return invoice.studentName.toLowerCase().contains(query) ||
             invoice.rollNumber.toLowerCase().contains(query) ||
             invoice.id.toLowerCase().contains(query);
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 1000,
              maxWidth: constraints.maxWidth > 1000 ? constraints.maxWidth : 1000,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Action Bar
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          width: constraints.maxWidth > 500 ? 400 : constraints.maxWidth - 48,
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            onChanged: onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search invoices by name, roll no, or ID...',
                              hintStyle: AppTextStyles.bodyMedium,
                              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: const Text('Export'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.divider),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: AppColors.background.withOpacity(0.5), // Slight off-white background
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _buildHeaderCell('INVOICE ID')),
                        Expanded(flex: 3, child: _buildHeaderCell('STUDENT')),
                        Expanded(flex: 2, child: _buildHeaderCell('BILLING MONTH')),
                        Expanded(flex: 2, child: _buildHeaderCell('AMOUNT')),
                        Expanded(flex: 2, child: _buildHeaderCell('STATUS')),
                        Expanded(flex: 1, child: _buildHeaderCell('ACTIONS', alignRight: true)),
                      ],
                    ),
                  ),
                  
                  // Table Rows
                  if (filteredInvoices.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(48),
                      child: const Center(
                        child: Text('Not available', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ),
                    )
                  else
                    ...filteredInvoices.map((invoice) => _buildDataRow(invoice)),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeaderCell(String title, {bool alignRight = false}) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
    );
  }

  Widget _buildDataRow(Invoice invoice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Invoice ID
          Expanded(
            flex: 2,
            child: Text(
              invoice.id,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Student Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.studentName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(invoice.rollNumber, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          // Billing Month
          Expanded(
            flex: 2,
            child: Text(
              invoice.billingMonth,
              style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          // Amount
          Expanded(
            flex: 2,
            child: Text(invoice.amount, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          ),
          // Status Badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(invoice.status),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (invoice.status == InvoiceStatus.pending)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 20, color: AppColors.success),
                    tooltip: 'Mark as Paid',
                    onPressed: () => onMarkAsPaid?.call(invoice),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (invoice.status == InvoiceStatus.pending)
                  const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: AppColors.primary),
                  tooltip: 'View Details',
                  onPressed: () => onInvoiceTap(invoice),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case InvoiceStatus.paid:
        bgColor = AppColors.success.withOpacity(0.15);
        textColor = AppColors.success;
        label = 'PAID';
        break;
      case InvoiceStatus.pending:
        bgColor = AppColors.warning.withOpacity(0.15);
        textColor = AppColors.warning;
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

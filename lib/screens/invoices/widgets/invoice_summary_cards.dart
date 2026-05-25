import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/api/dashboard_api.dart';

class InvoiceSummaryCards extends StatefulWidget {
  const InvoiceSummaryCards({super.key});

  @override
  State<InvoiceSummaryCards> createState() => _InvoiceSummaryCardsState();
}

class _InvoiceSummaryCardsState extends State<InvoiceSummaryCards> {
  bool _isLoading = true;
  double _totalPendingAmount = 0;
  double _totalRevenue = 0;
  int _pendingInvoicesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final summary = await DashboardApi.getSummary();
      if (mounted) {
        setState(() {
          _totalPendingAmount = (summary['totalPendingAmount'] ?? 0).toDouble();
          _totalRevenue = (summary['totalRevenue'] ?? 0).toDouble();
          _pendingInvoicesCount = summary['pendingInvoicesCount'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32) / 3;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildCard(
              title: 'TOTAL OUTSTANDING',
              value: 'PKR ${_totalPendingAmount.toStringAsFixed(2)}',
              iconData: Icons.access_time,
              iconColor: AppColors.warning,
              width: constraints.maxWidth > 800 ? cardWidth : constraints.maxWidth,
            ),
            _buildCard(
              title: 'TOTAL COLLECTED',
              value: 'PKR ${_totalRevenue.toStringAsFixed(2)}',
              iconData: Icons.check_circle_outline,
              iconColor: AppColors.success,
              width: constraints.maxWidth > 800 ? cardWidth : constraints.maxWidth,
            ),
            _buildCard(
              title: 'PENDING INVOICES',
              value: '$_pendingInvoicesCount',
              iconData: Icons.error_outline,
              iconColor: AppColors.error,
              width: constraints.maxWidth > 800 ? cardWidth : constraints.maxWidth,
            ),
          ],
        );
      }
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData iconData,
    required Color iconColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.h2),
            ],
          ),
        ],
      ),
    );
  }
}

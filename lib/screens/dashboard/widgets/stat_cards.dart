import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/api/dashboard_api.dart';

class StatCardsRow extends StatefulWidget {
  const StatCardsRow({super.key});

  @override
  State<StatCardsRow> createState() => _StatCardsRowState();
}

class _StatCardsRowState extends State<StatCardsRow> {
  bool _isLoading = true;
  int _totalStudents = 0;
  double _totalRevenue = 0;
  int _pendingInvoicesCount = 0;
  double _totalPendingAmount = 0;

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
          _totalStudents = summary['totalStudents'] ?? 0;
          _totalRevenue = (summary['totalRevenue'] ?? 0).toDouble();
          _pendingInvoicesCount = summary['pendingInvoicesCount'] ?? 0;
          _totalPendingAmount = (summary['totalPendingAmount'] ?? 0).toDouble();
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
      return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 48) / 4;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'TOTAL STUDENTS',
              value: '$_totalStudents',
              iconData: Icons.people_outline,
              iconColor: AppColors.primary,
              width: constraints.maxWidth > 800 ? cardWidth : (constraints.maxWidth > 450 ? constraints.maxWidth / 2 - 8 : constraints.maxWidth),
            ),
            _buildStatCard(
              title: 'TOTAL FEES COLLECTED',
              value: 'PKR ${_totalRevenue.toStringAsFixed(2)}',
              iconData: Icons.currency_exchange,
              iconColor: AppColors.success,
              width: constraints.maxWidth > 800 ? cardWidth : (constraints.maxWidth > 450 ? constraints.maxWidth / 2 - 8 : constraints.maxWidth),
            ),
            _buildStatCard(
              title: 'PENDING INVOICES',
              value: '$_pendingInvoicesCount',
              iconData: Icons.receipt_long,
              iconColor: AppColors.warning,
              width: constraints.maxWidth > 800 ? cardWidth : (constraints.maxWidth > 450 ? constraints.maxWidth / 2 - 8 : constraints.maxWidth),
            ),
            _buildStatCard(
              title: 'TOTAL PENDING AMOUNT',
              value: 'PKR ${_totalPendingAmount.toStringAsFixed(2)}',
              iconData: Icons.access_time,
              iconColor: AppColors.error,
              width: constraints.maxWidth > 800 ? cardWidth : (constraints.maxWidth > 450 ? constraints.maxWidth / 2 - 8 : constraints.maxWidth),
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData iconData,
    required Color iconColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.metricValue),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

class InvoiceSummaryCards extends StatelessWidget {
  const InvoiceSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32) / 3;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildCard(
              title: 'TOTAL OUTSTANDING',
              value: 'PKR 120,000.00',
              iconData: Icons.access_time,
              iconColor: AppColors.warning,
              width: constraints.maxWidth > 800 ? cardWidth : constraints.maxWidth,
            ),
            _buildCard(
              title: 'COLLECTED THIS MONTH',
              value: 'PKR 580,000.00',
              iconData: Icons.check_circle_outline,
              iconColor: AppColors.success,
              width: constraints.maxWidth > 800 ? cardWidth : constraints.maxWidth,
            ),
            _buildCard(
              title: 'OVERDUE PAYMENTS',
              value: 'PKR 45,000.00',
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

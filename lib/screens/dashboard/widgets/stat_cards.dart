import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

class StatCardsRow extends StatelessWidget {
  const StatCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 48) / 4;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'TOTAL STUDENTS',
              value: '1,250',
              change: '+5%',
              isPositive: true,
              iconData: Icons.people_outline,
              iconColor: AppColors.primary,
              width: constraints.maxWidth > 800 ? cardWidth : (constraints.maxWidth > 450 ? constraints.maxWidth / 2 - 8 : constraints.maxWidth),
            ),
            _buildStatCard(
              title: 'TOTAL FEES COLLECTED',
              value: 'PKR 850,000.00',
              change: '+12%',
              isPositive: true,
              iconData: Icons.currency_exchange,
              iconColor: AppColors.success,
              width: constraints.maxWidth > 800 ? cardWidth : (constraints.maxWidth > 450 ? constraints.maxWidth / 2 - 8 : constraints.maxWidth),
            ),
            _buildStatCard(
              title: 'PENDING FEES',
              value: 'PKR 120,000.00',
              change: '-2%',
              isPositive: false,
              iconData: Icons.access_time,
              iconColor: AppColors.warning,
              width: constraints.maxWidth > 800 ? cardWidth : (constraints.maxWidth > 450 ? constraints.maxWidth / 2 - 8 : constraints.maxWidth),
            ),
            _buildStatCard(
              title: 'COLLECTION RATE',
              value: '85%',
              change: '+3%',
              isPositive: true,
              iconData: Icons.trending_up,
              iconColor: AppColors.purple,
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
    required String change,
    required bool isPositive,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? AppColors.success : AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text('vs last period', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import 'widgets/stat_cards.dart';
import 'widgets/fee_trend_chart.dart';
import 'widgets/academic_calendar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Text('Dashboard Summary', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back! Here\'s what\'s happening with EduStream today.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Stat Cards
          const StatCardsRow(),
          const SizedBox(height: 32),
          
          // Chart and Calendar
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1000) {
                // Large screen layout
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: FeeTrendChart(),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 380, // Match chart approx height
                        child: AcademicCalendar(),
                      ),
                    ),
                  ],
                );
              } else {
                // Smaller screen layout (tablet/mobile)
                return Column(
                  children: [
                    const FeeTrendChart(),
                    const SizedBox(height: 24),
                    const SizedBox(
                      height: 380,
                      child: AcademicCalendar(),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

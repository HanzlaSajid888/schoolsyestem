import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

import '../../../core/api/dashboard_api.dart';

class FeeTrendChart extends StatefulWidget {
  const FeeTrendChart({super.key});

  @override
  State<FeeTrendChart> createState() => _FeeTrendChartState();
}

class _FeeTrendChartState extends State<FeeTrendChart> {
  List<BarChartGroupData> _barGroups = [];
  List<String> _months = [];
  bool _isLoading = true;
  int _selectedMonths = 6;
  double _maxY = 800;

  @override
  void initState() {
    super.initState();
    _fetchTrends();
  }

  Future<void> _fetchTrends() async {
    setState(() => _isLoading = true);
    try {
      final trends = await DashboardApi.getTrends(months: _selectedMonths);
      if (trends.isNotEmpty) {
        final List<BarChartGroupData> newBarGroups = [];
        final List<String> newMonths = [];
        double tempMaxY = 0;
        
        for (int i = 0; i < trends.length && i < _selectedMonths; i++) {
          final trend = trends[i];
          final double totalExpected = (trend['totalExpected'] ?? 0).toDouble() / 1000;
          final double paid = (trend['paidAmount'] ?? 0).toDouble() / 1000;
          
          if (totalExpected > tempMaxY) tempMaxY = totalExpected;

          newBarGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: totalExpected,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  rodStackItems: [
                    BarChartRodStackItem(0, paid, AppColors.primary),
                    BarChartRodStackItem(paid, totalExpected, AppColors.primary.withOpacity(0.3)),
                  ],
                ),
              ],
            ),
          );
          newMonths.add(trend['month']?.toString().substring(0, 3) ?? '');
        }
        
        // Pad with zeros if less than selected
        while (newBarGroups.length < _selectedMonths) {
          newBarGroups.add(
            BarChartGroupData(
              x: newBarGroups.length,
              barRods: [
                BarChartRodData(toY: 0, width: 16),
              ],
            ),
          );
          newMonths.add('');
        }

        double calculatedMax = tempMaxY * 1.2;
        if (calculatedMax < 100) calculatedMax = 100;

        // Create empty bars for initial state to trigger entry animation
        final emptyBars = newBarGroups.map((g) => BarChartGroupData(
          x: g.x, 
          barRods: [BarChartRodData(toY: 0, width: 16)]
        )).toList();

        setState(() {
          _barGroups = emptyBars;
          _months = newMonths;
          _maxY = calculatedMax;
          _isLoading = false;
        });

        // Wait slightly, then set the real values so fl_chart animates them
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _barGroups = newBarGroups;
            });
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching trends: $e');
    }
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fee Collection Trend', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Monthly collection overview', style: AppTextStyles.bodyMedium),
                      const SizedBox(width: 16),
                      _buildLegendItem('Paid', AppColors.primary),
                      const SizedBox(width: 12),
                      _buildLegendItem('Pending', AppColors.primary.withOpacity(0.3)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedMonths,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('Last 3 Months')),
                      DropdownMenuItem(value: 6, child: Text('Last 6 Months')),
                      DropdownMenuItem(value: 12, child: Text('Last 12 Months')),
                    ],
                    onChanged: (val) {
                      if (val != null && val != _selectedMonths) {
                        setState(() {
                          _selectedMonths = val;
                        });
                        _fetchTrends();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _isLoading 
            ? const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()))
            : SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY > 0 ? _maxY / 4 : 200,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.divider.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: AppColors.textSecondary, fontSize: 12);
                        Widget text;
                        final index = value.toInt();
                        if (index >= 0 && index < _months.length) {
                          text = Text(_months[index], style: style);
                        } else {
                          text = const Text('', style: style);
                        }
                        return SideTitleWidget(meta: meta, child: text);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _maxY > 0 ? _maxY / 4 : 200,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text('Rs.${value.toInt()}k', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _barGroups,
                maxY: _maxY,
                alignment: BarChartAlignment.spaceAround,
              ),
              swapAnimationDuration: const Duration(milliseconds: 1000),
              swapAnimationCurve: Curves.easeOutQuart,
            ),
          ),
        ],
      ),
    );
  }
}

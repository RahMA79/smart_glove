import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/progress_point.dart';
import 'progress_stats_row.dart';

class ProgressLineChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final List<ProgressPoint> points;

  const ProgressLineChartCard({
    super.key,
    required this.title,
    required this.unit,
    required this.points,
  });

  double _avgY() => points.isEmpty
      ? 0
      : points.map((p) => p.y).reduce((a, b) => a + b) / points.length;

  double _maxY() => points.isEmpty
      ? 0
      : points.map((p) => p.y).reduce((a, b) => a > b ? a : b);
  double _minY() => points.isEmpty
      ? 0
      : points.map((p) => p.y).reduce((a, b) => a < b ? a : b);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.65);

    final avg = _avgY();
    final max = _maxY();
    final min = _minY();

    final spots = points.map((p) => FlSpot(p.x, p.y)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (max - min) == 0 ? 1 : (max - min) / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: onSurface.withOpacity(0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (v, meta) => Text(
                        v.toStringAsFixed(0),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (v, meta) => Text(
                        v.toStringAsFixed(0),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: points.isEmpty ? 0 : points.first.x,
                maxX: points.isEmpty ? 0 : points.last.x,
                minY: min - ((max - min) * 0.15),
                maxY: max + ((max - min) * 0.15),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 3.5,
                            color: primary,
                            strokeWidth: 2,
                            strokeColor: theme.cardColor,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          primary.withOpacity(0.20),
                          primary.withOpacity(0.00),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          ProgressStatsRow(
            leftLabel: "Average",
            leftValue: "${avg.toStringAsFixed(2)} $unit",
            rightLabel: "Max / Min",
            rightValue: "${max.toStringAsFixed(1)} / ${min.toStringAsFixed(1)}",
          ),
        ],
      ),
    );
  }
}

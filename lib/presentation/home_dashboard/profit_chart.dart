import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_summary.dart';

/// The monthly/quarterly profit bar chart (01_PRD.md §4.6). Colour encodes
/// polarity only — Coinbase Blue for profit, semantic red for a loss period —
/// and every bar is *also* labelled with its value in text, so the chart never
/// relies on colour alone (WCAG: colour is not the sole information channel; the
/// blue `#0052ff` and red both clear AA contrast on the card surface). Tapping a
/// bar drills into that exact period.
class ProfitChart extends StatelessWidget {
  final List<PeriodProfit> series;
  final ValueChanged<PeriodProfit> onBarTap;

  const ProfitChart({super.key, required this.series, required this.onBarTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (series.every((p) => p.profitPaisa == 0)) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text('No profit or loss recorded yet.',
              style: TextStyle(color: c.muted)),
        ),
      );
    }

    final maxProfit = series
        .map((p) => p.profitPaisa)
        .fold<int>(0, (a, b) => b > a ? b : a);
    final minProfit = series
        .map((p) => p.profitPaisa)
        .fold<int>(0, (a, b) => b < a ? b : a);
    // Headroom above/below so the value labels never clip.
    final maxY = (maxProfit == 0 ? 1 : maxProfit) * 1.35;
    final minY = minProfit == 0 ? 0.0 : minProfit * 1.35;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY.toDouble(),
          minY: minY.toDouble(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => c.surfaceDark,
              getTooltipItem: (group, _, rod, _) {
                final p = series[group.x];
                return BarTooltipItem(
                  '${p.label}\n',
                  monoStyle(size: 11, color: c.onDarkSoft),
                  children: [
                    TextSpan(
                      text: _compact(p.profitPaisa, withSign: true),
                      style: monoStyle(
                          size: 13,
                          weight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (event, response) {
              if (event is FlTapUpEvent &&
                  response?.spot != null) {
                onBarTap(series[response!.spot!.touchedBarGroupIndex]);
              }
            },
          ),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= series.length) return const SizedBox();
                  final p = series[i];
                  if (p.profitPaisa == 0) return const SizedBox();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(_compact(p.profitPaisa),
                        style: monoStyle(size: 10, color: c.muted)),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= series.length) return const SizedBox();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(series[i].label,
                        style: monoStyle(size: 11, color: c.body)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < series.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: series[i].profitPaisa.toDouble(),
                    width: 18,
                    color: series[i].profitPaisa >= 0
                        ? c.primary
                        : c.semanticDown,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact rupee label for axis/tooltip use, e.g. `12k`, `1.2L`, `-8k`. Display
/// only — the exact figure lives in the drill-down (Paisa integers everywhere).
String _compact(int paisa, {bool withSign = false}) {
  final rupees = paisa ~/ 100;
  final sign = rupees < 0 ? '-' : (withSign && rupees > 0 ? '+' : '');
  final a = rupees.abs();
  String body;
  if (a >= 10000000) {
    body = '${(a / 10000000).toStringAsFixed(1)}Cr';
  } else if (a >= 100000) {
    body = '${(a / 100000).toStringAsFixed(1)}L';
  } else if (a >= 1000) {
    body = '${(a / 1000).toStringAsFixed(a >= 10000 ? 0 : 1)}k';
  } else {
    body = '$a';
  }
  return '$sign$body';
}

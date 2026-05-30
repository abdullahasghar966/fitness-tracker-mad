import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/fitness_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/volume_scroll_list.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedPeriod = 1; // 0=1W, 1=1M, 2=3M, 3=6M
  static const List<String> _periods = ['1W', '1M', '3M', '6M'];

  List<double> _filterWeightData(List<double> data) {
    if (data.isEmpty) return data;
    // Map period index to number of data points to show.
    // Data points represent weekly measurements (1 point ≈ 1 week).
    const counts = [2, 4, 8, 12]; // 1W, 1M, 3M, 6M
    final count = counts[_selectedPeriod];
    if (data.length <= count) return data;
    return data.sublist(data.length - count);
  }

  void _showBodyMeasurementDialog(FitnessProvider provider,
      {String? key, double? value}) {
    final nameController = TextEditingController(text: key ?? '');
    final valueController =
    TextEditingController(text: value?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(key == null ? 'Add Measurement' : 'Edit Measurement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Measurement Name'),
              ),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Value (cm)'),
              ),
            ],
          ),
          actions: [
            if (key != null)
              TextButton(
                onPressed: () {
                  provider.deleteMeasurement(key);
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final val = double.tryParse(valueController.text) ?? 0.0;
                if (name.isEmpty) return;

                if (key == null) {
                  provider.addMeasurement(name, val);
                } else {
                  provider.editMeasurement(key, name, val);
                }
                Navigator.pop(context);
              },
              child: Text(key == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _showWeightDialog(FitnessProvider provider, {double? weight, int? index}) {
    final controller = TextEditingController(text: weight?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(weight == null ? 'Add Weight' : 'Edit Weight'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          actions: [
            if (weight != null)
              TextButton(
                onPressed: () {
                  provider.deleteWeight(index!);
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final w = double.tryParse(controller.text) ?? 0.0;
                if (weight == null) {
                  provider.addWeight(w);
                } else {
                  provider.editWeight(index!, w);
                }
                Navigator.pop(context);
              },
              child: Text(weight == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FitnessProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'PROGRESS',
          style: GoogleFonts.barlowCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showWeightDialog(provider),
            icon: const Icon(Icons.add, color: AppColors.accent),
          )
        ],
      ),
      body: VolumeScrollList(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        children: [
          // Period Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Row(
              children: List.generate(_periods.length, (index) {
                final isSelected = _selectedPeriod == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        _periods[index],
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.black
                              : AppColors.textMuted,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Weight Trend Chart
          Text(
            'WEIGHT TREND',
            style: GoogleFonts.barlowCondensed(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                provider.weightData.isNotEmpty
                    ? '${provider.weightData.last} kg'
                    : '0 kg',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (provider.weightData.length > 1)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        provider.weightData.last <
                            provider.weightData.first
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 12,
                        color: const Color(0xFF2ECC71),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${(provider.weightData.last - provider.weightData.first).toStringAsFixed(1)} kg',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2ECC71),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: provider.weightData.isEmpty
                ? const Center(child: Text('No weight data'))
                : Builder(builder: (context) {
                    final filtered = _filterWeightData(provider.weightData);
                    return LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx % 2 != 0) return const SizedBox.shrink();
                                return Text(
                                  'W${idx + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                );
                              },
                              reservedSize: 22,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              filtered.length,
                              (i) => FlSpot(i.toDouble(), filtered[i]),
                            ),
                            isCurved: true,
                            color: AppColors.accent,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.3),
                                  AppColors.accent.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                        minY: filtered.reduce((a, b) => a < b ? a : b) - 1,
                        maxY: filtered.reduce((a, b) => a > b ? a : b) + 1,
                      ),
                    );
                  }),
          ),

          const SizedBox(height: 24),

          // Body Measurements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BODY MEASUREMENTS',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.accent),
                onPressed: () => _showBodyMeasurementDialog(provider),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Column(
              children: provider.bodyMeasurements.entries
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final measurement = entry.value;
                final isLast = index == provider.bodyMeasurements.length - 1;

                return GestureDetector(
                  onTap: () => _showBodyMeasurementDialog(
                      provider,
                      key: measurement.key,
                      value: measurement.value),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : const Border(
                        bottom: BorderSide(
                            color: AppColors.divider, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.straighten_outlined,
                            size: 18,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          measurement.key,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${measurement.value}',
                                style: GoogleFonts.barlowCondensed(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: ' cm',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
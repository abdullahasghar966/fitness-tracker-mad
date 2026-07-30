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

  Future<void> _showBodyMeasurementDialog(FitnessProvider provider,
      {String? key, double? value}) async {
    final result = await showDialog<_MeasurementResult>(
      context: context,
      builder: (_) => _MeasurementDialog(initialName: key, initialValue: value),
    );
    if (result == null) return;

    if (result.delete) {
      provider.deleteMeasurement(key!);
    } else if (key == null) {
      provider.addMeasurement(result.name, result.value);
    } else {
      provider.editMeasurement(key, result.name, result.value);
    }
  }

  Future<void> _showWeightDialog(FitnessProvider provider,
      {double? weight, int? index}) async {
    final result = await showDialog<_WeightResult>(
      context: context,
      builder: (_) => _WeightDialog(initialWeight: weight),
    );
    if (result == null) return;

    if (result.delete) {
      provider.deleteWeight(index!);
    } else if (weight == null) {
      provider.addWeight(result.value);
    } else {
      provider.editWeight(index!, result.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FitnessProvider>();

    // Computed once so the trend badge and the chart below always describe
    // the same period. (The badge used to read the full dataset while the
    // chart showed the filtered window.)
    final filtered = _filterWeightData(provider.weightData);
    final hasTrend = filtered.length > 1;
    final delta = hasTrend ? filtered.last - filtered.first : 0.0;
    // Losing weight is the app's goal, so a drop reads as positive.
    final isLoss = delta < 0;
    final trendColor = delta == 0
        ? AppColors.textMuted
        : (isLoss ? const Color(0xFF2ECC71) : AppColors.accentRed);

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
                    ? '${provider.weightData.last.toStringAsFixed(1)} kg'
                    : '—',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (hasTrend)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        delta == 0
                            ? Icons.remove
                            : (isLoss
                                ? Icons.arrow_downward
                                : Icons.arrow_upward),
                        size: 12,
                        color: trendColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        // Direction lives in the arrow, so show magnitude only.
                        '${delta.abs().toStringAsFixed(1)} kg',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: trendColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _periods[_selectedPeriod],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: trendColor.withValues(alpha: 0.8),
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
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No weight data yet — tap + to add one',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : LineChart(
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
                  ),
          ),

          const SizedBox(height: 20),

          // Recent weight entries — tap one to edit or delete it.
          // (Without this the editWeight/deleteWeight paths were unreachable.)
          if (filtered.isNotEmpty) ...[
            Text(
              'RECENT ENTRIES',
              style: GoogleFonts.barlowCondensed(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap an entry to edit or delete it',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(filtered.length, (i) {
                // Map the filtered position back to its index in the full list.
                final realIndex =
                    provider.weightData.length - filtered.length + i;
                final value = filtered[i];
                final isLatest = realIndex == provider.weightData.length - 1;

                return GestureDetector(
                  onTap: () => _showWeightDialog(
                    provider,
                    weight: value,
                    index: realIndex,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLatest
                          ? AppColors.accent.withValues(alpha: 0.12)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLatest
                            ? AppColors.accent
                            : AppColors.divider,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${value.toStringAsFixed(1)} kg',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isLatest
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
          ] else
            const SizedBox(height: 4),

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
                                text: measurement.value % 1 == 0
                                    ? '${measurement.value.toInt()}'
                                    : measurement.value.toStringAsFixed(1),
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

// ─────────────────────────────────────────────────────────────────────────────
// Dialogs
//
// Each dialog is a StatefulWidget so it owns — and disposes — its own
// controllers. Disposing right after `await showDialog` would risk a
// "used after being disposed" error while the dismissal animation still
// renders the fields.
// ─────────────────────────────────────────────────────────────────────────────

class _MeasurementResult {
  final String name;
  final double value;
  final bool delete;

  const _MeasurementResult(this.name, this.value, {this.delete = false});
}

class _WeightResult {
  final double value;
  final bool delete;

  const _WeightResult(this.value, {this.delete = false});
}

class _MeasurementDialog extends StatefulWidget {
  final String? initialName;
  final double? initialValue;

  const _MeasurementDialog({this.initialName, this.initialValue});

  @override
  State<_MeasurementDialog> createState() => _MeasurementDialogState();
}

class _MeasurementDialogState extends State<_MeasurementDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _valueCtrl;
  String? _nameError;
  String? _valueError;

  bool get _isEdit => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _valueCtrl = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final value = double.tryParse(_valueCtrl.text.trim());

    setState(() {
      _nameError = name.isEmpty ? 'Enter a measurement name' : null;
      _valueError = (value == null || value <= 0)
          ? 'Enter a value greater than 0'
          : null;
    });

    if (name.isEmpty || value == null || value <= 0) return;
    Navigator.pop(context, _MeasurementResult(name, value));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _isEdit ? 'EDIT MEASUREMENT' : 'ADD MEASUREMENT',
        style: GoogleFonts.barlowCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: !_isEdit,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Measurement Name',
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _valueCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Value (cm)',
              errorText: _valueError,
            ),
          ),
        ],
      ),
      actions: [
        if (_isEdit)
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              const _MeasurementResult('', 0, delete: true),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Text(_isEdit ? 'SAVE' : 'ADD'),
        ),
      ],
    );
  }
}

class _WeightDialog extends StatefulWidget {
  final double? initialWeight;

  const _WeightDialog({this.initialWeight});

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  late final TextEditingController _ctrl;
  String? _error;

  bool get _isEdit => widget.initialWeight != null;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialWeight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_ctrl.text.trim());
    setState(() {
      _error = (value == null || value <= 0)
          ? 'Enter a weight greater than 0'
          : null;
    });
    if (value == null || value <= 0) return;
    Navigator.pop(context, _WeightResult(value));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _isEdit ? 'EDIT WEIGHT' : 'ADD WEIGHT',
        style: GoogleFonts.barlowCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: 'Weight (kg)',
          errorText: _error,
        ),
      ),
      actions: [
        if (_isEdit)
          TextButton(
            onPressed: () =>
                Navigator.pop(context, const _WeightResult(0, delete: true)),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Text(_isEdit ? 'SAVE' : 'ADD'),
        ),
      ],
    );
  }
}
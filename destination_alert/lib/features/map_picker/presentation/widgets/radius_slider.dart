import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Reusable radius selector widget offering both preset chips and a continuous slider.
class RadiusSlider extends StatelessWidget {
  final double selectedRadiusMeters;
  final ValueChanged<double> onRadiusChanged;
  final List<double> presetOptions;
  final double minMeters;
  final double maxMeters;

  const RadiusSlider({
    super.key,
    required this.selectedRadiusMeters,
    required this.onRadiusChanged,
    this.presetOptions = const [100.0, 250.0, 500.0, 1000.0, 2000.0],
    this.minMeters = 50.0,
    this.maxMeters = 3000.0,
  });

  String _formatRadius(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return '${km.toStringAsFixed(km.truncateToDouble() == km ? 0 : 1)} km';
    }
    return '${meters.round()} m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alarm Trigger Radius',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _formatRadius(selectedRadiusMeters),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presetOptions.map((radius) {
              final isSelected = (selectedRadiusMeters - radius).abs() < 5;
              final label = _formatRadius(radius);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: Key('preset_chip_${radius.round()}'),
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      onRadiusChanged(radius);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.16),
          ),
          child: Slider(
            value: selectedRadiusMeters.clamp(minMeters, maxMeters),
            min: minMeters,
            max: maxMeters,
            divisions: 59, // 50m intervals
            onChanged: (val) {
              onRadiusChanged(val.roundToDouble());
            },
          ),
        ),
      ],
    );
  }
}

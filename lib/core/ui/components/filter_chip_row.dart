import 'package:flutter/material.dart';
import '../tokens.dart';

/// Horizontal scrolling row of filter chips
/// 
/// UI-only component. Selected index is managed by parent.
class FilterChipRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: labels.length,
        separatorBuilder: (context, index) => const SizedBox(
          width: AppSpacing.xs,
        ),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return FilterChip(
            label: Text(labels[index]),
            selected: isSelected,
            onSelected: (_) => onSelected(index),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}


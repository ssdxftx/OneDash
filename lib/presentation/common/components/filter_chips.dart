import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class AppFilterChips<T> extends StatelessWidget {
  const AppFilterChips({
    super.key,
    required this.options,
    required this.labelOf,
    required this.selected,
    required this.onChanged,
    this.multiSelect = false,
    this.padding = const EdgeInsets.only(
      left: AppTokens.s16,
      right: AppTokens.s24,
    ),
  });

  final List<T> options;
  final String Function(T option) labelOf;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool multiSelect;
  final EdgeInsetsGeometry padding;

  void _toggle(T option) {
    if (multiSelect) {
      final next = Set<T>.of(selected);
      if (!next.add(option)) next.remove(option);
      onChanged(next);
      return;
    }
    onChanged({option});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final resolvedPadding = padding.resolve(Directionality.of(context));
    return SizedBox(
      height: 48,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            scheme.surface.withValues(alpha: 0),
            scheme.surface,
            scheme.surface,
            scheme.surface.withValues(alpha: 0),
          ],
          stops: const [0, 0.04, 0.96, 1],
        ).createShader(bounds),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: resolvedPadding.left,
            right: resolvedPadding.right,
          ),
          itemCount: options.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppTokens.s8),
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = selected.contains(option);
            return Center(
              child: FilterChip(
                selected: isSelected,
                showCheckmark: false,
                label: Text(labelOf(option)),
                onSelected: (_) => _toggle(option),
                backgroundColor: scheme.surfaceContainerLow,
                selectedColor: scheme.primaryContainer,
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : scheme.outlineVariant,
                ),
                labelStyle: AppTextStyles.label.copyWith(
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8),
              ),
            );
          },
        ),
      ),
    );
  }
}

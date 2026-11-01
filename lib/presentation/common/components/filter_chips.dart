import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class AppFilterChips<T> extends StatefulWidget {
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

  @override
  State<AppFilterChips<T>> createState() => _AppFilterChipsState<T>();
}

class _AppFilterChipsState<T> extends State<AppFilterChips<T>> {
  final ScrollController _controller = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateEdges);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateEdges());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateEdges)
      ..dispose();
    super.dispose();
  }

  void _updateEdges() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final canLeft = position.pixels > 0.5;
    final canRight = position.pixels < position.maxScrollExtent - 0.5;
    if (canLeft == _canScrollLeft && canRight == _canScrollRight) return;
    setState(() {
      _canScrollLeft = canLeft;
      _canScrollRight = canRight;
    });
  }

  void _toggle(T option) {
    if (widget.multiSelect) {
      final next = Set<T>.of(widget.selected);
      if (!next.add(option)) next.remove(option);
      widget.onChanged(next);
      return;
    }
    widget.onChanged({option});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final resolvedPadding = widget.padding.resolve(Directionality.of(context));
    return SizedBox(
      height: 48,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            if (_canScrollLeft)
              scheme.surface.withValues(alpha: 0)
            else
              scheme.surface,
            scheme.surface,
            scheme.surface,
            if (_canScrollRight)
              scheme.surface.withValues(alpha: 0)
            else
              scheme.surface,
          ],
          stops: const [0, 0.08, 0.92, 1],
        ).createShader(bounds),
        child: ListView.separated(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: resolvedPadding.left,
            right: resolvedPadding.right,
          ),
          itemCount: widget.options.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppTokens.s8),
          itemBuilder: (context, index) {
            final option = widget.options[index];
            final isSelected = widget.selected.contains(option);
            return Center(
              child: FilterChip(
                selected: isSelected,
                showCheckmark: false,
                label: Text(widget.labelOf(option)),
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

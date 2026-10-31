import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: AppTokens.s16),
    this.scrollable = true,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final tabs = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      final selected = i == selectedIndex;
      tabs.add(
        InkWell(
          onTap: () => onChanged(i),
          borderRadius: BorderRadius.circular(AppTokens.rSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s12,
              vertical: AppTokens.s12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labels[i],
                  style: AppTextStyles.label.copyWith(
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: context.motion(AppTokens.dBase),
                  curve: AppTokens.curveBase,
                  height: 3,
                  width: selected ? 20 : 0,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(AppTokens.rFull),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final row = Row(mainAxisSize: MainAxisSize.min, children: tabs);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: padding,
              child: row,
            )
          : Padding(
              padding: padding,
              child: Row(
                children: [
                  for (final tab in tabs) Expanded(child: Center(child: tab)),
                ],
              ),
            ),
    );
  }
}

/// 带淡入淡出内容切换的分段视图。
class SegmentedTabsView extends StatefulWidget {
  const SegmentedTabsView({
    super.key,
    required this.labels,
    required this.children,
    this.initialIndex = 0,
    this.onChanged,
    this.scrollable = true,
    this.keepAlive = true,
  });

  final List<String> labels;
  final List<Widget> children;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final bool scrollable;
  final bool keepAlive;

  @override
  State<SegmentedTabsView> createState() => _SegmentedTabsViewState();
}

class _SegmentedTabsViewState extends State<SegmentedTabsView> {
  late int _index = widget.initialIndex;
  late final Set<int> _visited = {widget.initialIndex};

  @override
  Widget build(BuildContext context) {
    assert(widget.labels.length == widget.children.length);
    return Column(
      children: [
        SegmentedTabs(
          labels: widget.labels,
          selectedIndex: _index,
          scrollable: widget.scrollable,
          onChanged: (index) {
            setState(() {
              _index = index;
              _visited.add(index);
            });
            widget.onChanged?.call(index);
          },
        ),
        Expanded(
          child: widget.keepAlive
              ? IndexedStack(
                  index: _index,
                  children: [
                    for (var i = 0; i < widget.children.length; i++)
                      _visited.contains(i)
                          ? widget.children[i]
                          : const SizedBox.shrink(),
                  ],
                )
              : AnimatedSwitcher(
                  duration: context.motion(AppTokens.dBase),
                  switchInCurve: AppTokens.curveBase,
                  switchOutCurve: AppTokens.curveBase,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.985,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_index),
                    child: widget.children[_index],
                  ),
                ),
        ),
      ],
    );
  }
}

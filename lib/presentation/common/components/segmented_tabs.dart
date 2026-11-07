import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import 'edge_fade.dart';

class SegmentedTabs extends StatefulWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.padding = const EdgeInsets.only(
      left: AppTokens.s16,
      right: AppTokens.s32,
    ),
    this.scrollable = true,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  State<SegmentedTabs> createState() => _SegmentedTabsState();
}

class _SegmentedTabsState extends State<SegmentedTabs> {
  final ScrollController _controller = ScrollController();
  final GlobalKey _rowKey = GlobalKey();
  late List<GlobalKey> _keys = _buildKeys();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  double? _indicatorLeft;
  double? _lastRowWidth;

  List<GlobalKey> _buildKeys() =>
      List.generate(widget.labels.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateEdges);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateEdges();
      _updateIndicator();
      _ensureSelectedVisible();
    });
  }

  @override
  void didUpdateWidget(covariant SegmentedTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels.length != widget.labels.length) {
      _keys = _buildKeys();
    }
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.labels.length != widget.labels.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicator();
        _ensureSelectedVisible();
      });
    }
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

  void _updateIndicator() {
    if (!mounted || widget.labels.isEmpty) return;
    final row = _rowKey.currentContext?.findRenderObject();
    final index = widget.selectedIndex.clamp(0, _keys.length - 1);
    final tab = _keys[index].currentContext?.findRenderObject();
    if (row is! RenderBox || tab is! RenderBox || !row.hasSize) return;
    final left =
        tab.localToGlobal(Offset.zero, ancestor: row).dx +
        (tab.size.width - 20) / 2;
    if (_indicatorLeft != null && (_indicatorLeft! - left).abs() < 0.5) return;
    setState(() => _indicatorLeft = left);
  }

  void _handleRowWidth(double width) {
    if (_lastRowWidth == width) return;
    _lastRowWidth = width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateIndicator();
    });
  }

  void _ensureSelectedVisible() {
    if (!mounted || !widget.scrollable || _keys.isEmpty) return;
    final index = widget.selectedIndex.clamp(0, _keys.length - 1);
    final key = _keys[index];
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0.5,
      duration: target.motion(const Duration(milliseconds: 220)),
      curve: AppTokens.curveFast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final selectedIndex = widget.labels.isEmpty
        ? 0
        : widget.selectedIndex.clamp(0, widget.labels.length - 1);
    final tabs = <Widget>[];
    for (var i = 0; i < widget.labels.length; i++) {
      final selected = i == selectedIndex;
      tabs.add(
        Semantics(
          button: true,
          selected: selected,
          label: widget.labels[i],
          child: InkWell(
            key: _keys[i],
            onTap: () => widget.onChanged(i),
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
                    widget.labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(
                      color: selected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 9),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final row = Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          key: _rowKey,
          mainAxisSize: widget.scrollable ? MainAxisSize.min : MainAxisSize.max,
          children: widget.scrollable
              ? tabs
              : [for (final tab in tabs) Expanded(child: Center(child: tab))],
        ),
        if (_indicatorLeft != null)
          AnimatedPositioned(
            duration: context.motion(AppTokens.dBase),
            curve: AppTokens.curveBase,
            left: _indicatorLeft,
            bottom: 0,
            width: 20,
            height: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppTokens.rFull),
              ),
            ),
          ),
      ],
    );
    final scrollArea = widget.scrollable
        ? ShaderMask(
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
              stops: appEdgeFadeStops(bounds.width),
            ).createShader(bounds),
            child: SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: widget.padding,
              child: row,
            ),
          )
        : Padding(
            padding: widget.padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                _handleRowWidth(constraints.maxWidth);
                return row;
              },
            ),
          );
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      child: Stack(
        children: [
          scrollArea,
          if (widget.scrollable && _canScrollRight)
            Positioned(
              right: 2,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: Icon(
                    Icons.chevron_right,
                    key: const Key('segmentedTabsMoreHint'),
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
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

class _SegmentedTabsViewState extends State<SegmentedTabsView>
    with SingleTickerProviderStateMixin {
  late int _index = widget.initialIndex.clamp(
    0,
    widget.children.isEmpty ? 0 : widget.children.length - 1,
  );
  late final Set<int> _visited = {_index};
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: AppTokens.dBase,
    value: 1,
  );
  int? _previous;

  @override
  void didUpdateWidget(covariant SegmentedTabsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.children.length && widget.children.isNotEmpty) {
      _index = widget.children.length - 1;
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.labels.length == widget.children.length);
    if (widget.children.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SegmentedTabs(
          labels: widget.labels,
          selectedIndex: _index,
          scrollable: widget.scrollable,
          onChanged: (index) {
            if (index == _index) return;
            setState(() {
              _previous = _index;
              _index = index;
              _visited.add(index);
            });
            if (widget.keepAlive) {
              _fade.duration = context.motion(AppTokens.dBase);
              _fade.forward(from: 0);
            }
            widget.onChanged?.call(index);
          },
        ),
        Expanded(
          child: widget.keepAlive
              ? AnimatedBuilder(
                  animation: _fade,
                  builder: (context, _) {
                    final previous = _fade.isCompleted ? null : _previous;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        for (var i = 0; i < widget.children.length; i++)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: i != _index,
                              child: TickerMode(
                                enabled: i == _index || i == previous,
                                child: Opacity(
                                  opacity: i == _index
                                      ? _fade.value
                                      : i == previous
                                      ? 1 - _fade.value
                                      : 0,
                                  child: Offstage(
                                    offstage:
                                        !_visited.contains(i) ||
                                        (i != _index && i != previous),
                                    child: _visited.contains(i)
                                        ? widget.children[i]
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
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

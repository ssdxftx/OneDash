import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

/// 单个加载态容器共享的动画值。避免每个骨架块各建一个 Ticker。
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppTokens.dLoop,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonScope(animation: _controller, child: widget.child);
  }
}

class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_SkeletonScope oldWidget) =>
      oldWidget.animation != animation;
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppTokens.rXs,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final base = scheme.surfaceContainerHigh;
    final highlight = Color.lerp(base, scheme.onSurface, 0.06)!;
    final scope = context.dependOnInheritedWidgetOfExactType<_SkeletonScope>();
    Widget box(double t) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment(-1 + 2 * t, 0),
            end: Alignment(1 + 2 * t, 0),
            colors: [base, highlight, base],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      );
    }

    if (scope == null) return box(0.5);
    return AnimatedBuilder(
      animation: scope.animation,
      builder: (context, _) => box(scope.animation.value),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.height = 120,
    this.margin = const EdgeInsets.only(bottom: AppTokens.s12),
  });

  final double height;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      height: height,
      margin: margin,
      padding: const EdgeInsets.all(AppTokens.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.rLg),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 120, height: 14),
          SizedBox(height: AppTokens.s12),
          SkeletonBox(width: 200, height: 22),
          Spacer(),
          SkeletonBox(width: double.infinity, height: 12),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 72,
    this.padding = const EdgeInsets.all(AppTokens.s16),
  });

  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.s12),
        child: Row(
          children: [
            const SkeletonBox(width: 40, height: 40, borderRadius: 20),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 160, height: 14),
                  const SizedBox(height: AppTokens.s8),
                  SkeletonBox(width: 120 + (index % 3) * 40, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

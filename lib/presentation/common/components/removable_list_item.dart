import 'package:flutter/material.dart';

import '../../../core/motion/list_animation_scope.dart';
import '../../../core/theme/tokens.dart';

class RemovableListItem extends StatelessWidget {
  const RemovableListItem({
    super.key,
    required this.removing,
    required this.child,
    this.animateIn = false,
  });

  final bool removing;
  final Widget child;
  final bool animateIn;

  @override
  Widget build(BuildContext context) {
    final animate = animateIn && ListAnimationScope.of(context);
    if (!animate && !removing) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0 : 1, end: removing ? 0 : 1),
      duration: (animate || removing)
          ? context.motion(AppTokens.dBase)
          : Duration.zero,
      curve: AppTokens.curveBase,
      child: child,
      builder: (context, value, child) {
        if (value >= 1) return child!;
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: value.clamp(0, 1),
            child: Opacity(opacity: value.clamp(0, 1), child: child),
          ),
        );
      },
    );
  }
}

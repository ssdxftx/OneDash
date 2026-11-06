import 'package:flutter/material.dart';

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
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animateIn ? 0 : 1, end: removing ? 0 : 1),
      duration: context.motion(AppTokens.dBase),
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

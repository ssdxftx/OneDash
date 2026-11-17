import 'package:flutter/widgets.dart';

/// App-level list entry animation switch, independent of system reduce motion.
class ListAnimationScope extends InheritedWidget {
  const ListAnimationScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  final bool enabled;

  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ListAnimationScope>()
          ?.enabled ??
      true;

  @override
  bool updateShouldNotify(ListAnimationScope oldWidget) =>
      oldWidget.enabled != enabled;
}

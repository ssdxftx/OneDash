import 'package:flutter/material.dart';

import 'empty_state.dart';

/// 空态外层可下拉刷新，保证空列表仍有刷新手势。
class RefreshableEmptyState extends StatelessWidget {
  const RefreshableEmptyState({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final RefreshCallback onRefresh;
  final EmptyState child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

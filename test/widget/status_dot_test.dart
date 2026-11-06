import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/status_dot.dart';
import 'package:onedash/presentation/common/components/status_pulse.dart';

Widget _wrap(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: AppTheme.build(Brightness.light),
    builder: (context, appChild) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: appChild!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('错误状态点共享脉冲并在移除后释放', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusDot(status: 'error'),
            SizedBox(width: 8),
            StatusDot(status: 'failed'),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(StatusPulse.debugReferences, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(StatusPulse.debugReferences, 0);
  });

  testWidgets('减少动态效果时错误状态点不启动脉冲', (tester) async {
    await tester.pumpWidget(
      _wrap(const StatusDot(status: 'error'), reduceMotion: true),
    );
    await tester.pump();

    expect(StatusPulse.debugReferences, 0);
    expect(tester.takeException(), isNull);
  });
}

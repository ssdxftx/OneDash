import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/app_bar_large.dart';

void main() {
  testWidgets('server title supports tap and long press', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          appBar: AppBarLarge(
            title: 'Panel A',
            subtitle: '10.0.0.1:9999',
            onTitleTap: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Panel A'));
    await tester.pump();
    expect(taps, 1);

    await tester.longPress(find.text('Panel A'));
    await tester.pump();
    expect(taps, 2);
  });
}

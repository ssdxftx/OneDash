import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
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

  testWidgets('compact variant uses the compact toolbar height', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: AppBarLarge(title: 'Editor', compact: true)),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.toolbarHeight, lessThan(64));
  });

  testWidgets('long title drops one size instead of scaling', (tester) async {
    tester.view.physicalSize = const Size(320, 200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const title = 'Singapore Production Cluster Node 02';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: AppBarLarge(title: title)),
      ),
    );

    final text = tester.widget<Text>(find.text(title));
    expect(text.style!.fontSize, 20);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(find.byType(FittedBox), findsNothing);
  });

  testWidgets('short title keeps the headline size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: AppBarLarge(title: '生产')),
      ),
    );

    final text = tester.widget<Text>(find.text('生产'));
    expect(text.style!.fontSize, 24);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('chevron stays next to a short title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBarLarge(title: 'More', onTitleTap: () {}),
        ),
      ),
    );

    final titleRect = tester.getRect(find.text('More'));
    final chevronRect = tester.getRect(find.byIcon(TablerIcons.chevron_down));
    expect(chevronRect.left - titleRect.right, lessThan(12));
  });
}

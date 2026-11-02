import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/split_list_group.dart';

void main() {
  testWidgets('long trailing value keeps the title readable at 320dp/1.3x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              SplitListGroup(
                children: [
                  SplitListTile(
                    title: '到期时间',
                    trailing: Text('已过期 · 2026-10-01 · 剩余 0 天'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.text('到期时间')).width, greaterThan(60));
    final trailing = tester.widget<Text>(
      find.text('已过期 · 2026-10-01 · 剩余 0 天'),
    );
    expect(trailing.maxLines, 1);
    expect(trailing.overflow, TextOverflow.ellipsis);
  });
}

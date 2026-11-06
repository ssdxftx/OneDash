import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/segmented_tabs.dart';

void main() {
  testWidgets('选中的靠后页签会自动滚入视口', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: SegmentedTabs(
            labels: const ['概览', '网站', '文件', '容器', '计划任务', '负载均衡'],
            selectedIndex: 5,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('非滚动页签共享指示器跟随选中项移动', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SegmentedTabs(
              labels: const ['概览', '网站', '文件'],
              selectedIndex: selected,
              scrollable: false,
              onChanged: (index) => setState(() => selected = index),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final before = tester.widget<AnimatedPositioned>(
      find.byType(AnimatedPositioned),
    );
    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    final after = tester.widget<AnimatedPositioned>(
      find.byType(AnimatedPositioned),
    );

    expect(before.left, isNotNull);
    expect(after.left, greaterThan(before.left!));
    expect(tester.takeException(), isNull);
  });
}

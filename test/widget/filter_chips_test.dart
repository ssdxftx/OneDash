import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/tokens.dart';
import 'package:onedash/presentation/common/components/filter_chips.dart';

void main() {
  testWidgets('filters fade at the edge and keep trailing breathing room', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 200);
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
          body: AppFilterChips<String>(
            options: const ['全部', '静态网站', '反向代理', '运行环境', '其他'],
            labelOf: (option) => option,
            selected: const {'全部'},
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ShaderMask), findsOneWidget);
    final list = tester.widget<ListView>(find.byType(ListView));
    final padding = list.padding!.resolve(TextDirection.ltr);
    expect(padding.right, AppTokens.s32);
  });
}

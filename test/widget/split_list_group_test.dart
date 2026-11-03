import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/tokens.dart';
import 'package:onedash/presentation/common/components/split_list_group.dart';
import 'package:onedash/presentation/common/components/tonal_card.dart';

void main() {
  Widget wrap({required double width, required double textScale}) {
    return MaterialApp(
      theme: AppTheme.build(Brightness.light),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              TonalCard(
                child: SplitListGroup(
                  children: [
                    SplitListTile(
                      title: '到期时间',
                      trailing: Text(
                        '已过期 · 2026-10-01',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('long trailing value moves below the title at 320dp/1.3x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 320, textScale: 1.3));

    expect(tester.takeException(), isNull);
    final title = tester.renderObject<RenderParagraph>(find.text('到期时间'));
    expect(title.didExceedMaxLines, isFalse);
    final value = tester.renderObject<RenderParagraph>(
      find.textContaining('已过期'),
    );
    expect(value.didExceedMaxLines, isFalse);
    expect(
      tester.getCenter(find.text('到期时间')).dy,
      lessThan(tester.getCenter(find.textContaining('已过期')).dy),
    );
  });

  testWidgets('long value stacks below the label instead of squeezing it', (
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
        home: const Scaffold(
          body: SizedBox(
            width: 320,
            child: TonalCard(
              child: SplitListGroup(
                children: [
                  SplitListTile(title: '到期时间', value: '已过期 · 2026-10-01'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.text('到期时间')).width, greaterThan(40));
    expect(
      tester.getCenter(find.text('到期时间')).dy,
      lessThan(tester.getCenter(find.textContaining('已过期')).dy),
    );
  });

  testWidgets('short title and value stay on one row at 390dp/1.0x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 390, textScale: 1));

    expect(tester.takeException(), isNull);
    final title = tester.renderObject<RenderParagraph>(find.text('到期时间'));
    final value = tester.renderObject<RenderParagraph>(
      find.textContaining('已过期'),
    );
    expect(title.didExceedMaxLines, isFalse);
    expect(value.didExceedMaxLines, isFalse);
    expect(
      tester.getCenter(find.textContaining('已过期')).dy,
      closeTo(tester.getCenter(find.text('到期时间')).dy, 1),
    );
    expect(tester.getTopRight(find.textContaining('已过期')).dx, greaterThan(200));
  });

  testWidgets('value rows mute the label and emphasize the value', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: SizedBox(
            width: 390,
            child: TonalCard(
              child: SplitListGroup(
                children: [SplitListTile(title: '端口', value: '9090')],
              ),
            ),
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('端口'));
    final value = tester.widget<Text>(find.text('9090'));
    expect(label.style?.fontSize, AppTextStyles.bodyS.fontSize);
    expect(value.style?.fontSize, AppTextStyles.bodyL.fontSize);
  });

  testWidgets('valueStyle keeps the value layer with a custom color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: SizedBox(
            width: 390,
            child: TonalCard(
              child: SplitListGroup(
                children: [
                  SplitListTile(
                    title: '到期时间',
                    value: '已过期',
                    valueStyle: TextStyle(color: Color(0xFFB3261E)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('到期时间'));
    final value = tester.widget<Text>(find.text('已过期'));
    expect(label.style?.fontSize, AppTextStyles.bodyS.fontSize);
    expect(value.style?.fontSize, AppTextStyles.bodyL.fontSize);
    expect(value.style?.color, const Color(0xFFB3261E));
  });

  testWidgets('value survives when trailing is present', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 390,
            child: TonalCard(
              child: SplitListGroup(
                children: [
                  SplitListTile(
                    title: '用户名',
                    value: 'app',
                    trailing: IconButton(
                      tooltip: '复制',
                      icon: const Icon(Icons.copy),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('app'), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsOneWidget);
    expect(
      tester.getCenter(find.text('app')).dx,
      greaterThan(tester.getCenter(find.text('用户名')).dx),
    );
  });

  testWidgets('long value stays complete beside trailing at 320dp/1.3x', (
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
          body: SizedBox(
            width: 320,
            child: TonalCard(
              child: SplitListGroup(
                children: [
                  SplitListTile(
                    title: '连接地址',
                    value: 'db-cluster.internal',
                    trailing: IconButton(
                      tooltip: '复制',
                      icon: const Icon(Icons.copy),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final value = tester.renderObject<RenderParagraph>(
      find.text('db-cluster.internal'),
    );
    expect(value.didExceedMaxLines, isFalse);
    expect(find.byIcon(Icons.copy), findsOneWidget);
  });
}

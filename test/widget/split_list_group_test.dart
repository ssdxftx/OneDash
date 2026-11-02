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
}

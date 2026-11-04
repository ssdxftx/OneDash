import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/simple_markdown.dart';

void main() {
  Widget wrap(String data) => MaterialApp(
    theme: AppTheme.build(Brightness.light),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SimpleMarkdown(data: data),
      ),
    ),
  );

  testWidgets('renders headings, lists and inline emphasis', (tester) async {
    await tester.pumpWidget(
      wrap('# Title\n\n- first item\n- second **bold** item\n'),
    );
    expect(find.text('Title'), findsOneWidget);
    expect(find.textContaining('first item'), findsOneWidget);
    expect(find.textContaining('second bold item'), findsOneWidget);
  });

  testWidgets('renders fenced code blocks without dropping lines', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap('```bash\n1Panel v2.4.2\nsystemctl status 1panel\n```\n'),
    );
    expect(find.textContaining('1Panel v2.4.2'), findsOneWidget);
    expect(find.textContaining('systemctl status 1panel'), findsOneWidget);
  });

  testWidgets('unknown syntax stays visible as plain text', (tester) async {
    await tester.pumpWidget(wrap('| a | b |\n| - | - |\n'));
    expect(find.textContaining('| a | b |'), findsOneWidget);
  });
}

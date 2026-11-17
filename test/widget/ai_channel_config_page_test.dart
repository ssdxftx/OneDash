import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/features/ai/widgets/ai_channel_config_page.dart';

void main() {
  testWidgets('telegram channel form edits structured fields and payload', (
    tester,
  ) async {
    Map<String, dynamic>? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  result = await Navigator.of(context)
                      .push<Map<String, dynamic>>(
                        MaterialPageRoute(
                          builder: (_) => const AiChannelConfigPage(
                            channel: 'telegram',
                            initial: {
                              'enabled': true,
                              'dmPolicy': 'pairing',
                              'allowFrom': ['1001'],
                              'groupPolicy': 'open',
                              'groupAllowFrom': ['2001'],
                              'streaming': 'off',
                              'requireMention': false,
                              'defaultAccount': 'bot-1',
                              'bots': [
                                {
                                  'accountId': 'bot-1',
                                  'name': 'Main bot',
                                  'enabled': true,
                                  'isDefault': true,
                                  'botToken': 'token-1',
                                  'dmPolicy': 'pairing',
                                  'groupPolicy': 'open',
                                  'streaming': 'off',
                                },
                              ],
                            },
                          ),
                        ),
                      );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('私聊策略'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.dragUntilVisible(
      find.text('机器人 Token'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(find.text('Main bot'), findsWidgets);
    expect(find.text('机器人 Token'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('添加机器人'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.tap(find.text('添加机器人'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('机器人名称 2'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(find.text('机器人名称 2'), findsOneWidget);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!['dmPolicy'], 'pairing');
    expect(result!['allowFrom'], ['1001']);
    expect(result!['bots'], hasLength(2));
    expect((result!['bots'] as List).first['accountId'], 'bot-1');
  });
}

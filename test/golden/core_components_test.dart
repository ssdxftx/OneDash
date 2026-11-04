import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/tokens.dart';
import 'package:onedash/presentation/common/components/action_sheet.dart';
import 'package:onedash/presentation/common/components/app_bar_large.dart';
import 'package:onedash/presentation/common/components/split_list_group.dart';
import 'package:onedash/presentation/common/components/tonal_card.dart';

Future<void> _loadFont() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = await File('assets/fonts/MiSans-Regular.ttf').readAsBytes();
  await ui.loadFontFromList(Uint8List.fromList(bytes), fontFamily: 'MiSans');
}

Widget _sample() {
  return MaterialApp(
    theme: AppTheme.build(Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        appBar: const AppBarLarge(title: 'Sample'),
        body: ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            const TonalCard(
              child: SplitListGroup(
                children: [
                  SplitListTile(
                    leading: Icon(TablerIcons.world),
                    title: 'example.com',
                    subtitle: 'Static · /opt/1panel/www',
                  ),
                  SplitListTile(
                    leading: Icon(TablerIcons.lock),
                    title: 'SSL certificate',
                    value: '42 days',
                  ),
                  SplitListTile(
                    leading: Icon(TablerIcons.file_text),
                    title: 'Logs',
                    trailing: Icon(TablerIcons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            ActionSheetSection(
              title: 'Actions',
              icon: TablerIcons.settings,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.edit,
                  iconColor: context.appColors.info,
                  title: 'Edit',
                  onTap: () {},
                ),
                ActionSheetRow(
                  icon: TablerIcons.refresh,
                  iconColor: context.appColors.info,
                  title: 'Restart',
                  onTap: () {},
                ),
                ActionSheetRow(
                  icon: TablerIcons.trash,
                  iconColor: context.appColors.danger,
                  title: 'Delete',
                  danger: true,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(_loadFont);

  for (final width in [320.0, 390.0, 600.0]) {
    testWidgets('core components at ${width.toInt()}dp', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_sample());
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/core_${width.toInt()}.png'),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/data/dto/website/website_group_dto.dart';
import 'package:onedash/presentation/features/websites/screens/website_groups_page.dart';

void main() {
  Widget wrap(List<WebsiteGroupDto> groups) {
    return MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(
          children: [
            for (final group in groups)
              WebsiteGroupTile(group: group, onEdit: () {}, onDelete: () {}),
          ],
        ),
      ),
    );
  }

  const groups = [
    WebsiteGroupDto(id: 1, name: '默认', type: 'website', isDefault: true),
    WebsiteGroupDto(id: 2, name: '项目', type: 'website', isDefault: false),
  ];

  testWidgets('default group cannot be deleted', (tester) async {
    await tester.pumpWidget(wrap(groups));

    expect(find.byIcon(TablerIcons.trash), findsOneWidget);
    expect(find.byIcon(TablerIcons.lock), findsOneWidget);

    final defaultTile = find.ancestor(
      of: find.text('默认'),
      matching: find.byType(WebsiteGroupTile),
    );
    expect(
      find.descendant(
        of: defaultTile,
        matching: find.byIcon(TablerIcons.trash),
      ),
      findsNothing,
    );
    expect(find.text('系统保留，不可删除'), findsOneWidget);
  });
}

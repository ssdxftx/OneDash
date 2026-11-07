import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/container/container_option_dto.dart';
import 'package:onedash/presentation/features/containers/providers/container_resources_provider.dart';
import 'package:onedash/presentation/features/containers/screens/container_volumes_page.dart';

void main() {
  testWidgets('volume page lists names and exposes delete action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          containerVolumesProvider.overrideWith(
            (ref) async => const [
              ContainerOptionDto(option: 'app_data'),
              ContainerOptionDto(option: 'mysql_data'),
            ],
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ContainerVolumesPage(serverId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('存储卷'), findsOneWidget);
    expect(find.text('app_data'), findsOneWidget);
    expect(find.text('mysql_data'), findsOneWidget);
    expect(find.byIcon(TablerIcons.trash), findsNWidgets(2));
  });
}

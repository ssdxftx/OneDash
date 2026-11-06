import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/container/container_search_dto.dart';
import 'package:onedash/presentation/common/components/action_sheet.dart';
import 'package:onedash/presentation/features/containers/widgets/container_actions.dart';

void main() {
  const item = ContainerItemDto(
    containerID: 'abc',
    name: 'demo-container',
    imageID: 'sha256:1',
    imageName: 'nginx:alpine',
    createTime: '2026-11-06 10:00:00',
    state: 'running',
    runTime: '2 hours',
    isFromApp: false,
    isFromCompose: false,
    isPinned: false,
    description: 'demo',
  );

  testWidgets('container actions open as a bottom sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => TextButton(
                onPressed: () => showContainerActions(
                  context,
                  ref,
                  serverId: 1,
                  item: item,
                  onChanged: () async {},
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ActionSheetScaffold), findsOneWidget);
    expect(find.text('demo-container'), findsOneWidget);
    expect(find.text('nginx:alpine'), findsOneWidget);
    expect(find.byType(ActionSheetSection), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}

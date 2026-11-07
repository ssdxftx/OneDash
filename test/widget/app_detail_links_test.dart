import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/app/app_detail_dto.dart';
import 'package:onedash/presentation/features/app_store/providers/app_store_provider.dart';
import 'package:onedash/presentation/features/app_store/screens/app_detail_page.dart';

const _detail = AppDetailDto(
  id: 1,
  name: 'OpenClaw',
  key: 'openclaw',
  shortDescZh: '',
  shortDescEn: '',
  description: '',
  icon: '',
  type: 'runtime',
  status: 'Normal',
  crossVersionUpdate: false,
  limit: 0,
  website: 'https://example.com',
  github: 'https://github.com/example/openclaw',
  document: 'https://docs.example.com',
  recommend: 0,
  resource: '',
  readMe: '',
  architectures: 'amd64',
  memoryRequired: 0,
  gpuSupport: false,
  batchInstallSupport: false,
  installed: false,
  versions: ['1.0.0'],
  tags: [],
);

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDetailProvider('openclaw').overrideWith((ref) async => _detail),
      ],
      child: MaterialApp(
        theme: AppTheme.build(Brightness.light),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    showAppDetailSheet(context, serverId: 1, appId: 'openclaw'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(390, 844), Size(320, 900)]) {
    testWidgets('detail link labels stay readable at ${size.width}dp', (
      tester,
    ) async {
      await _pump(tester, size);

      expect(tester.takeException(), isNull);
      for (final label in ['Website', 'GitHub', 'Docs']) {
        final finder = find.text(label);
        expect(finder, findsOneWidget);
        expect(tester.getSize(finder).width, greaterThan(0));
      }
    });
  }
}

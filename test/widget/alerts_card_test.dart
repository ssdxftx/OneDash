import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/data/dto/alert/alert_dto.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/data/repositories_impl/alert_repository_impl.dart';
import 'package:onedash/domain/repositories/alert_repository.dart';
import 'package:onedash/presentation/common/components/tonal_card.dart';
import 'package:onedash/presentation/features/alerts/screens/alerts_page.dart';

class _FakeAlertRepository implements AlertRepository {
  @override
  Future<PageResult<AlertInfo>> searchAlerts(AlertSearchReq req) async =>
      const PageResult(
        total: 1,
        items: [
          AlertInfo(
            id: 1,
            type: 'cpu',
            method: 'telegram',
            title: 'CPU 使用率过高',
            status: 'Enable',
          ),
        ],
      );

  @override
  Future<PageResult<AlertLogInfo>> searchAlertLogs(
    AlertLogSearchReq req,
  ) async => const PageResult(total: 0, items: []);

  @override
  Future<List<AlertConfigInfo>> getAlertConfigs() async => const [];

  @override
  Future<AlertConfigInfo> getAlertConfig() async => const AlertConfigInfo();

  @override
  Future<void> createAlert(AlertCreateReq req) async {}

  @override
  Future<void> updateAlert(int id, AlertCreateReq req) async {}

  @override
  Future<void> deleteAlert(int id) async {}

  @override
  Future<void> updateAlertStatus(int id, String status) async {}

  @override
  Future<void> cleanAlertLogs() async {}

  @override
  Future<void> updateAlertConfig(AlertConfigUpdateReq req) async {}

  @override
  Future<bool> testAlertConfig(AlertConfigTestReq req) async => true;

  @override
  Future<void> deleteAlertConfig(int id) async {}

  @override
  Future<List<Map<String, dynamic>>> listDisks() async => const [];
}

Future<void> _loadFont() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = await File('assets/fonts/MiSans-Regular.ttf').readAsBytes();
  await ui.loadFontFromList(Uint8List.fromList(bytes), fontFamily: 'MiSans');
}

void main() {
  setUpAll(_loadFont);

  Widget wrap({
    required double width,
    required double textScale,
    Locale locale = const Locale('zh'),
  }) {
    return ProviderScope(
      overrides: [
        alertRepositoryProvider.overrideWith(
          (ref) async => _FakeAlertRepository(),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const AlertsPage(serverId: 1),
      ),
    );
  }

  testWidgets('320dp / 1.3x keeps Telegram on one line', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 320, textScale: 1.3));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.text('Telegram')).height, lessThan(30));

    final menu = tester.getCenter(find.byTooltip('更多'));
    final toggle = tester.getCenter(find.byType(Switch));
    expect((menu.dx - toggle.dx).abs(), lessThan(12));
    expect(toggle.dy, greaterThan(menu.dy));
  });

  testWidgets('320dp / 1.0x keeps controls on one row', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 320, textScale: 1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(TonalCard)).height,
      lessThanOrEqualTo(108),
    );
    final menu = tester.getCenter(find.byTooltip('更多'));
    final toggle = tester.getCenter(find.byType(Switch));
    expect((menu.dy - toggle.dy).abs(), lessThan(2));
  });

  testWidgets('390dp / 1.0x English meta is not ellipsized', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(width: 390, textScale: 1, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final method = tester.renderObject<RenderParagraph>(
      find.text('Method: Telegram'),
    );
    expect(method.didExceedMaxLines, isFalse);
    expect(tester.getSize(find.text('Method: Telegram')).height, lessThan(40));
  });

  testWidgets('360dp / 1.0x keeps controls on one row', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(width: 360, textScale: 1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(TonalCard)).height,
      lessThanOrEqualTo(108),
    );

    final menu = tester.getCenter(find.byTooltip('更多'));
    final toggle = tester.getCenter(find.byType(Switch));
    expect((menu.dy - toggle.dy).abs(), lessThan(2));
  });
}

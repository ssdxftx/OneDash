import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/data/dto/alert/alert_dto.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/data/repositories_impl/alert_repository_impl.dart';
import 'package:onedash/domain/repositories/alert_repository.dart';
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

void main() {
  testWidgets('compact alert card keeps Telegram on one line', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alertRepositoryProvider.overrideWith(
            (ref) async => _FakeAlertRepository(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const AlertsPage(serverId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final method = tester.renderObject<RenderParagraph>(find.text('Telegram'));
    expect(method.didExceedMaxLines, isFalse);
    expect(find.textContaining('Telegr\n'), findsNothing);

    final menu = tester.getCenter(find.byTooltip('更多'));
    final toggle = tester.getCenter(find.byType(Switch));
    expect((menu.dx - toggle.dx).abs(), lessThan(12));
    expect(toggle.dy, greaterThan(menu.dy));
  });
}

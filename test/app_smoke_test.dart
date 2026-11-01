import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/app.dart';
import 'package:onedash/core/router/app_router.dart';
import 'package:onedash/core/storage/storage_service.dart';
import 'package:onedash/domain/entities/server.dart';
import 'package:onedash/presentation/common/states/error_state.dart';
import 'package:onedash/presentation/features/server_detail/providers/active_server_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('五个 tab 打开后不出现 provider 作用域错误', (tester) async {
    SharedPreferences.setMockInitialValues({});
    // StorageService.init() 会调 getApplicationDocumentsDirectory()，
    // 纯 flutter_test 环境下这条路走不通，必须打桩，否则抛 MissingPluginException。
    final documents = Directory.systemTemp.createTempSync('onedash-smoke-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => documents.path,
        );
    addTearDown(() => documents.deleteSync(recursive: true));

    final storage = StorageService();
    await tester.runAsync(() async {
      await storage.init();
      await storage.saveServer(
        Server()
          ..id = 1
          ..name = 'smoke'
          ..host = '127.0.0.1'
          ..port = 1,
      );
    });
    appContainer = ProviderContainer(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: appContainer,
        child: const OneDashApp(),
      ),
    );
    // 不要用 pumpAndSettle：页面里有轮询 Timer，永远 settle 不了，会 10s 超时。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    appRouter.go('/s/1');
    await tester.pump();
    expect(
      appRouter.routerDelegate.currentConfiguration.uri.path,
      '/s/1/overview',
      reason: '裸路径 /s/1 没有落到概览',
    );

    for (final tab in ['overview', 'websites', 'files', 'containers', 'more']) {
      appRouter.go('/s/1/$tab');
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(
        appRouter.routerDelegate.currentConfiguration.uri.path,
        '/s/1/$tab',
        reason: '$tab 路由没有解析到预期路径',
      );
      final states = tester.widgetList<ErrorState>(find.byType(ErrorState));
      for (final state in states) {
        expect(
          state.data.detail ?? '',
          isNot(contains('activeServerIdProvider')),
          reason: '$tab 的 provider 作用域没生效',
        );
      }
    }
    appRouter.go('/s/1/containers/create');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      appRouter.routerDelegate.currentConfiguration.uri.path,
      '/s/1/containers/create',
    );
    expect(tester.takeException(), isNull);

    for (final route in [
      '/s/1/files/history?path=%2Ftmp',
      '/s/1/files/ai-search?path=%2Ftmp',
      '/s/1/websites/templates',
      '/s/1/more/host',
      '/s/1/more/runtimes/1?type=php&name=php',
      '/s/1/more/toolbox/device',
      '/s/1/more/toolbox/clam',
      '/s/1/more/toolbox/fail2ban',
      '/s/1/more/toolbox/ftp',
    ]) {
      appRouter.go(route);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        appRouter.routerDelegate.currentConfiguration.uri.path,
        route.split('?').first,
        reason: '$route 路由没有解析到预期路径',
      );
      expect(tester.takeException(), isNull, reason: '$route 渲染异常');
    }

    appRouter.go('/s/1/more');
    await tester.pump();
    expect(appContainer.read(activeServerIdProvider), 1);
  });
}

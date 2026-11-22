import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/storage/storage_service.dart';
import 'package:onedash/domain/entities/server.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'corrupt servers.json is quarantined and the app starts empty',
    () async {
      SharedPreferences.setMockInitialValues({});
      final documents = Directory.systemTemp.createTempSync('onedash-storage-');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => documents.path,
          );
      addTearDown(() => documents.deleteSync(recursive: true));

      final storage = StorageService();
      await storage.init();
      await File('${documents.path}/servers.json').writeAsString('{broken');

      expect(await storage.getServers(), isEmpty);
      final quarantined = documents.listSync().whereType<File>().any(
        (file) => file.path.contains('.corrupt-'),
      );
      expect(quarantined, isTrue);

      final saved = Server()
        ..id = 1
        ..host = '127.0.0.1'
        ..port = 9999;
      await storage.saveServer(saved);
      expect((await storage.getServers()).single.id, 1);
    },
  );
}

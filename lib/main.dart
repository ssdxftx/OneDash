import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'core/storage/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache
    ..maximumSize = 120
    ..maximumSizeBytes = 80 << 20;

  final storageService = StorageService();
  await storageService.init();

  appContainer = ProviderContainer(
    overrides: [storageServiceProvider.overrideWithValue(storageService)],
  );

  runApp(
    UncontrolledProviderScope(
      container: appContainer,
      child: const OneDashApp(),
    ),
  );
}

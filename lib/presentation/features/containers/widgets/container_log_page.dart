import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../log/screens/log_preview_page.dart';

Future<void> openContainerLogs(
  BuildContext context,
  WidgetRef ref, {
  required String containerName,
  String? subtitle,
}) {
  final l10n = AppLocalizations.of(context);
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LogPreviewPage(
        title: l10n.containers_logs,
        subtitle: subtitle ?? containerName,
        sources: [
          LogSourceOption(
            label: l10n.containers_logs,
            load: () async {
              final repository = await ref.read(
                containerRepositoryProvider.future,
              );
              final log = await repository.getContainerLog(
                containerName: containerName,
                since: '24h',
                tail: '1000',
                follow: false,
                timestamp: true,
              );
              return log
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .toList(growable: false);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> openComposeLogs(
  BuildContext context,
  WidgetRef ref, {
  required String composePath,
  String? subtitle,
}) {
  final l10n = AppLocalizations.of(context);
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LogPreviewPage(
        title: l10n.containers_composeLogs,
        subtitle: subtitle ?? composePath,
        sources: [
          LogSourceOption(
            label: l10n.containers_composeLogs,
            load: () async {
              final repository = await ref.read(
                containerRepositoryProvider.future,
              );
              final log = await repository.getComposeLog(
                composePath: composePath,
                since: '24h',
                tail: '1000',
                follow: false,
                timestamp: true,
              );
              return log
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .toList(growable: false);
            },
          ),
        ],
      ),
    ),
  );
}

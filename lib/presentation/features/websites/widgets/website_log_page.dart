import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../data/dto/website/website_log_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../log/screens/log_preview_page.dart';
import '../providers/websites_provider.dart';

List<LogSourceOption> websiteLogSources(
  WidgetRef ref,
  int websiteId,
  AppLocalizations l10n, {
  int pageSize = 500,
}) {
  return WebsiteLogType.values
      .map(
        (type) => LogSourceOption(
          label: type == WebsiteLogType.access
              ? l10n.websites_accessLog
              : l10n.websites_errorLog,
          load: () async {
            final repository = await ref.read(websiteRepositoryProvider.future);
            final log = await repository.readWebsiteLog(
              websiteId,
              type,
              pageSize: pageSize,
            );
            return log.lines;
          },
          loadPage: (page, size) async {
            final repository = await ref.read(websiteRepositoryProvider.future);
            final log = await repository.readWebsiteLog(
              websiteId,
              type,
              page: page,
              pageSize: size,
            );
            return LogBatch(lines: log.lines, end: log.end);
          },
          exportBytes: () async {
            final repository = await ref.read(websiteRepositoryProvider.future);
            final log = await repository.readWebsiteLog(
              websiteId,
              type,
              pageSize: 1,
            );
            if (log.path.trim().isEmpty) return null;
            final files = await ref.read(fileRepositoryProvider.future);
            return files.downloadBytes(log.path);
          },
        ),
      )
      .toList(growable: false);
}

Future<void> openWebsiteLogs(
  BuildContext context,
  WidgetRef ref, {
  required int websiteId,
  String? subtitle,
  WebsiteLogType initialType = WebsiteLogType.access,
  int pageSize = 500,
}) {
  final l10n = AppLocalizations.of(context);
  final sources = websiteLogSources(ref, websiteId, l10n, pageSize: pageSize);
  final initialIndex = WebsiteLogType.values.indexOf(initialType);
  final ordered = [
    sources[initialIndex],
    for (var index = 0; index < sources.length; index++)
      if (index != initialIndex) sources[index],
  ];
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LogPreviewPage(
        title: l10n.websites_logs,
        subtitle: subtitle,
        pageSize: pageSize,
        sources: ordered,
      ),
    ),
  );
}

/// Opens website logs as a sheet above the website action sheet.
Future<void> showWebsiteLogsSheet(
  BuildContext context,
  WidgetRef ref, {
  required int websiteId,
  String? subtitle,
  WebsiteLogType initialType = WebsiteLogType.access,
  int pageSize = 500,
}) {
  final l10n = AppLocalizations.of(context);
  final sources = websiteLogSources(ref, websiteId, l10n, pageSize: pageSize);
  final initialIndex = WebsiteLogType.values.indexOf(initialType);
  final ordered = [
    sources[initialIndex],
    for (var index = 0; index < sources.length; index++)
      if (index != initialIndex) sources[index],
  ];
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.94,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.86,
      child: LogPreviewPage(
        title: l10n.websites_logs,
        subtitle: subtitle,
        pageSize: pageSize,
        sources: ordered,
        embedded: true,
      ),
    ),
  );
}

class WebsiteLogsPage extends ConsumerWidget {
  const WebsiteLogsPage({
    super.key,
    required this.serverId,
    required this.websiteId,
  });

  final int serverId;
  final int websiteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final site = ref.watch(websiteDetailProvider(websiteId)).valueOrNull;
    return LogPreviewPage(
      title: l10n.websites_logs,
      subtitle: site?.website.primaryDomain,
      sources: websiteLogSources(ref, websiteId, l10n),
    );
  }
}

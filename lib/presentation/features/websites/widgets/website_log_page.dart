import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../data/dto/website/website_log_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../log/screens/log_preview_page.dart';
import '../providers/websites_provider.dart';

List<LogSourceOption> websiteLogSources(
  WidgetRef ref,
  int websiteId,
  AppLocalizations l10n,
) {
  return WebsiteLogType.values
      .map(
        (type) => LogSourceOption(
          label: type == WebsiteLogType.access
              ? l10n.websites_accessLog
              : l10n.websites_errorLog,
          load: () async {
            final repository = await ref.read(websiteRepositoryProvider.future);
            final log = await repository.readWebsiteLog(websiteId, type);
            return log.lines;
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
}) {
  final l10n = AppLocalizations.of(context);
  final sources = websiteLogSources(ref, websiteId, l10n);
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
        sources: ordered,
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

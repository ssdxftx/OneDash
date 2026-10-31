import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/async_state_view.dart';
import '../../servers/providers/servers_provider.dart';

final _panelSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async {
    final repository = await ref.watch(settingRepositoryProvider.future);
    final settings = await repository.searchSettings();
    final core = await repository.searchCoreSettings();
    return {...settings, ...core};
  },
  name: 'panelSettingsProvider',
);

class PanelSettingsPage extends ConsumerWidget {
  const PanelSettingsPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(_panelSettingsProvider);
    final server = ref.watch(serverByIdProvider(serverId)).valueOrNull;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panel_settings_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_panelSettingsProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: settings,
        onRetry: () => ref.invalidate(_panelSettingsProvider),
        loading: const SkeletonList(itemCount: 10),
        builder: (data) => ListView(
          padding: const EdgeInsets.all(AppTokens.s16),
          children: [
            if (server != null)
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.world_www),
                    title: l10n.panelSettings_openWeb,
                    subtitle: server.baseUrl.toString(),
                    trailing: const Icon(TablerIcons.external_link),
                    onTap: () => launchUrl(
                      server.baseUrl,
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppTokens.s16),
            SplitListGroup(
              children: [
                for (final entry in data.entries)
                  if (entry.value is String ||
                      entry.value is num ||
                      entry.value is bool)
                    SplitListTile(title: entry.key, subtitle: '${entry.value}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

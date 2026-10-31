import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/repository_providers.dart';
import '../../../../domain/entities/dashboard.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/split_list_group.dart';
import '../../servers/providers/servers_provider.dart';

final _panelCountsProvider = FutureProvider.autoDispose
    .family<DashboardBase, int>((ref, id) async {
      final repository = await ref.watch(
        dashboardRepositoryForServerProvider(id).future,
      );
      return repository.getDashboardBase(ioOption: 'all', netOption: 'all');
    }, name: 'panelCountsProvider');

class MorePage extends ConsumerWidget {
  const MorePage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final server = ref.watch(serverByIdProvider(serverId)).valueOrNull;
    final counts = ref.watch(_panelCountsProvider(serverId)).valueOrNull;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppTokens.s32),
          children: [
            AppBarLarge(
              title: l10n.more_title,
              subtitle: server?.displayName,
              onTitleLongPress: () =>
                  showServerSwitcher(context, ref, currentServerId: serverId),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: l10n.more_group_apps),
                  SplitListGroup(
                    children: [
                      _tile(
                        context,
                        icon: TablerIcons.apps,
                        title: l10n.more_app_store,
                        subtitle: l10n.apps_search_hint,
                        onTap: () => context.push('/s/$serverId/more/apps'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.package,
                        title: l10n.more_installed_apps,
                        subtitle: '${counts?.appInstalledNumber ?? '-'}',
                        onTap: () => context.push('/s/$serverId/more/apps'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.database,
                        title: l10n.more_databases,
                        subtitle: '${counts?.databaseNumber ?? '-'}',
                        onTap: () =>
                            context.push('/s/$serverId/more/databases'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.clock,
                        title: l10n.more_cronjobs,
                        subtitle: '${counts?.cronjobNumber ?? '-'}',
                        onTap: () => context.push('/s/$serverId/more/cronjobs'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.brand_docker,
                        title: l10n.more_runtimes,
                        subtitle: 'PHP / Node / Python',
                        onTap: () => context.push('/s/$serverId/more/runtimes'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s24),
                  SectionHeader(title: l10n.more_group_web),
                  SplitListGroup(
                    children: [
                      _tile(
                        context,
                        icon: TablerIcons.world,
                        title: l10n.nav_websites,
                        subtitle: '${counts?.websiteNumber ?? '-'}',
                        onTap: () => context.go('/s/$serverId/websites'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.stack_2,
                        title: l10n.containers_compose,
                        subtitle: 'docker compose',
                        onTap: () => context.push('/s/$serverId/more/compose'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.shield,
                        title: l10n.more_firewall,
                        onTap: () => context.push('/s/$serverId/more/firewall'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s24),
                  SectionHeader(title: l10n.more_group_ops),
                  SplitListGroup(
                    children: [
                      _tile(
                        context,
                        icon: TablerIcons.file_text,
                        title: l10n.more_logs,
                        onTap: () => context.push('/s/$serverId/more/logs'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.terminal_2,
                        title: l10n.more_terminal,
                        subtitle: 'SSH',
                        onTap: () => context.push('/s/$serverId/terminal'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.cpu,
                        title: l10n.more_process,
                        onTap: () => context.push('/s/$serverId/more/process'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.cloud_upload,
                        title: l10n.more_backups,
                        onTap: () => context.push('/s/$serverId/more/backups'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s24),
                  SectionHeader(title: l10n.more_group_system),
                  SplitListGroup(
                    children: [
                      _tile(
                        context,
                        icon: TablerIcons.settings,
                        title: l10n.more_panel_settings,
                        subtitle: l10n.panel_settings_base,
                        onTap: () => context.push('/s/$serverId/more/settings'),
                      ),
                      _tile(
                        context,
                        icon: TablerIcons.adjustments,
                        title: l10n.more_app_settings,
                        subtitle: l10n.settings_appearance,
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s24),
                  Center(
                    child: Text(
                      'OneDash · GPL-3.0',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return SplitListTile(
      leading: Icon(icon),
      title: title,
      subtitle: subtitle,
      trailing: const Icon(TablerIcons.chevron_right),
      onTap: onTap,
    );
  }
}

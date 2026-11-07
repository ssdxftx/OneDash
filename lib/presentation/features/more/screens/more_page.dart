import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/repository_providers.dart';
import '../../../../domain/entities/dashboard.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/error_toast.dart';
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
        child: CustomScrollView(
          slivers: [
            SliverAppBarLarge(
              title: l10n.more_title,
              subtitle: server?.displayName,
              onTitleTap: () =>
                  showServerSwitcher(context, ref, currentServerId: serverId),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                0,
                context.pagePadding,
                AppTokens.bottomNavClearance +
                    MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: l10n.more_group_apps),
                    SplitListGroup(
                      children: [
                        _tile(
                          context,
                          icon: TablerIcons.layout_grid,
                          title: l10n.more_app_store,
                          subtitle: l10n.more_appStoreSubtitle,
                          onTap: () => context.push('/s/$serverId/more/apps'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.package,
                          title: l10n.more_installed_apps,
                          subtitle: counts == null
                              ? null
                              : l10n.more_appsCount(counts.appInstalledNumber),
                          onTap: () => context.push(
                            '/s/$serverId/more/apps?tab=installed',
                          ),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.database,
                          title: l10n.more_databases,
                          subtitle: counts == null
                              ? null
                              : l10n.more_databasesCount(counts.databaseNumber),
                          onTap: () =>
                              context.push('/s/$serverId/more/databases'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.brand_docker,
                          title: l10n.more_runtimes,
                          subtitle: l10n.more_runtimesSubtitle,
                          onTap: () =>
                              context.push('/s/$serverId/more/runtimes'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.brain,
                          title: l10n.ai_title,
                          subtitle: l10n.ai_subtitle,
                          onTap: () => context.push('/s/$serverId/more/ai'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s24),
                    SectionHeader(title: l10n.more_group_ops),
                    SplitListGroup(
                      children: [
                        _tile(
                          context,
                          icon: TablerIcons.clock,
                          title: l10n.more_cronjobs,
                          subtitle: counts == null
                              ? null
                              : l10n.more_cronjobsCount(counts.cronjobNumber),
                          onTap: () =>
                              context.push('/s/$serverId/more/cronjobs'),
                        ),
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
                          icon: TablerIcons.list_details,
                          title: l10n.more_process,
                          onTap: () =>
                              context.push('/s/$serverId/more/process'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.server,
                          title: l10n.host_title,
                          subtitle: l10n.host_subtitleOps,
                          onTap: () => context.push('/s/$serverId/more/host'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.cloud_upload,
                          title: l10n.more_backups,
                          onTap: () =>
                              context.push('/s/$serverId/more/backups'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.bell,
                          title: l10n.panelSettings_alerts,
                          subtitle: l10n.panelSettings_alertList,
                          onTap: () => context.push('/s/$serverId/more/alerts'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.shield,
                          title: l10n.more_firewall,
                          onTap: () =>
                              context.push('/s/$serverId/more/firewall'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.settings_cog,
                          title: l10n.supervisor_titleLong,
                          onTap: () =>
                              context.push('/s/$serverId/more/host-tools'),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.tool,
                          title: l10n.toolbox_title,
                          onTap: () =>
                              context.push('/s/$serverId/more/toolbox'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s24),
                    SectionHeader(title: l10n.more_group_system),
                    SplitListGroup(
                      children: [
                        _tile(
                          context,
                          icon: TablerIcons.refresh,
                          title: l10n.system_restartPanel,
                          subtitle: l10n.system_restartPanelSubtitle,
                          onTap: () => _restart(
                            context,
                            ref,
                            operation: '1panel',
                            title: l10n.system_restartPanel,
                            message: l10n.system_restartPanelMessage,
                          ),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.server,
                          title: l10n.system_restartServer,
                          subtitle: l10n.system_restartServerSubtitle,
                          onTap: server == null
                              ? null
                              : () => _restart(
                                  context,
                                  ref,
                                  operation: 'system',
                                  title: l10n.system_restartServer,
                                  message: l10n.system_restartServerMessage,
                                  requireText: server.displayName,
                                ),
                        ),
                        _tile(
                          context,
                          icon: TablerIcons.settings,
                          title: l10n.more_panel_settings,
                          subtitle: l10n.panel_settings_base,
                          onTap: () =>
                              context.push('/s/$serverId/more/settings'),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restart(
    BuildContext context,
    WidgetRef ref, {
    required String operation,
    required String title,
    required String message,
    String? requireText,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: title,
      message: message,
      confirmLabel: l10n.action_restart,
      requireText: requireText,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(
        dashboardRepositoryForServerProvider(serverId).future,
      );
      await repository.restartSystem(operation);
      if (!context.mounted) return;
      AppToast.success(context, l10n.system_restartSubmitted);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
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

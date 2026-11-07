import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../containers/widgets/container_log_page.dart';
import '../providers/app_store_provider.dart';
import '../widgets/installed_app_actions.dart';

class InstalledAppPage extends ConsumerWidget {
  const InstalledAppPage({
    super.key,
    required this.serverId,
    required this.installId,
    this.detailId,
    this.embedded = false,
  });

  final int serverId;
  final String installId;
  final int? detailId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = int.tryParse(installId) ?? 0;
    final info = ref.watch(installedInfoProvider(id));
    final ignored = ref.watch(installedIgnoredProvider(id)).valueOrNull;
    final installed = ref.watch(installedAppsProvider).valueOrNull;
    AppInstalledDto? app;
    for (final item in installed?.items ?? const <AppInstalledDto>[]) {
      if (item.id == id) {
        app = item;
        break;
      }
    }
    final current = info.valueOrNull;
    final container = current?.container;
    final appName = current?.name ?? app?.displayName ?? '';
    final title = appName.trim().isEmpty ? l10n.apps_installed : appName;
    final body = AsyncStateView(
      value: info,
      onRetry: () => ref.invalidate(installedInfoProvider(id)),
      builder: (data) => ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          TonalCard(
            child: Row(
              children: [
                StatusDot(status: data.status.toLowerCase()),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: AppTextStyles.titleM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${data.version} · ${data.httpPort}',
                        style: AppTextStyles.bodyS.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.error_details),
          SplitListGroup(
            children: [
              SplitListTile(title: l10n.app_detail_key, value: data.appKey),
              SplitListTile(
                title: l10n.app_detail_container,
                value: data.container,
              ),
              if (data.composePath.trim().isNotEmpty)
                SplitListTile(
                  title: l10n.app_detail_compose,
                  value: data.composePath,
                ),
              if (data.message.isNotEmpty)
                SplitListTile(
                  title: l10n.app_detail_message,
                  value: data.message,
                ),
            ],
          ),
          if (app != null) ...[
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.containers_groupMaintenance),
            SplitListGroup(
              children: [
                SplitListTile(
                  leading: const Icon(TablerIcons.file_text),
                  title: l10n.apps_installLog,
                  onTap: () => InstalledAppActions.showInstallLog(
                    context,
                    ref,
                    installId: id,
                    appName: appName,
                  ),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.restore),
                  title: l10n.apps_rebuild,
                  onTap: () => InstalledAppActions.rebuild(context, ref, app!),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.reload),
                  title: l10n.apps_reload,
                  onTap: () => InstalledAppActions.reload(context, ref, app!),
                ),
                if (app.canUpdate)
                  SplitListTile(
                    leading: const Icon(TablerIcons.arrow_up_circle),
                    title: l10n.apps_upgrade,
                    subtitle: app.version,
                    onTap: () =>
                        InstalledAppActions.upgrade(context, ref, app!),
                  ),
                SplitListTile(
                  leading: const Icon(TablerIcons.adjustments),
                  title: l10n.apps_editParams,
                  subtitle: app.version,
                  onTap: () =>
                      InstalledAppActions.editParams(context, ref, app!),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.plug),
                  title: l10n.apps_changePort,
                  subtitle: '${app.httpPort}',
                  onTap: () =>
                      InstalledAppActions.changePort(context, ref, app!),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.info_circle),
                  title: l10n.apps_connInfo,
                  subtitle: app.container,
                  onTap: () =>
                      InstalledAppActions.showConnInfo(context, ref, app!),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.bell_off),
                  title: ignored == null
                      ? l10n.apps_ignoreUpdate
                      : l10n.apps_cancelIgnoreUpdate,
                  onTap: () =>
                      InstalledAppActions.toggleIgnore(context, ref, app!),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.containers_groupLifecycle),
            SplitListGroup(
              children: [
                SplitListTile(
                  leading: const Icon(TablerIcons.player_play),
                  title: l10n.containers_start,
                  enabled: app.status.toLowerCase() != 'running',
                  onTap: () =>
                      InstalledAppActions.operate(context, ref, app!, 'start'),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.player_stop),
                  title: l10n.containers_stop,
                  enabled: app.status.toLowerCase() == 'running',
                  onTap: () =>
                      InstalledAppActions.operate(context, ref, app!, 'stop'),
                ),
                SplitListTile(
                  leading: const Icon(TablerIcons.refresh),
                  title: l10n.containers_restart,
                  enabled: app.status.toLowerCase() == 'running',
                  onTap: () => InstalledAppActions.operate(
                    context,
                    ref,
                    app!,
                    'restart',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            SectionHeader(title: l10n.containers_groupDanger),
            SplitListGroup(
              children: [
                SplitListTile(
                  leading: const Icon(TablerIcons.trash),
                  title: l10n.apps_uninstall,
                  danger: true,
                  onTap: () => InstalledAppActions.uninstall(
                    context,
                    ref,
                    app!,
                    detailId: detailId,
                    popOnDone: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(title: title, onClose: () => Navigator.of(context).pop()),
          const SizedBox(height: AppTokens.s8),
          Expanded(child: body),
        ],
      );
    }
    return Scaffold(
      appBar: AppBarLarge(
        title: title,
        actions: [
          AppIconButton(
            icon: TablerIcons.terminal_2,
            tooltip: l10n.containers_terminal,
            onPressed: container == null || container.isEmpty
                ? null
                : () => context.push(
                    '/s/$serverId/terminal?container=${Uri.encodeComponent(container)}',
                  ),
          ),
          AppIconButton(
            icon: TablerIcons.file_text,
            tooltip: container == null || container.isEmpty
                ? l10n.apps_installLog
                : l10n.containers_viewLogs,
            onPressed: container == null || container.isEmpty
                ? () => InstalledAppActions.showInstallLog(
                    context,
                    ref,
                    installId: id,
                    appName: appName,
                  )
                : () => openContainerLogs(
                    context,
                    ref,
                    containerName: container,
                    subtitle: appName,
                  ),
          ),
        ],
      ),
      body: body,
    );
  }
}

Future<void> showInstalledAppSheet(
  BuildContext context, {
  required int serverId,
  required String installId,
  int? detailId,
}) {
  final id = int.tryParse(installId) ?? 0;
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.94,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.86,
      child: InstalledAppPage(
        serverId: serverId,
        installId: '$id',
        detailId: detailId,
        embedded: true,
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/states/async_state_view.dart';
import '../providers/app_store_provider.dart';
import '../widgets/installed_app_actions.dart';

class InstalledAppPage extends ConsumerWidget {
  const InstalledAppPage({
    super.key,
    required this.serverId,
    required this.installId,
    this.detailId,
  });

  final int serverId;
  final String installId;
  final int? detailId;

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
    return Scaffold(
      appBar: AppBarLarge(
        title: appName.trim().isEmpty ? l10n.apps_installed : appName,
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
        ],
      ),
      body: AsyncStateView(
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
                    onTap: () => InstalledAppActions.operate(
                      context,
                      ref,
                      app!,
                      'start',
                    ),
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
                    onTap: () => _uninstall(context, ref, app!),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _uninstall(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app,
  ) async {
    final l10n = AppLocalizations.of(context);
    final targetDetailId = detailId ?? app.appDetailId;
    if (targetDetailId <= 0) {
      AppToast.warning(context, l10n.apps_detailMissing);
      return;
    }
    bool deleteDB = false;
    bool deleteBackup = false;
    bool deleteImage = false;
    bool force = false;
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.apps_uninstall, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s4),
            Text(
              l10n.apps_uninstallHint(app.displayName),
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.apps_deleteDatabase),
              value: deleteDB,
              onChanged: (value) => setState(() => deleteDB = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.apps_deleteBackup),
              value: deleteBackup,
              onChanged: (value) => setState(() => deleteBackup = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.apps_deleteImage),
              value: deleteImage,
              onChanged: (value) => setState(() => deleteImage = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.apps_forceDelete),
              value: force,
              onChanged: (value) => setState(() => force = value),
            ),
            const SizedBox(height: AppTokens.s16),
            DangerButton(
              label: l10n.apps_uninstall,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final repository = await ref.read(appRepositoryProvider.future);
    if (!context.mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: l10n.apps_uninstall,
      task: (controller) async {
        await repository.uninstallApp(
          installId: app.id,
          detailId: targetDetailId,
          taskID: taskID,
          forceDelete: force,
          deleteBackup: deleteBackup,
          deleteImage: deleteImage,
          deleteDB: deleteDB,
        );
        await InstalledAppActions.waitTask(controller, repository, taskID);
      },
    );
    if (!success || !context.mounted) return;
    ref.invalidate(installedAppsProvider);
    AppToast.success(context, l10n.action_done);
    context.pop();
  }
}

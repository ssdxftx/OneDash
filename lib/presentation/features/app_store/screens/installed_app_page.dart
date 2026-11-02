import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/components/app_toast.dart';
import '../../../../data/dto/app/app_installed_params_dto.dart';
import '../../../../data/dto/app/app_ignored_dto.dart';
import '../../../../data/dto/app/app_update_version_dto.dart';
import '../../../../data/dto/common/task_log_dto.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/states/async_state_view.dart';
import '../providers/app_store_provider.dart';
import '../../../common/states/error_toast.dart';

final _installedIgnoredProvider = FutureProvider.autoDispose
    .family<AppIgnoredDto?, int>((ref, installId) async {
      final repository = await ref.watch(appRepositoryProvider.future);
      final ignored = await repository.getIgnoredApps();
      for (final item in ignored) {
        if (item.appId == installId) return item;
      }
      return null;
    }, name: 'installedIgnoredProvider');

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
    final ignored = ref.watch(_installedIgnoredProvider(id)).valueOrNull;
    final container = info.valueOrNull?.container;
    return Scaffold(
      appBar: AppBarLarge(
        title: info.valueOrNull?.name ?? l10n.apps_installed,
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
          PopupMenuButton<String>(
            tooltip: l10n.action_more,
            onSelected: (value) {
              final app = info.valueOrNull;
              if (app == null) return;
              switch (value) {
                case 'upgrade':
                  _upgrade(context, ref, id, app);
                case 'params':
                  _editParams(context, ref, id);
                case 'port':
                  _changePort(context, ref, app);
                case 'conn':
                  _showConnInfo(context, ref, app);
                case 'ignore':
                  _ignoreUpdate(context, ref, id, app);
                case 'cancelIgnore':
                  _cancelIgnore(context, ref, id);
                case 'uninstall':
                  _uninstall(context, ref, id, app);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'upgrade', child: Text(l10n.apps_upgrade)),
              PopupMenuItem(value: 'params', child: Text(l10n.apps_editParams)),
              PopupMenuItem(value: 'port', child: Text(l10n.apps_changePort)),
              PopupMenuItem(value: 'conn', child: Text(l10n.apps_connInfo)),
              PopupMenuItem(
                value: ignored == null ? 'ignore' : 'cancelIgnore',
                child: Text(
                  ignored == null
                      ? l10n.apps_ignoreUpdate
                      : l10n.apps_cancelIgnoreUpdate,
                ),
              ),
              PopupMenuItem(
                value: 'uninstall',
                child: Text(l10n.apps_uninstall),
              ),
            ],
          ),
        ],
      ),
      body: AsyncStateView(
        value: info,
        onRetry: () => ref.invalidate(installedInfoProvider(id)),
        builder: (app) => ListView(
          padding: const EdgeInsets.all(AppTokens.s16),
          children: [
            TonalCard(
              child: Row(
                children: [
                  StatusDot(status: app.status.toLowerCase()),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.name, style: AppTextStyles.titleM),
                        Text(
                          '${app.version} · ${app.httpPort}',
                          style: AppTextStyles.bodyS.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _operate(context, ref, id, 'start'),
                    icon: const Icon(TablerIcons.player_play),
                    label: Text(l10n.containers_start),
                  ),
                ),
                const SizedBox(width: AppTokens.s8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _operate(context, ref, id, 'stop'),
                    icon: const Icon(TablerIcons.player_stop),
                    label: Text(l10n.containers_stop),
                  ),
                ),
                const SizedBox(width: AppTokens.s8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _operate(context, ref, id, 'restart'),
                    icon: const Icon(TablerIcons.refresh),
                    label: Text(l10n.containers_restart),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.s24),
            SplitListGroup(
              children: [
                SplitListTile(title: l10n.app_detail_key, subtitle: app.appKey),
                SplitListTile(
                  title: l10n.app_detail_container,
                  subtitle: app.container,
                ),
                SplitListTile(
                  title: l10n.app_detail_compose,
                  subtitle: app.composePath,
                ),
                if (app.message.isNotEmpty)
                  SplitListTile(
                    title: l10n.app_detail_message,
                    subtitle: app.message,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _waitTask(
    TaskProgressController controller,
    dynamic repository,
    String taskID,
  ) async {
    for (var attempt = 0; attempt < 120; attempt++) {
      final log = await repository.readTaskLog(taskID) as TaskLogDto;
      if (log.lines.isNotEmpty) controller.log(log.lines.last);
      final status = log.taskStatus.toLowerCase();
      if (status == 'success') return;
      if (status == 'failed' || status == 'error' || status == 'canceled') {
        throw Exception(log.lines.isEmpty ? 'Task failed' : log.lines.last);
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw const TaskFailedException(subject: 'Task', timedOut: true);
  }

  Future<void> _uninstall(
    BuildContext context,
    WidgetRef ref,
    int installId,
    dynamic app,
  ) async {
    final l10n = AppLocalizations.of(context);
    final detailId = this.detailId ?? 0;
    if (detailId <= 0) {
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
              l10n.apps_uninstallHint(app.name),
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
          installId: installId,
          detailId: detailId,
          taskID: taskID,
          forceDelete: force,
          deleteBackup: deleteBackup,
          deleteImage: deleteImage,
          deleteDB: deleteDB,
        );
        await _waitTask(controller, repository, taskID);
      },
    );
    if (!success || !context.mounted) return;
    ref.invalidate(installedAppsProvider);
    AppToast.success(context, l10n.action_done);
    context.pop();
  }

  Future<void> _upgrade(
    BuildContext context,
    WidgetRef ref,
    int installId,
    dynamic app,
  ) async {
    final l10n = AppLocalizations.of(context);
    final detailId = this.detailId ?? 0;
    if (detailId <= 0) {
      AppToast.warning(context, l10n.apps_detailMissing);
      return;
    }
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final versions = await repository.getUpdateVersions(installId);
      if (!context.mounted) return;
      if (versions.isEmpty) {
        AppToast.show(
          context,
          l10n.apps_latestVersion,
          type: AppToastType.info,
        );
        return;
      }
      AppUpdateVersionDto selected = versions.first;
      bool backup = true;
      bool pullImage = true;
      final confirmed = await showAppSheet<bool>(
        context: context,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.apps_upgrade, style: AppTextStyles.titleL),
              const SizedBox(height: AppTokens.s16),
              DropdownButtonFormField<String>(
                initialValue: selected.version,
                decoration: InputDecoration(labelText: l10n.apps_version),
                items: [
                  for (final version in versions)
                    DropdownMenuItem(
                      value: version.version,
                      child: Text(version.version),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(
                    () => selected = versions.firstWhere(
                      (item) => item.version == value,
                    ),
                  );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.apps_backupBeforeUpgrade),
                value: backup,
                onChanged: (value) => setState(() => backup = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.apps_pullImage),
                value: pullImage,
                onChanged: (value) => setState(() => pullImage = value),
              ),
              const SizedBox(height: AppTokens.s16),
              PrimaryButton(
                label: l10n.apps_upgrade,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
            ],
          ),
        ),
      );
      if (confirmed != true || !context.mounted) return;
      final taskID = const Uuid().v4();
      final success = await TaskProgressSheet.run(
        context,
        title: l10n.apps_upgrade,
        task: (controller) async {
          await repository.upgradeApp(
            installId: installId,
            detailId: detailId,
            version: selected.version,
            dockerCompose: selected.dockerCompose,
            taskID: taskID,
            backup: backup,
            pullImage: pullImage,
          );
          await _waitTask(controller, repository, taskID);
        },
      );
      if (!success || !context.mounted) return;
      ref.invalidate(installedInfoProvider(installId));
      ref.invalidate(installedAppsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editParams(
    BuildContext context,
    WidgetRef ref,
    int installId,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final data = await repository.getInstalledParams(installId);
      if (!context.mounted) return;
      final controllers = <String, TextEditingController>{
        for (final field in data.params)
          field.key: TextEditingController(text: '${field.value ?? ''}'),
      };
      final containerName = TextEditingController(text: data.containerName);
      final restartPolicy = TextEditingController(text: data.restartPolicy);
      final cpu = TextEditingController(text: '${data.cpuQuota}');
      final memory = TextEditingController(text: '${data.memoryLimit}');
      final dockerCompose = TextEditingController(text: data.dockerCompose);
      bool advanced = false;
      final saved = await showAppSheet<bool>(
        context: context,
        maxHeightFactor: 0.92,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.apps_editParams, style: AppTextStyles.titleL),
              const SizedBox(height: AppTokens.s16),
              for (final field in data.params)
                if (field.edit) ...[
                  AppTextField(
                    controller: controllers[field.key],
                    label: Localizations.localeOf(context).languageCode == 'zh'
                        ? field.labelZh
                        : field.labelEn,
                  ),
                  const SizedBox(height: AppTokens.s12),
                ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.apps_advancedParams),
                value: advanced,
                onChanged: (value) => setState(() => advanced = value),
              ),
              if (advanced) ...[
                AppTextField(
                  controller: containerName,
                  label: l10n.apps_containerName,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: restartPolicy,
                  label: l10n.containers_restartPolicy,
                ),
                const SizedBox(height: AppTokens.s12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: cpu,
                        label: l10n.containers_cpuLimit,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppTokens.s12),
                    Expanded(
                      child: AppTextField(
                        controller: memory,
                        label: l10n.containers_memoryLimit,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: dockerCompose,
                  label: 'docker-compose.yml',
                  maxLines: 8,
                ),
              ],
              const SizedBox(height: AppTokens.s16),
              PrimaryButton(
                label: l10n.action_save,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
            ],
          ),
        ),
      );
      final params = <String, dynamic>{
        for (final field in data.params)
          if (field.edit) field.key: controllers[field.key]?.text.trim(),
      };
      final request = AppInstalledParamsUpdateReq(
        installId: installId,
        params: params,
        advanced: advanced,
        containerName: containerName.text.trim(),
        allowPort: data.allowPort,
        restartPolicy: restartPolicy.text.trim(),
        cpuQuota: double.tryParse(cpu.text.trim()) ?? data.cpuQuota,
        memoryLimit: double.tryParse(memory.text.trim()) ?? data.memoryLimit,
        memoryUnit: data.memoryUnit,
        editCompose: data.editCompose,
        dockerCompose: dockerCompose.text,
        specifyIP: data.specifyIP,
      );
      for (final controller in controllers.values) {
        controller.dispose();
      }
      containerName.dispose();
      restartPolicy.dispose();
      cpu.dispose();
      memory.dispose();
      dockerCompose.dispose();
      if (saved != true || !context.mounted) return;
      await repository.updateInstalledParams(request);
      ref.invalidate(installedInfoProvider(installId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _changePort(
    BuildContext context,
    WidgetRef ref,
    dynamic app,
  ) async {
    final l10n = AppLocalizations.of(context);
    final port = TextEditingController(text: '${app.httpPort}');
    final value = await showAppSheet<int>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.apps_changePort, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: port,
            label: l10n.apps_port,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () {
              final parsed = int.tryParse(port.text.trim());
              if (parsed == null) return;
              Navigator.of(sheetContext).pop(parsed);
            },
          ),
        ],
      ),
    );
    port.dispose();
    if (value == null || !context.mounted) return;
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      await repository.changePort(key: app.appKey, name: app.name, port: value);
      ref.invalidate(installedInfoProvider(app.id));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showConnInfo(
    BuildContext context,
    WidgetRef ref,
    dynamic app,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final info = await repository.getConnInfo(
        type: app.appKey,
        name: app.name,
      );
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.apps_connInfo, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            SplitListGroup(
              children: [
                for (final entry in info.entries)
                  SplitListTile(title: entry.key, subtitle: '${entry.value}'),
              ],
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _ignoreUpdate(
    BuildContext context,
    WidgetRef ref,
    int installId,
    dynamic app,
  ) async {
    final l10n = AppLocalizations.of(context);
    final detailId = this.detailId ?? 0;
    if (detailId <= 0) {
      AppToast.warning(context, l10n.apps_detailMissing);
      return;
    }
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      await repository.ignoreUpdate(
        appId: installId,
        appDetailId: detailId,
        scope: 'app',
      );
      ref.invalidate(installedInfoProvider(installId));
      ref.invalidate(_installedIgnoredProvider(installId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _cancelIgnore(
    BuildContext context,
    WidgetRef ref,
    int installId,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final ignored = await repository.getIgnoredApps();
      AppIgnoredDto? target;
      for (final item in ignored) {
        if (item.appId == installId) {
          target = item;
          break;
        }
      }
      if (target == null) {
        if (!context.mounted) return;
        AppToast.warning(context, l10n.apps_notIgnored);
        return;
      }
      await repository.cancelIgnore(target.id);
      ref.invalidate(installedInfoProvider(installId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _operate(
    BuildContext context,
    WidgetRef ref,
    int installId,
    String operation,
  ) async {
    final detailId = this.detailId ?? 0;
    final l10n = AppLocalizations.of(context);
    if (detailId <= 0) {
      AppToast.warning(
        context,
        AppLocalizations.of(context).apps_detailMissing,
      );
      return;
    }
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      switch (operation) {
        case 'start':
          await repository.startInstalled(
            installId: installId,
            detailId: detailId,
          );
          break;
        case 'stop':
          await repository.stopInstalled(
            installId: installId,
            detailId: detailId,
          );
          break;
        case 'restart':
          await repository.restartInstalled(
            installId: installId,
            detailId: detailId,
          );
          break;
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(installedInfoProvider(installId));
      ref.invalidate(installedAppsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

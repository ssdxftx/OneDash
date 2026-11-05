import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/app/app_installed_params_dto.dart';
import '../../../../data/dto/app/app_update_version_dto.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/states/error_toast.dart';
import '../providers/app_store_provider.dart';

/// Shared installed-app actions so the store sheet and detail page stay in sync.
class InstalledAppActions {
  const InstalledAppActions._();

  static Future<void> operate(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app,
    String operation,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (app.appDetailId <= 0) {
      AppToast.warning(context, l10n.apps_detailMissing);
      return;
    }
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      switch (operation) {
        case 'start':
          await repository.startInstalled(
            installId: app.id,
            detailId: app.appDetailId,
          );
        case 'stop':
          await repository.stopInstalled(
            installId: app.id,
            detailId: app.appDetailId,
          );
        case 'restart':
          await repository.restartInstalled(
            installId: app.id,
            detailId: app.appDetailId,
          );
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(installedInfoProvider(app.id));
      ref.invalidate(installedAppsProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  static Future<void> upgrade(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (app.appDetailId <= 0) {
      AppToast.warning(context, l10n.apps_detailMissing);
      return;
    }
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final versions = await repository.getUpdateVersions(app.id);
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
      final confirmed = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.apps_upgrade,
            subtitle: app.displayName,
            saveLabel: l10n.apps_upgrade,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
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
              const SizedBox(height: AppTokens.s12),
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
            installId: app.id,
            detailId: app.appDetailId,
            version: selected.version,
            dockerCompose: selected.dockerCompose,
            taskID: taskID,
            backup: backup,
            pullImage: pullImage,
          );
          await waitTask(controller, repository, taskID);
        },
      );
      if (!success || !context.mounted) return;
      ref.invalidate(installedInfoProvider(app.id));
      ref.invalidate(installedAppsProvider);
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  static Future<void> editParams(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final data = await repository.getInstalledParams(app.id);
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
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.apps_editParams,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              for (final field in data.params)
                if (field.edit) ...[
                  AppTextField(
                    controller: controllers[field.key],
                    label:
                        Localizations.localeOf(pageContext).languageCode == 'zh'
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
            ],
          ),
        ),
      );
      final params = <String, dynamic>{
        for (final field in data.params)
          if (field.edit) field.key: controllers[field.key]?.text.trim(),
      };
      final request = AppInstalledParamsUpdateReq(
        installId: app.id,
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
      ref.invalidate(installedInfoProvider(app.id));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  static Future<void> changePort(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app,
  ) async {
    final l10n = AppLocalizations.of(context);
    final port = TextEditingController(text: '${app.httpPort}');
    final value = await pushFormPage<int>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.apps_changePort,
          onSave: () async {
            final parsed = int.tryParse(port.text.trim());
            if (parsed == null) return;
            Navigator.of(pageContext).pop(parsed);
          },
          children: [
            AppTextField(
              controller: port,
              label: l10n.apps_port,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
    port.dispose();
    if (value == null || !context.mounted) return;
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      await repository.changePort(key: app.appKey, name: app.name, port: value);
      ref.invalidate(installedInfoProvider(app.id));
      ref.invalidate(installedAppsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  static Future<void> showConnInfo(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(databaseRepositoryProvider.future);
      final info = await repository.getConnInfo(
        type: app.appKey,
        name: app.name,
      );
      if (!context.mounted) return;
      await pushFormPage<void>(
        context,
        Scaffold(
          appBar: AppBarLarge(
            title: l10n.apps_connInfo,
            subtitle: app.displayName,
          ),
          body: ListView(
            padding: EdgeInsets.all(context.pagePadding),
            children: [
              SplitListGroup(
                children: [
                  for (final entry in info.entries)
                    SplitListTile(title: entry.key, subtitle: '${entry.value}'),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  static Future<void> uninstall(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app, {
    int? detailId,
    bool popOnDone = false,
  }) async {
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
    try {
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
          await waitTask(controller, repository, taskID);
        },
      );
      if (!success || !context.mounted) return;
      ref.invalidate(installedInfoProvider(app.id));
      ref.invalidate(installedAppsProvider);
      AppToast.success(context, l10n.action_done);
      if (popOnDone && context.mounted) Navigator.of(context).maybePop();
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  static Future<void> toggleIgnore(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final ignored = await repository.getIgnoredApps();
      int? ignoredId;
      for (final item in ignored) {
        if (item.appId == app.id) {
          ignoredId = item.id;
          break;
        }
      }
      if (ignoredId != null) {
        await repository.cancelIgnore(ignoredId);
      } else {
        if (app.appDetailId <= 0) {
          if (!context.mounted) return;
          AppToast.warning(context, l10n.apps_detailMissing);
          return;
        }
        await repository.ignoreUpdate(
          appId: app.id,
          appDetailId: app.appDetailId,
          scope: 'app',
        );
      }
      ref.invalidate(installedInfoProvider(app.id));
      ref.invalidate(installedIgnoredProvider(app.id));
      ref.invalidate(installedAppsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  static Future<void> waitTask(
    TaskProgressController controller,
    dynamic repository,
    String taskID,
  ) async {
    for (var attempt = 0; attempt < 120; attempt++) {
      final log = await repository.readTaskLog(taskID);
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
}

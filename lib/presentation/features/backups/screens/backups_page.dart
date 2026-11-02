import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/backup/backup_record_dto.dart';
import '../../../../data/dto/backup/backup_record_search_req.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/repositories_impl/backup_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _backupRecordsProvider = FutureProvider.autoDispose
    .family<PageResult<BackupRecordDto>, String>((ref, type) async {
      final repository = await ref.watch(backupRepositoryProvider.future);
      return repository.searchRecords(
        BackupRecordSearchReq(
          page: 1,
          pageSize: 50,
          type: type,
          name: '',
          detailName: '',
        ),
      );
    }, name: 'backupRecordsProvider');

class BackupsPage extends ConsumerWidget {
  const BackupsPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.backups_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.cloud_cog,
            tooltip: l10n.backups_accounts,
            onPressed: () => context.push('/s/$serverId/more/backups/accounts'),
          ),
          AppIconButton(
            icon: TablerIcons.file_upload,
            tooltip: l10n.backups_restoreFromFile,
            onPressed: () => _restoreFromFile(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.calculator,
            tooltip: l10n.backups_calculateSizes,
            onPressed: () => _showSizes(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.backups_create,
            onPressed: () => _create(context, ref),
          ),
        ],
      ),
      body: SegmentedTabsView(
        labels: [
          l10n.backups_tabApps,
          l10n.backups_tabDatabases,
          l10n.backups_tabWebsites,
          l10n.backups_tabDirectories,
          l10n.containers_title,
        ],
        children: const [
          _BackupTab(type: 'app'),
          _BackupTab(type: 'database'),
          _BackupTab(type: 'website'),
          _BackupTab(type: 'directory'),
          _BackupTab(type: 'container'),
        ],
      ),
    );
  }
}

Future<void> _restoreFromFile(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final path = TextEditingController();
  final name = TextEditingController();
  final detail = TextEditingController();
  final secret = TextEditingController();
  String type = 'mysql';
  final saved = await showAppSheet<bool>(
    context: context,
    maxHeightFactor: 0.92,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.backups_restoreFromFile, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s8),
          Text(
            l10n.backups_restoreFromFileHint,
            style: AppTextStyles.bodyS.copyWith(
              color: sheetContext.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: path,
            label: l10n.backups_serverFilePath,
            hint: '/root/backup.tar.gz',
          ),
          const SizedBox(height: AppTokens.s12),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: InputDecoration(labelText: l10n.backups_type),
            items: const [
              DropdownMenuItem(value: 'mysql', child: Text('MySQL')),
              DropdownMenuItem(value: 'postgresql', child: Text('PostgreSQL')),
              DropdownMenuItem(value: 'mongodb', child: Text('MongoDB')),
              DropdownMenuItem(value: 'redis', child: Text('Redis')),
              DropdownMenuItem(value: 'app', child: Text('App')),
              DropdownMenuItem(value: 'website', child: Text('Website')),
              DropdownMenuItem(value: 'container', child: Text('Container')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => type = value);
            },
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: name, label: l10n.backups_resourceName),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: detail, label: l10n.backups_detailName),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: secret,
            label: l10n.backups_restoreSecret,
            obscure: true,
          ),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.backups_confirmRestore,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    ),
  );
  final filePath = path.text.trim();
  final resource = name.text.trim();
  final detailName = detail.text.trim();
  final secretValue = secret.text.trim();
  path.dispose();
  name.dispose();
  detail.dispose();
  secret.dispose();
  if (saved != true || !context.mounted || filePath.isEmpty) return;
  try {
    final repository = await ref.read(backupRepositoryProvider.future);
    const targetDir = '/opt/1panel/backup';
    await repository.uploadForRecover(filePath: filePath, targetDir: targetDir);
    final fileName = filePath.split('/').last;
    await repository.recoverByUpload(
      downloadAccountID: 1,
      type: type,
      name: resource.isEmpty ? fileName : resource,
      detailName: detailName,
      file: fileName,
      secret: secretValue,
      taskID: const Uuid().v4(),
    );
    if (!context.mounted) return;
    AppToast.success(context, l10n.backups_restoreSubmitted);
  } catch (error) {
    if (!context.mounted) return;
    showErrorToast(context, error);
  }
}

Future<void> _showSizes(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  try {
    final repository = await ref.read(backupRepositoryProvider.future);
    var total = 0;
    var count = 0;
    for (final type in const [
      'app',
      'database',
      'website',
      'directory',
      'container',
    ]) {
      final sizes = await repository.recordSizes(
        BackupRecordSearchReq(
          page: 1,
          pageSize: 1000,
          type: type,
          name: '',
          detailName: '',
        ),
      );
      count += sizes.length;
      for (final item in sizes) {
        total += item.size;
      }
    }
    if (!context.mounted) return;
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.backups_calculateSizes, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                title: l10n.backups_recordCount,
                trailing: Text('$count'),
              ),
              SplitListTile(
                title: l10n.backups_totalSize,
                trailing: Text(formatBytes(total)),
              ),
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

Future<void> _create(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final name = TextEditingController();
  final detail = TextEditingController();
  final secret = TextEditingController();
  final description = TextEditingController();
  String type = 'mysql';
  bool stopBefore = false;
  final confirmed = await showAppSheet<bool>(
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.backups_create, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: InputDecoration(labelText: l10n.backups_type),
            items: [
              DropdownMenuItem(value: 'app', child: Text(l10n.backups_tabApps)),
              const DropdownMenuItem(value: 'mysql', child: Text('MySQL')),
              const DropdownMenuItem(
                value: 'postgresql',
                child: Text('PostgreSQL'),
              ),
              const DropdownMenuItem(value: 'mongodb', child: Text('MongoDB')),
              const DropdownMenuItem(value: 'redis', child: Text('Redis')),
              DropdownMenuItem(
                value: 'website',
                child: Text(l10n.backups_tabWebsites),
              ),
              DropdownMenuItem(
                value: 'container',
                child: Text(l10n.containers_title),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => type = value);
            },
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: name,
            label: l10n.backups_resourceName,
            hint: type == 'app' ? 'app-key' : 'instance or container',
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: detail,
            label: l10n.backups_detailName,
            hint: type == 'app'
                ? 'install-name'
                : type == 'website'
                ? 'site-alias'
                : 'database-name',
          ),
          if (type == 'mysql' ||
              type == 'postgresql' ||
              type == 'mongodb' ||
              type == 'redis') ...[
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: secret,
              label: l10n.backups_dbPassword,
              obscure: true,
            ),
          ],
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: description,
            label: l10n.backups_description,
          ),
          if (type == 'container')
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.backups_stopBefore),
              value: stopBefore,
              onChanged: (value) => setState(() => stopBefore = value),
            ),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.backups_startBackup,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    ),
  );
  final resource = name.text.trim();
  final detailName = detail.text.trim();
  final dbSecret = secret.text.trim();
  final note = description.text.trim();
  name.dispose();
  detail.dispose();
  secret.dispose();
  description.dispose();
  if (confirmed != true || !context.mounted) return;
  if (resource.isEmpty) return;
  final repository = await ref.read(backupRepositoryProvider.future);
  if (!context.mounted) return;
  final taskID = const Uuid().v4();
  final success = await TaskProgressSheet.run(
    context,
    title: l10n.backups_create,
    task: (controller) async {
      switch (type) {
        case 'app':
          await repository.backupApp(
            name: resource,
            detailName: detailName,
            secret: dbSecret,
            taskID: taskID,
            description: note,
          );
        case 'mysql':
        case 'postgresql':
        case 'mongodb':
        case 'redis':
          await repository.backupDatabase(
            type: type,
            name: resource,
            detailName: detailName,
            secret: dbSecret,
            taskID: taskID,
            description: note,
          );
        case 'website':
          await repository.backupDatabase(
            type: 'website',
            name: detailName.isEmpty ? resource : detailName,
            detailName: detailName.isEmpty ? resource : detailName,
            secret: dbSecret,
            taskID: taskID,
            description: note,
          );
        case 'container':
          await repository.backupContainer(
            name: resource,
            detailName: detailName,
            secret: dbSecret,
            taskID: taskID,
            description: note,
            stopBefore: stopBefore,
          );
      }
      for (var attempt = 0; attempt < 120; attempt++) {
        final log = await repository.readTaskLog(taskID, latest: true);
        if (log.lines.isNotEmpty) controller.log(log.lines.last);
        final status = log.taskStatus.toLowerCase();
        if (status == 'success') return;
        if (status == 'failed' || status == 'error' || status == 'canceled') {
          throw Exception(log.lines.isEmpty ? 'Task failed' : log.lines.last);
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    },
  );
  if (!success || !context.mounted) return;
  AppToast.success(context, l10n.action_done);
  ref.invalidate(_backupRecordsProvider(type));
}

class _BackupTab extends ConsumerWidget {
  const _BackupTab({required this.type});

  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final records = ref.watch(_backupRecordsProvider(type));
    return AsyncStateView(
      value: records,
      onRetry: () => ref.invalidate(_backupRecordsProvider(type)),
      loading: const SkeletonList(itemCount: 8),
      isEmpty: (data) => data.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.cloud_upload,
        title: l10n.backups_empty_title,
        message: l10n.backups_empty_message,
      ),
      builder: (data) => ListView.builder(
        padding: const EdgeInsets.all(AppTokens.s16),
        itemCount: data.items.length,
        itemBuilder: (context, index) {
          final record = data.items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s12),
            child: TonalCard(
              onLongPress: () => _showActions(context, ref, record),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusDot(status: record.status.toLowerCase()),
                      const SizedBox(width: AppTokens.s8),
                      Expanded(
                        child: Text(
                          record.fileName.trim().isEmpty
                              ? l10n.backups_recordUntitled
                              : record.fileName,
                          style: AppTextStyles.titleS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatBytes(record.size),
                        style: AppTextStyles.caption,
                      ),
                      IconButton(
                        tooltip: l10n.action_more,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          TablerIcons.dots,
                          size: AppTokens.iconList,
                        ),
                        onPressed: () => _showActions(context, ref, record),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s4),
                  Text(
                    record.filePath,
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTokens.s8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${taskStatusLabel(record.status, l10n)} · '
                          '${record.accountName}',
                          style: AppTextStyles.caption.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        record.createdAt == null
                            ? '-'
                            : formatRelativeTime(record.createdAt, l10n),
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    BackupRecordDto record,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.fileName, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            record.filePath,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.download),
                title: l10n.backups_downloadUrl,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  try {
                    final repository = await ref.read(
                      backupRepositoryProvider.future,
                    );
                    final url = await repository.downloadRecord(
                      downloadAccountID: record.downloadAccountID,
                      fileDir: record.fileDir,
                      fileName: record.fileName,
                    );
                    await Clipboard.setData(ClipboardData(text: url));
                    if (!context.mounted) return;
                    AppToast.success(context, url);
                  } catch (error) {
                    if (!context.mounted) return;
                    showErrorToast(context, error);
                  }
                },
              ),
              if (type == 'app' || type == 'database')
                SplitListTile(
                  leading: const Icon(TablerIcons.restore),
                  title: l10n.backups_restoreThis,
                  danger: true,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _restore(context, ref, record);
                  },
                ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.action_delete,
                danger: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await showConfirmSheet(
                    context,
                    title: l10n.action_delete,
                    message: record.fileName,
                    confirmLabel: l10n.action_delete,
                  );
                  if (!confirmed) return;
                  try {
                    final repository = await ref.read(
                      backupRepositoryProvider.future,
                    );
                    await repository.deleteRecords([record.id]);
                    if (!context.mounted) return;
                    AppToast.success(context, l10n.action_done);
                    ref.invalidate(_backupRecordsProvider(type));
                  } catch (error) {
                    if (!context.mounted) return;
                    showErrorToast(context, error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    BackupRecordDto record,
  ) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final detailController = TextEditingController();
    final secretController = TextEditingController();
    final dbTypeController = TextEditingController(text: 'mysql');
    final isApp = type == 'app';
    final isContainer = type == 'container';
    final confirmed = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.backups_restoreTitle),
          Text(
            record.fileName,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: nameController,
            label: l10n.backups_resourceName,
            hint: isApp
                ? l10n.backups_appNameHint
                : isContainer
                ? l10n.backups_containerHint
                : l10n.backups_databaseInstanceHint,
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: detailController,
            label: l10n.backups_detailName,
            hint: isApp
                ? l10n.backups_appDetailHint
                : l10n.backups_databaseNameHint,
          ),
          if (!isApp) ...[
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: dbTypeController,
              label: l10n.backups_databaseType,
              hint: 'mysql / postgresql',
            ),
          ],
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: secretController,
            label: l10n.backups_restoreSecret,
            obscure: true,
          ),
          const SizedBox(height: AppTokens.s24),
          DangerButton(
            label: l10n.backups_confirmRestore,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      nameController.dispose();
      detailController.dispose();
      secretController.dispose();
      dbTypeController.dispose();
      return;
    }
    final name = nameController.text.trim();
    final detail = detailController.text.trim();
    final secret = secretController.text.trim();
    final dbType = dbTypeController.text.trim();
    nameController.dispose();
    detailController.dispose();
    secretController.dispose();
    dbTypeController.dispose();
    if (!context.mounted) return;
    if (name.isEmpty || detail.isEmpty || secret.isEmpty) {
      AppToast.error(context, l10n.backups_restoreParamsRequired);
      return;
    }
    try {
      final repository = await ref.read(backupRepositoryProvider.future);
      if (isContainer) {
        await repository.recoverContainer(
          downloadAccountID: record.downloadAccountID,
          name: name,
          detailName: detail,
          file: record.fileName,
          secret: secret,
          taskID: const Uuid().v4(),
          backupRecordID: record.id,
          timeout: 600,
        );
      } else if (isApp) {
        await repository.recoverApp(
          downloadAccountID: record.downloadAccountID,
          name: name,
          detailName: detail,
          file: record.fileName,
          secret: secret,
          taskID: const Uuid().v4(),
          backupRecordID: record.id,
        );
      } else {
        await repository.recoverDatabase(
          downloadAccountID: record.downloadAccountID,
          type: dbType,
          name: name,
          detailName: detail,
          file: record.fileName,
          secret: secret,
          taskID: const Uuid().v4(),
        );
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.backups_restoreSubmitted);
      ref.invalidate(_backupRecordsProvider(type));
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

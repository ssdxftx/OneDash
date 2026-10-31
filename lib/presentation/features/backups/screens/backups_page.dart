import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

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
import '../../../common/components/tonal_card.dart';
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
      appBar: AppBarLarge(title: l10n.backups_title),
      body: SegmentedTabsView(
        labels: [
          l10n.backups_tabApps,
          l10n.backups_tabDatabases,
          l10n.backups_tabWebsites,
          l10n.backups_tabDirectories,
        ],
        children: const [
          _BackupTab(type: 'app'),
          _BackupTab(type: 'database'),
          _BackupTab(type: 'website'),
          _BackupTab(type: 'directory'),
        ],
      ),
    );
  }
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
                          record.fileName,
                          style: AppTextStyles.titleS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatBytes(record.size),
                        style: AppTextStyles.caption,
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
                          record.accountName,
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
      if (isApp) {
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

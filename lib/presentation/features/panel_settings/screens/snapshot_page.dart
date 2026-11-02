import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _snapshotsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = await ref.watch(settingRepositoryProvider.future);
      final result = await repository.searchSnapshots(page: 1, pageSize: 100);
      return (result['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          const [];
    }, name: 'snapshotsProvider');

class SnapshotPage extends ConsumerWidget {
  const SnapshotPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapshots = ref.watch(_snapshotsProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.panelSettings_snapshots,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_snapshotsProvider),
          ),
          AppIconButton(
            icon: TablerIcons.upload,
            tooltip: l10n.panelSettings_importSnapshot,
            onPressed: () => _import(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.panelSettings_createSnapshot,
            onPressed: () => _create(context, ref),
          ),
        ],
      ),
      body: AsyncStateView(
        value: snapshots,
        onRetry: () => ref.invalidate(_snapshotsProvider),
        loading: const SkeletonList(itemCount: 6),
        isEmpty: (items) => items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.camera_off,
          title: l10n.panelSettings_noSnapshots,
          message: l10n.panelSettings_noSnapshotsHint,
        ),
        builder: (items) => ListView.separated(
          padding: const EdgeInsets.all(AppTokens.s16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
          itemBuilder: (context, index) {
            final item = items[index];
            final id = (item['id'] as num?)?.toInt() ?? 0;
            final status = '${item['status'] ?? ''}';
            return TonalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusDot(status: status.toLowerCase()),
                      const SizedBox(width: AppTokens.s8),
                      Expanded(
                        child: Text(
                          '${item['name'] ?? ''}',
                          style: AppTextStyles.titleM,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatBytes(item['size']),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s4),
                  Text(
                    '${item['createdAt'] ?? ''} · ${item['version'] ?? ''}',
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  if ('${item['description'] ?? ''}'.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      '${item['description']}',
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTokens.s8),
                  Wrap(
                    spacing: AppTokens.s8,
                    children: [
                      TextButton(
                        onPressed: () => _editDescription(
                          context,
                          ref,
                          id,
                          '${item['description'] ?? ''}',
                        ),
                        child: Text(l10n.action_edit),
                      ),
                      TextButton(
                        onPressed: () => _recreate(context, ref, id),
                        child: Text(l10n.panelSettings_recreateSnapshot),
                      ),
                      TextButton(
                        onPressed: () => _restore(context, ref, id),
                        child: Text(l10n.panelSettings_restoreSnapshot),
                      ),
                      TextButton(
                        onPressed: () => _rollback(context, ref, id),
                        child: Text(l10n.panelSettings_rollbackSnapshot),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: context.appColors.danger,
                        ),
                        onPressed: () => _delete(context, ref, id),
                        child: Text(l10n.action_delete),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.92,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.panelSettings_importSnapshot, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            label: l10n.panelSettings_snapshotJson,
            maxLines: 12,
          ),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.action_import,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final raw = controller.text.trim();
    controller.dispose();
    if (saved != true || raw.isEmpty || !context.mounted) return;
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        AppToast.warning(context, l10n.panelSettings_snapshotJsonInvalid);
        return;
      }
      data = decoded;
    } catch (_) {
      AppToast.warning(context, l10n.panelSettings_snapshotJsonInvalid);
      return;
    }
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.importSnapshot(data);
      ref.invalidate(_snapshotsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<String?> _askSecret(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.panelSettings_snapshotSecret, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: controller, obscure: true),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.action_continue,
            onPressed: () =>
                Navigator.of(sheetContext).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<void> _restore(BuildContext context, WidgetRef ref, int id) async {
    final l10n = AppLocalizations.of(context);
    final secret = await _askSecret(context, l10n);
    if (secret == null || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.recoverSnapshot(
        id: id,
        taskID: const Uuid().v4(),
        secret: secret,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_snapshotRestoreSubmitted);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _rollback(BuildContext context, WidgetRef ref, int id) async {
    final l10n = AppLocalizations.of(context);
    final secret = await _askSecret(context, l10n);
    if (secret == null || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.rollbackSnapshot(
        id: id,
        taskID: const Uuid().v4(),
        secret: secret,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_snapshotRestoreSubmitted);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(
      text: 'snapshot-${DateTime.now().millisecondsSinceEpoch}',
    );
    final description = TextEditingController();
    final flags = <String, bool>{
      'withDockerConf': true,
      'withMonitorData': false,
      'withLoginLog': false,
      'withOperationLog': false,
      'withSystemLog': false,
      'withTaskLog': false,
    };
    final saved = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.panelSettings_createSnapshot,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: name,
              label: l10n.panelSettings_snapshotName,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: description,
              label: l10n.panelSettings_snapshotDescription,
            ),
            for (final entry in flags.entries)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_flagLabel(entry.key, l10n)),
                value: entry.value,
                onChanged: (value) => setState(() => flags[entry.key] = value),
              ),
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: l10n.panelSettings_createSnapshot,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    final snapshotName = name.text.trim();
    final note = description.text.trim();
    final options = Map<String, bool>.of(flags);
    name.dispose();
    description.dispose();
    if (saved != true || !context.mounted || snapshotName.isEmpty) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.createSnapshot({
        'name': snapshotName,
        'taskID': const Uuid().v4(),
        'sourceAccountIDs': '1',
        'downloadAccountID': 1,
        'description': note,
        'secret': '',
        ...options,
      });
      ref.invalidate(_snapshotsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.panelSettings_snapshotCreated);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  String _flagLabel(String key, AppLocalizations l10n) {
    return switch (key) {
      'withDockerConf' => l10n.panelSettings_withDockerConf,
      'withMonitorData' => l10n.panelSettings_withMonitorData,
      'withLoginLog' => l10n.panelSettings_withLoginLog,
      'withOperationLog' => l10n.panelSettings_withOperationLog,
      'withSystemLog' => l10n.panelSettings_withSystemLog,
      _ => l10n.panelSettings_withTaskLog,
    };
  }

  Future<void> _editDescription(
    BuildContext context,
    WidgetRef ref,
    int id,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.panelSettings_snapshotDescription,
            style: AppTextStyles.titleL,
          ),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: controller),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () =>
                Navigator.of(sheetContext).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.updateSnapshotDescription(id, value);
      ref.invalidate(_snapshotsProvider);
      if (!context.mounted) return;
      AppToast.success(context, AppLocalizations.of(context).action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _recreate(BuildContext context, WidgetRef ref, int id) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.panelSettings_recreateSnapshot,
      message: l10n.panelSettings_recreateSnapshotHint,
      confirmLabel: l10n.panelSettings_recreateSnapshot,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.recreateSnapshot(id);
      ref.invalidate(_snapshotsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int id) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: l10n.panelSettings_deleteSnapshotHint,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.deleteSnapshots(ids: [id], deleteWithFile: true);
      ref.invalidate(_snapshotsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

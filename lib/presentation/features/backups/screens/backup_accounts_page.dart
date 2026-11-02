import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/backup_account_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _accountsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = await ref.watch(
        backupAccountRepositoryProvider.future,
      );
      final result = await repository.searchAccounts(page: 1, pageSize: 100);
      return (result['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          const [];
    }, name: 'backupAccountsProvider');

class BackupAccountsPage extends ConsumerWidget {
  const BackupAccountsPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(_accountsProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.backups_accounts,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_accountsProvider),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.backups_addAccount,
            onPressed: () => _edit(context, ref),
          ),
        ],
      ),
      body: AsyncStateView(
        value: accounts,
        onRetry: () => ref.invalidate(_accountsProvider),
        loading: const SkeletonList(itemCount: 6),
        isEmpty: (items) => items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.cloud_off,
          title: l10n.backups_noAccounts,
          message: l10n.backups_noAccountsHint,
        ),
        builder: (items) => ListView.separated(
          padding: const EdgeInsets.all(AppTokens.s16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
          itemBuilder: (context, index) {
            final account = items[index];
            final name = '${account['name'] ?? ''}';
            final type = '${account['type'] ?? ''}';
            final path = '${account['backupPath'] ?? ''}';
            final typeLabel = backupAccountTypeLabel(type, l10n);
            final nameLower = name.toLowerCase();
            final nameHasType =
                nameLower.contains(type.toLowerCase()) ||
                nameLower.contains(typeLabel.toLowerCase());
            final subtitle = [
              if (!nameHasType) typeLabel,
              if (path.isNotEmpty) path,
            ].join(' · ');
            return TonalCard(
              onTap: () => _edit(context, ref, account),
              child: Row(
                children: [
                  Icon(
                    type.toLowerCase() == 'local'
                        ? TablerIcons.folder
                        : TablerIcons.cloud,
                    color: context.scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.titleM),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: l10n.action_more,
                    icon: const Icon(TablerIcons.dots),
                    onSelected: (value) {
                      if (value == 'buckets') _buckets(context, ref, account);
                      if (value == 'refresh') _refresh(context, ref, account);
                      if (value == 'test') _test(context, ref, account);
                      if (value == 'delete') _delete(context, ref, account);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'buckets',
                        child: Text(l10n.backups_listBuckets),
                      ),
                      PopupMenuItem(
                        value: 'refresh',
                        child: Text(l10n.backups_refreshToken),
                      ),
                      PopupMenuItem(
                        value: 'test',
                        child: Text(l10n.backups_testConnection),
                      ),
                      PopupMenuItem(
                        value: 'delete',
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

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    Map<String, dynamic>? current,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: '${current?['name'] ?? ''}');
    final accessKey = TextEditingController(
      text: '${current?['accessKey'] ?? ''}',
    );
    final credential = TextEditingController(
      text: '${current?['credential'] ?? ''}',
    );
    final bucket = TextEditingController(text: '${current?['bucket'] ?? ''}');
    final backupPath = TextEditingController(
      text: '${current?['backupPath'] ?? ''}',
    );
    final vars = TextEditingController(text: '${current?['vars'] ?? ''}');
    final rawType = '${current?['type'] ?? backupAccountTypes.first}'
        .toUpperCase();
    final isLocalAccount = rawType == backupAccountLocal;
    String type = isLocalAccount || backupAccountTypes.contains(rawType)
        ? rawType
        : backupAccountTypes.first;
    bool rememberAuth = current?['rememberAuth'] == true;
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.92,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current == null
                  ? l10n.backups_addAccount
                  : l10n.backups_editAccount,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s16),
            AppTextField(controller: name, label: l10n.backups_accountName),
            const SizedBox(height: AppTokens.s12),
            if (isLocalAccount)
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.backups_accountType,
                ),
                child: Text(l10n.backups_typeLocal),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(
                  labelText: l10n.backups_accountType,
                ),
                items: [
                  for (final value in backupAccountTypes)
                    DropdownMenuItem(
                      value: value,
                      child: Text(backupAccountTypeLabel(value, l10n)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => type = value);
                },
              ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: accessKey, label: l10n.backups_accessKey),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: credential,
              label: l10n.backups_credential,
              obscure: true,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: bucket, label: l10n.backups_bucket),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: backupPath,
              label: l10n.backups_backupPath,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: vars,
              label: l10n.backups_vars,
              hint: '{"endpoint": "https://..."}',
              maxLines: 4,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.backups_rememberAuth),
              value: rememberAuth,
              onChanged: (value) => setState(() => rememberAuth = value),
            ),
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    final payload = <String, dynamic>{
      if (current?['id'] != null) 'id': current!['id'],
      'name': name.text.trim(),
      'type': type,
      'isPublic': current?['isPublic'] ?? false,
      'bucket': bucket.text.trim(),
      'accessKey': accessKey.text.trim(),
      'credential': credential.text.trim(),
      'backupPath': backupPath.text.trim(),
      'vars': vars.text.trim(),
      'rememberAuth': rememberAuth,
    };
    name.dispose();
    accessKey.dispose();
    credential.dispose();
    bucket.dispose();
    backupPath.dispose();
    vars.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(backupAccountRepositoryProvider.future);
      if (current == null) {
        await repository.createAccount(payload);
      } else {
        await repository.updateAccount(payload);
      }
      ref.invalidate(_accountsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _test(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> account,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(backupAccountRepositoryProvider.future);
      final result = await repository.checkConnection({
        'name': account['name'] ?? '',
        'type': account['type'] ?? '',
        'isPublic': account['isPublic'] ?? false,
        'bucket': account['bucket'] ?? '',
        'accessKey': account['accessKey'] ?? '',
        'credential': account['credential'] ?? '',
        'backupPath': account['backupPath'] ?? '',
        'vars': account['vars'] ?? '',
        'rememberAuth': account['rememberAuth'] ?? false,
      });
      if (!context.mounted) return;
      final ok = result['isOk'] == true;
      if (ok) {
        AppToast.success(context, l10n.backups_connectionOk);
      } else {
        AppToast.error(
          context,
          '${result['msg'] ?? l10n.backups_connectionFailed}',
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Map<String, dynamic> _accountPayload(Map<String, dynamic> account) => {
    'name': account['name'] ?? '',
    'type': account['type'] ?? '',
    'isPublic': account['isPublic'] ?? false,
    'bucket': account['bucket'] ?? '',
    'accessKey': account['accessKey'] ?? '',
    'credential': account['credential'] ?? '',
    'backupPath': account['backupPath'] ?? '',
    'vars': account['vars'] ?? '',
    'rememberAuth': account['rememberAuth'] ?? false,
  };

  Future<void> _buckets(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> account,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(backupAccountRepositoryProvider.future);
      final buckets = await repository.listBuckets(_accountPayload(account));
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.backups_buckets, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (buckets.isEmpty)
              Text(l10n.state_empty)
            else
              for (final bucket in buckets)
                ListTile(dense: true, title: Text('$bucket')),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _refresh(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final id = account['id'];
    if (id is! num) return;
    try {
      final repository = await ref.read(backupAccountRepositoryProvider.future);
      await repository.refreshToken(id.toInt());
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final id = account['id'];
    if (id is! num) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: l10n.backups_deleteAccountConfirm('${account['name'] ?? ''}'),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(backupAccountRepositoryProvider.future);
      await repository.deleteAccount(id.toInt());
      ref.invalidate(_accountsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

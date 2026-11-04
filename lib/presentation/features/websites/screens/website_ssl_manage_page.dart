import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _sslListProvider = FutureProvider.autoDispose<List<SslManageDto>>((
  ref,
) async {
  final repository = await ref.watch(websiteRepositoryProvider.future);
  final result = await repository.searchSsl({'page': 1, 'pageSize': 100});
  return result.items;
}, name: 'sslManageListProvider');

class WebsiteSslManagePage extends ConsumerWidget {
  const WebsiteSslManagePage({
    super.key,
    required this.serverId,
    required this.websiteId,
    required this.domain,
  });

  final int serverId;
  final int websiteId;
  final String domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final certs = ref.watch(_sslListProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.websites_sslManage,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_sslListProvider),
          ),
          AppIconButton(
            icon: TablerIcons.upload,
            tooltip: l10n.websites_uploadSsl,
            onPressed: () => _upload(context, ref),
          ),
          AppIconButton(
            icon: TablerIcons.plus,
            tooltip: l10n.websites_applySsl,
            onPressed: () => _apply(context, ref, domain),
          ),
        ],
      ),
      body: AsyncStateView(
        value: certs,
        onRetry: () => ref.invalidate(_sslListProvider),
        loading: const SkeletonList(itemCount: 6),
        isEmpty: (items) => items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.shield_off,
          title: l10n.websites_noSslCertificate,
          message: l10n.websites_sslManageHint,
          actionLabel: l10n.websites_uploadSsl,
          onAction: () => _upload(context, ref),
        ),
        builder: (items) => ListView.separated(
          padding: EdgeInsets.all(context.pagePadding),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
          itemBuilder: (context, index) {
            final cert = items[index];
            final expiry = _expiryState(context, cert, l10n);
            return TonalCard(
              onTap: () => _showActions(context, ref, cert),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusDot(status: cert.status.toLowerCase()),
                      const SizedBox(width: AppTokens.s8),
                      Expanded(
                        child: Text(
                          cert.primaryDomain.isEmpty
                              ? 'SSL #${cert.id}'
                              : cert.primaryDomain,
                          style: AppTextStyles.titleS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        TablerIcons.chevron_right,
                        size: AppTokens.iconList,
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s8),
                  SplitListGroup(
                    flat: true,
                    children: [
                      SplitListTile(
                        title: l10n.websites_sslProvider,
                        value: sslProviderLabel(cert.provider, l10n),
                      ),
                      SplitListTile(
                        title: l10n.websites_sslExpire,
                        value: expiry == null
                            ? cert.expireDate
                            : '${expiry.label} · ${cert.expireDate}',
                        valueStyle: expiry == null
                            ? null
                            : TextStyle(color: expiry.color),
                      ),
                      SplitListTile(
                        title: l10n.websites_autoRenew,
                        value: cert.autoRenew
                            ? l10n.websites_enabled
                            : l10n.websites_disabled,
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

  ({String label, Color color})? _expiryState(
    BuildContext context,
    SslManageDto cert,
    AppLocalizations l10n,
  ) {
    final date = DateTime.tryParse(cert.expireDate);
    if (date == null) return null;
    final days = date.difference(DateTime.now()).inDays;
    if (days < 0) {
      return (label: l10n.websites_sslExpired, color: context.appColors.danger);
    }
    if (days <= 30) {
      return (
        label: l10n.websites_expire_days(days),
        color: context.appColors.warning,
      );
    }
    return null;
  }

  Future<void> _upload(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final cert = TextEditingController();
    final key = TextEditingController();
    final description = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.websites_uploadSsl,
          saveLabel: l10n.action_upload,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: cert,
              label: l10n.websites_certificatePem,
              maxLines: 8,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: key,
              label: l10n.websites_privateKeyPem,
              maxLines: 8,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: description, label: l10n.websites_remark),
          ],
        ),
      ),
    );
    final certificate = cert.text.trim();
    final privateKey = key.text.trim();
    final note = description.text.trim();
    cert.dispose();
    key.dispose();
    description.dispose();
    if (saved != true || !context.mounted) return;
    if (certificate.isEmpty || privateKey.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.uploadSsl(
        type: 'paste',
        certificate: certificate,
        privateKey: privateKey,
        description: note,
      );
      ref.invalidate(_sslListProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.websites_sslUploaded);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    String domain,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final accounts = await repository.searchAcmeAccounts();
      if (!context.mounted) return;
      if (accounts.isEmpty) {
        AppToast.warning(context, l10n.websites_noAcmeAccount);
        return;
      }
      final domainController = TextEditingController(text: domain);
      final description = TextEditingController();
      int accountId = accounts.first.id;
      bool autoRenew = true;
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.websites_applySsl,
            saveLabel: l10n.websites_applySsl,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              AppTextField(
                controller: domainController,
                label: l10n.websites_domain,
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<int>(
                initialValue: accountId,
                decoration: InputDecoration(
                  labelText: l10n.websites_acmeAccount,
                ),
                items: [
                  for (final account in accounts)
                    DropdownMenuItem(
                      value: account.id,
                      child: Text(account.displayName),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => accountId = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: description,
                label: l10n.websites_remark,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_autoRenew),
                value: autoRenew,
                onChanged: (value) => setState(() => autoRenew = value),
              ),
            ],
          ),
        ),
      );
      final target = domainController.text.trim();
      final note = description.text.trim();
      domainController.dispose();
      description.dispose();
      if (saved != true || !context.mounted || target.isEmpty) return;
      final created = SslCreateReq(
        primaryDomain: target,
        otherDomains: '',
        provider: 'http',
        keyType: 'P256',
        description: note,
        dir: '',
        shell: '',
        nodes: '',
        acmeAccountId: accountId,
        dnsAccountId: 0,
        autoRenew: autoRenew,
        pushDir: false,
        execShell: false,
        pushNode: false,
        isIp: false,
        disableCNAME: false,
        skipDNS: false,
        nameserver1: '',
        nameserver2: '',
      );
      await repository.createSsl(created);
      final page = await repository.searchSsl({'page': 1, 'pageSize': 100});
      SslManageDto? cert;
      for (final item in page.items) {
        if (item.primaryDomain == target) {
          cert = item;
          break;
        }
      }
      if (cert != null) await repository.obtainSsl(cert.id);
      ref.invalidate(_sslListProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.websites_sslRequested);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    SslManageDto cert,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cert.primaryDomain.isEmpty ? 'SSL #${cert.id}' : cert.primaryDomain,
            style: AppTextStyles.titleL,
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.download),
                title: l10n.websites_downloadSsl,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _download(context, ref, cert);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.world_check),
                title: l10n.websites_checkDns,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _checkDns(context, ref, cert);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.edit),
                title: l10n.action_edit,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _edit(context, ref, cert);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.action_delete,
                danger: true,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _delete(context, ref, cert);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    SslManageDto cert,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final response = await repository.downloadSsl(cert.id);
      final raw = response.data;
      final bytes = raw is List<int> ? Uint8List.fromList(raw) : null;
      if (bytes == null) return;
      final name = cert.primaryDomain.isEmpty
          ? 'ssl-${cert.id}.zip'
          : '${cert.primaryDomain}.zip';
      final path = await FilePicker.saveFile(fileName: name, bytes: bytes);
      if (path == null || !context.mounted) return;
      AppToast.success(context, l10n.websites_downloaded(path));
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _checkDns(
    BuildContext context,
    WidgetRef ref,
    SslManageDto cert,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final results = await repository.resolveSsl(cert.acmeAccountId, cert.id);
      if (!context.mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.websites_checkDns, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (results.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.world_off,
                title: l10n.state_empty,
              )
            else
              SplitListGroup(
                children: [
                  for (final item in results)
                    SplitListTile(
                      leading: StatusDot(
                        status: item.err.isEmpty ? 'running' : 'error',
                      ),
                      title: item.domain,
                      subtitle: item.err.isEmpty
                          ? '${item.resolve}: ${item.value}'
                          : item.err,
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

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    SslManageDto cert,
  ) async {
    final l10n = AppLocalizations.of(context);
    final description = TextEditingController(text: cert.description);
    bool autoRenew = cert.autoRenew;
    final saved = await pushFormPage<bool>(
      context,
      StatefulBuilder(
        builder: (pageContext, setState) => SimpleFormPage(
          title: l10n.websites_editSsl,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: description, label: l10n.websites_remark),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.websites_autoRenew),
              value: autoRenew,
              onChanged: (value) => setState(() => autoRenew = value),
            ),
          ],
        ),
      ),
    );
    final note = description.text.trim();
    description.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateSsl(
        SslUpdateReq(
          id: cert.id,
          primaryDomain: cert.primaryDomain,
          otherDomains: cert.otherDomains,
          provider: cert.provider,
          keyType: cert.keyType,
          description: note,
          dir: cert.dir,
          shell: cert.shell,
          nodes: cert.nodes,
          acmeAccountId: cert.acmeAccountId,
          dnsAccountId: cert.dnsAccountId,
          autoRenew: autoRenew,
          pushDir: cert.pushDir,
          execShell: cert.execShell,
          pushNode: cert.pushNode,
          isIp: cert.isIp,
          disableCNAME: cert.disableCNAME,
          skipDNS: cert.skipDNS,
          nameserver1: cert.nameserver1,
          nameserver2: cert.nameserver2,
        ),
      );
      ref.invalidate(_sslListProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SslManageDto cert,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_deleteSsl,
      message: l10n.websites_deleteSslConfirm(cert.primaryDomain),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteSsl([cert.id]);
      ref.invalidate(_sslListProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

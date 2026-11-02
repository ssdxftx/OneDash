import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../../data/dto/website/website_acme_account_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _acmeProvider = FutureProvider.autoDispose<List<WebsiteAcmeAccountDto>>((
  ref,
) async {
  final repository = await ref.watch(websiteRepositoryProvider.future);
  final page = await repository.searchAcmeAccountsPaged({
    'page': 1,
    'pageSize': 100,
  });
  return page.items;
}, name: 'websiteAcmeAccountsProvider');

final _dnsProvider = FutureProvider.autoDispose<List<DnsAccountDto>>((
  ref,
) async {
  final repository = await ref.watch(websiteRepositoryProvider.future);
  final page = await repository.searchDnsAccounts({'page': 1, 'pageSize': 100});
  return page.items;
}, name: 'websiteDnsAccountsProvider');

final _caProvider = FutureProvider.autoDispose<List<CaDto>>((ref) async {
  final repository = await ref.watch(websiteRepositoryProvider.future);
  final page = await repository.searchCaAccounts({'page': 1, 'pageSize': 100});
  return page.items;
}, name: 'websiteCaAccountsProvider');

class WebsiteAccountsPage extends ConsumerWidget {
  const WebsiteAccountsPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.websites_certificateAccounts,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () {
              ref.invalidate(_acmeProvider);
              ref.invalidate(_dnsProvider);
              ref.invalidate(_caProvider);
            },
          ),
        ],
      ),
      body: const SegmentedTabsView(
        labels: ['ACME', 'DNS', 'CA'],
        children: [_AcmeTab(), _DnsTab(), _CaTab()],
      ),
    );
  }
}

class _AcmeTab extends ConsumerWidget {
  const _AcmeTab();

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final email = TextEditingController();
    final url = TextEditingController();
    String type = 'letsencrypt';
    bool useEab = false;
    bool useProxy = false;
    final saved = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.websites_addAcme, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            AppTextField(controller: email, label: l10n.websites_email),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: InputDecoration(labelText: l10n.websites_acmeType),
              items: const [
                DropdownMenuItem(
                  value: 'letsencrypt',
                  child: Text('Let\'s Encrypt'),
                ),
                DropdownMenuItem(value: 'zerossl', child: Text('ZeroSSL')),
                DropdownMenuItem(value: 'custom', child: Text('Custom')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => type = value);
              },
            ),
            if (type == 'custom') ...[
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: url, label: l10n.websites_caDirUrl),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.websites_useProxy),
              value: useProxy,
              onChanged: (value) => setState(() => useProxy = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.websites_useEab),
              value: useEab,
              onChanged: (value) => setState(() => useEab = value),
            ),
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: l10n.action_create,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    final mail = email.text.trim();
    final caUrl = url.text.trim();
    email.dispose();
    url.dispose();
    if (saved != true || !context.mounted || mail.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.createAcmeAccount(
        AcmeAccountCreateReq(
          email: mail,
          type: type,
          keyType: 'P256',
          caDirURL: type == 'custom' ? caUrl : '',
          eabKid: '',
          eabHmacKey: '',
          useProxy: useProxy,
          useEAB: useEab,
        ),
      );
      ref.invalidate(_acmeProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    WebsiteAcmeAccountDto account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final email = TextEditingController(text: account.email);
    final url = TextEditingController(text: account.url);
    String type = account.type.isEmpty ? 'letsencrypt' : account.type;
    bool useProxy = account.useProxy;
    final saved = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.action_edit, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            AppTextField(controller: email, label: l10n.websites_email),
            const SizedBox(height: AppTokens.s12),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: InputDecoration(labelText: l10n.websites_acmeType),
              items: const [
                DropdownMenuItem(
                  value: 'letsencrypt',
                  child: Text('Let\'s Encrypt'),
                ),
                DropdownMenuItem(value: 'zerossl', child: Text('ZeroSSL')),
                DropdownMenuItem(value: 'custom', child: Text('Custom')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => type = value);
              },
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: url, label: l10n.websites_caDirUrl),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.websites_useProxy),
              value: useProxy,
              onChanged: (value) => setState(() => useProxy = value),
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
    final mail = email.text.trim();
    final caUrl = url.text.trim();
    email.dispose();
    url.dispose();
    if (saved != true || !context.mounted || mail.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateAcmeAccount({
        'id': account.id,
        'email': mail,
        'type': type,
        'keyType': 'P256',
        'caDirURL': type == 'custom' ? caUrl : '',
        'eabKid': '',
        'eabHmacKey': '',
        'useProxy': useProxy,
        'useEAB': false,
      });
      ref.invalidate(_acmeProvider);
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
    WebsiteAcmeAccountDto account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: account.email,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteAcmeAccount(account.id);
      ref.invalidate(_acmeProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(_acmeProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: PrimaryButton(
            label: l10n.websites_addAcme,
            icon: TablerIcons.plus,
            onPressed: () => _add(context, ref),
          ),
        ),
        Expanded(
          child: AsyncStateView(
            value: accounts,
            onRetry: () => ref.invalidate(_acmeProvider),
            loading: const SkeletonList(itemCount: 4),
            isEmpty: (items) => items.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.certificate,
              title: l10n.websites_noAcme,
              message: l10n.websites_noAcmeHint,
            ),
            builder: (items) => ListView.separated(
              padding: const EdgeInsets.all(AppTokens.s16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final item = items[index];
                return TonalCard(
                  child: Row(
                    children: [
                      const Icon(TablerIcons.certificate),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.email, style: AppTextStyles.titleS),
                            Text(
                              '${item.type} · ${item.url}',
                              style: AppTextStyles.caption.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.action_edit,
                        icon: const Icon(TablerIcons.edit),
                        onPressed: () => _edit(context, ref, item),
                      ),
                      IconButton(
                        tooltip: l10n.action_delete,
                        icon: Icon(
                          TablerIcons.trash,
                          color: context.appColors.danger,
                        ),
                        onPressed: () => _delete(context, ref, item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DnsTab extends ConsumerWidget {
  const _DnsTab();

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final type = TextEditingController(text: 'alidns');
    final auth = TextEditingController(text: '{\n  "AccessKey": ""\n}');
    final saved = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.websites_addDns, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: name, label: l10n.files_name),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: type, label: l10n.websites_dnsType),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: auth,
            label: l10n.websites_authorization,
            maxLines: 6,
          ),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.action_create,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final dnsName = name.text.trim();
    final dnsType = type.text.trim();
    final authText = auth.text.trim();
    name.dispose();
    type.dispose();
    auth.dispose();
    if (saved != true || !context.mounted || dnsName.isEmpty) return;
    try {
      final parsed = jsonDecode(authText);
      if (parsed is! Map<String, dynamic>) return;
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.createDnsAccount(
        DnsAccountCreateReq(
          name: dnsName,
          type: dnsType,
          authorization: parsed,
        ),
      );
      ref.invalidate(_dnsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    DnsAccountDto account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: account.name);
    final type = TextEditingController(text: account.type);
    final auth = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(account.authorization),
    );
    final saved = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.action_edit, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: name, label: l10n.files_name),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: type, label: l10n.websites_dnsType),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: auth,
            label: l10n.websites_authorization,
            maxLines: 6,
          ),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final dnsName = name.text.trim();
    final dnsType = type.text.trim();
    final authText = auth.text.trim();
    name.dispose();
    type.dispose();
    auth.dispose();
    if (saved != true || !context.mounted || dnsName.isEmpty) return;
    try {
      final parsed = jsonDecode(authText);
      if (parsed is! Map<String, dynamic>) return;
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateDnsAccount({
        'id': account.id,
        'name': dnsName,
        'type': dnsType,
        'authorization': parsed,
      });
      ref.invalidate(_dnsProvider);
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
    DnsAccountDto account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: account.name,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteDnsAccount(account.id);
      ref.invalidate(_dnsProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(_dnsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: PrimaryButton(
            label: l10n.websites_addDns,
            icon: TablerIcons.plus,
            onPressed: () => _add(context, ref),
          ),
        ),
        Expanded(
          child: AsyncStateView(
            value: accounts,
            onRetry: () => ref.invalidate(_dnsProvider),
            loading: const SkeletonList(itemCount: 4),
            isEmpty: (items) => items.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.server,
              title: l10n.websites_noDns,
              message: l10n.websites_noDnsHint,
            ),
            builder: (items) => ListView.separated(
              padding: const EdgeInsets.all(AppTokens.s16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final item = items[index];
                return TonalCard(
                  child: Row(
                    children: [
                      const Icon(TablerIcons.server),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: AppTextStyles.titleS),
                            Text(
                              item.type,
                              style: AppTextStyles.caption.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.action_edit,
                        icon: const Icon(TablerIcons.edit),
                        onPressed: () => _edit(context, ref, item),
                      ),
                      IconButton(
                        tooltip: l10n.action_delete,
                        icon: Icon(
                          TablerIcons.trash,
                          color: context.appColors.danger,
                        ),
                        onPressed: () => _delete(context, ref, item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CaTab extends ConsumerWidget {
  const _CaTab();

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final cn = TextEditingController();
    final country = TextEditingController(text: 'CN');
    final org = TextEditingController();
    final saved = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.websites_addCa, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: name, label: l10n.files_name),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: cn, label: l10n.websites_commonName),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: country, label: l10n.websites_country),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: org, label: l10n.websites_organization),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.action_create,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final caName = name.text.trim();
    final commonName = cn.text.trim();
    final countryValue = country.text.trim();
    final organization = org.text.trim();
    name.dispose();
    cn.dispose();
    country.dispose();
    org.dispose();
    if (saved != true || !context.mounted || caName.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.createCa(
        CaCreateReq(
          name: caName,
          commonName: commonName,
          country: countryValue,
          organization: organization,
          organizationUnit: '',
          province: '',
          city: '',
          keyType: 'P256',
        ),
      );
      ref.invalidate(_caProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _obtain(BuildContext context, WidgetRef ref, CaDto ca) async {
    final l10n = AppLocalizations.of(context);
    final domains = TextEditingController();
    final description = TextEditingController();
    final saved = await showAppSheet<bool>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.websites_obtainCa, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: domains,
            label: l10n.websites_domains,
            hint: 'example.com',
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: description, label: l10n.websites_remark),
          const SizedBox(height: AppTokens.s16),
          PrimaryButton(
            label: l10n.websites_obtainCa,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
        ],
      ),
    );
    final domainValue = domains.text.trim();
    final note = description.text.trim();
    domains.dispose();
    description.dispose();
    if (saved != true || !context.mounted || domainValue.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.obtainCa(
        CaObtainReq(
          id: ca.id,
          domains: domainValue,
          keyType: ca.keyType,
          time: 1,
          unit: 'year',
          description: note,
          dir: '',
          shell: '',
          autoRenew: false,
          pushDir: false,
          execShell: false,
        ),
      );
      ref.invalidate(_caProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _renew(BuildContext context, WidgetRef ref, CaDto ca) async {
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final sslId = int.tryParse(ca.sslId) ?? 0;
      if (sslId == 0) return;
      await repository.renewCa(sslId);
      ref.invalidate(_caProvider);
      if (!context.mounted) return;
      AppToast.success(context, AppLocalizations.of(context).action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _downloadCa(
    BuildContext context,
    WidgetRef ref,
    CaDto item,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final response = await repository.downloadCa(item.id);
      final raw = response.data;
      final bytes = raw is List<int> ? Uint8List.fromList(raw) : null;
      if (bytes == null) return;
      final path = await FilePicker.saveFile(
        fileName: '${item.name.isEmpty ? 'ca-${item.id}' : item.name}.zip',
        bytes: bytes,
      );
      if (path == null || !context.mounted) return;
      AppToast.success(context, l10n.websites_downloaded(path));
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, CaDto ca) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: ca.name,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteCa(ca.id);
      ref.invalidate(_caProvider);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(_caProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: PrimaryButton(
            label: l10n.websites_addCa,
            icon: TablerIcons.plus,
            onPressed: () => _add(context, ref),
          ),
        ),
        Expanded(
          child: AsyncStateView(
            value: accounts,
            onRetry: () => ref.invalidate(_caProvider),
            loading: const SkeletonList(itemCount: 4),
            isEmpty: (items) => items.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.shield,
              title: l10n.websites_noCa,
              message: l10n.websites_noCaHint,
            ),
            builder: (items) => ListView.separated(
              padding: const EdgeInsets.all(AppTokens.s16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final item = items[index];
                return TonalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(TablerIcons.shield),
                          const SizedBox(width: AppTokens.s12),
                          Expanded(
                            child: Text(item.name, style: AppTextStyles.titleS),
                          ),
                        ],
                      ),
                      Text(
                        '${item.commonName} · ${item.keyType}',
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _downloadCa(context, ref, item),
                            child: Text(l10n.websites_downloadCa),
                          ),
                          TextButton(
                            onPressed: () => _obtain(context, ref, item),
                            child: Text(l10n.websites_obtainCa),
                          ),
                          TextButton(
                            onPressed: () => _renew(context, ref, item),
                            child: Text(l10n.websites_renewCa),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: context.appColors.danger,
                            ),
                            onPressed: () => _delete(context, ref, item),
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
        ),
      ],
    );
  }
}

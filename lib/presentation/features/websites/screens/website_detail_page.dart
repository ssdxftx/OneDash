import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../../../data/dto/website/website_proxy_dto.dart';
import '../../../../data/dto/website/website_domain_req.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../widgets/website_load_balance_tab.dart';
import '../widgets/website_ssl_sheet.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_mapper.dart';
import '../../../common/states/error_state.dart';
import '../providers/websites_provider.dart';
import '../../../common/states/error_toast.dart';
import 'websites_page.dart';

class WebsiteDetailPage extends ConsumerWidget {
  const WebsiteDetailPage({
    super.key,
    required this.serverId,
    required this.siteId,
  });

  final int serverId;
  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = int.tryParse(siteId) ?? 0;
    final detail = ref.watch(websiteDetailProvider(id));
    final site = detail.valueOrNull?.website;

    return Scaffold(
      appBar: AppBarLarge(
        title: site?.primaryDomain ?? l10n.websites_title,
        subtitle: site?.type,
        actions: [
          if (site != null)
            PopupMenuButton<String>(
              tooltip: l10n.action_more,
              onSelected: (value) {
                if (value == 'toggle') {
                  _operate(
                    context,
                    ref,
                    site,
                    site.status.toLowerCase() == 'running' ? 'stop' : 'start',
                  );
                }
                if (value == 'open') _open(context, site);
                if (value == 'delete') _delete(context, ref, site);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    site.status.toLowerCase() == 'running'
                        ? l10n.websites_stop
                        : l10n.websites_start,
                  ),
                ),
                PopupMenuItem(value: 'open', child: Text(l10n.websites_open)),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.websites_delete),
                ),
              ],
            ),
        ],
      ),
      body: detail.when(
        loading: () => const SkeletonList(itemCount: 6),
        error: (error, stack) => ErrorState(
          data: mapError(error, l10n),
          onRetry: () => ref.invalidate(websiteDetailProvider(id)),
        ),
        data: (data) => SegmentedTabsView(
          labels: [
            l10n.websites_basicConfig,
            l10n.websites_domains,
            l10n.websites_sslCertificate,
            l10n.websites_proxySettings,
            l10n.websites_loadBalance,
            l10n.websites_logs,
          ],
          children: [
            _ConfigTab(detail: data),
            _DomainsTab(detail: data),
            _SslTab(detail: data),
            _ProxyTab(detail: data),
            WebsiteLoadBalanceTab(websiteId: data.website.id),
            _LogsTab(serverId: serverId, detail: data),
          ],
        ),
      ),
    );
  }

  Future<void> _operate(
    BuildContext context,
    WidgetRef ref,
    WebsiteDto site,
    String operate,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.operateWebsite(site.id, operate);
      if (!context.mounted) return;
      AppToast.success(
        context,
        operate == 'start' ? l10n.websites_started : l10n.websites_stopped,
      );
      ref.invalidate(websiteDetailProvider(site.id));
      ref.invalidate(websitesProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WebsiteDto site,
  ) async {
    final l10n = AppLocalizations.of(context);
    final options = await showAppSheet<WebsiteDeleteOptions>(
      context: context,
      builder: (sheetContext) => WebsiteDeleteSheet(site: site),
    );
    if (options == null || !context.mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_deleteTitle(site.primaryDomain),
      message: l10n.websites_deleteMessage,
      confirmLabel: l10n.action_delete,
      requireText: site.primaryDomain,
      danger: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteWebsite(
        site.id,
        deleteBackup: options.deleteBackup,
        forceDelete: options.forceDelete,
        deleteDB: options.deleteDB,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.websites_deleted);
      ref.invalidate(websitesProvider);
      context.pop();
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _open(BuildContext context, WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final protocol = site.protocol.toLowerCase() == 'https' ? 'https' : 'http';
    final uri = Uri.tryParse('$protocol://${site.primaryDomain}');
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      showErrorToast(context, StateError(l10n.websites_openFailed));
    }
  }
}

class _ConfigTab extends ConsumerWidget {
  const _ConfigTab({required this.detail});

  final WebsiteDetailDto detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final site = detail.website;
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        TonalCard(
          child: Row(
            children: [
              StatusDot(status: site.status.toLowerCase()),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(site.primaryDomain, style: AppTextStyles.titleM),
              ),
              Text(site.type, style: AppTextStyles.bodyS),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        OutlinedButton.icon(
          onPressed: () => _editSiteDir(context, ref, site),
          icon: const Icon(TablerIcons.folder),
          label: Text(l10n.websites_siteDirectory),
        ),
        const SizedBox(height: AppTokens.s8),
        OutlinedButton.icon(
          onPressed: () => _editConfig(context, ref, site),
          icon: const Icon(TablerIcons.file_code),
          label: Text(l10n.websites_configFile),
        ),
        const SizedBox(height: AppTokens.s24),
        SplitListGroup(
          children: [
            _Row(label: l10n.websites_websiteAlias, value: detail.alias),
            _Row(label: l10n.websites_rootDirectory, value: site.siteDir),
            _Row(label: l10n.websites_path, value: site.sitePath),
            _Row(label: l10n.websites_runtime, value: site.runtimeName),
            _Row(label: l10n.websites_remark, value: site.remark),
            _Row(label: l10n.websites_createdAt, value: site.createdAt),
          ],
        ),
      ],
    );
  }

  Future<void> _editConfig(
    BuildContext context,
    WidgetRef ref,
    WebsiteDto site,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final config = await repository.getWebsiteConfig(site.id);
      if (!context.mounted) return;
      final controller = TextEditingController(text: config.content);
      final confirmed = await showAppSheet<bool>(
        context: context,
        maxHeightFactor: 0.95,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.websites_configFile, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s4),
            Text(
              config.path,
              style: AppTextStyles.caption.copyWith(
                color: context.scheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            TextField(
              controller: controller,
              maxLines: 14,
              style: AppTextStyles.bodyS.copyWith(fontFamily: 'monospace'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppTokens.s16),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: l10n.action_cancel,
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: PrimaryButton(
                    label: l10n.action_save,
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await repository.updateWebsiteConfig(site.id, controller.text);
        if (!context.mounted) return;
        AppToast.success(context, l10n.action_save);
        ref.invalidate(websiteDetailProvider(site.id));
      }
      controller.dispose();
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editSiteDir(
    BuildContext context,
    WidgetRef ref,
    WebsiteDto site,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: site.siteDir);
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.websites_siteDirectory, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: controller, autofocus: true),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () =>
                Navigator.of(sheetContext).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsiteSiteDir(site.id, value);
      if (!context.mounted) return;
      AppToast.success(context, l10n.common_saved);
      ref.invalidate(websiteDetailProvider(site.id));
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _DomainsTab extends ConsumerWidget {
  const _DomainsTab({required this.detail});

  final WebsiteDetailDto detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        if (detail.domains.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.s32),
            child: Center(child: Text(l10n.websites_noDomains)),
          )
        else
          SplitListGroup(
            children: [
              for (final domain in detail.domains)
                SplitListTile(
                  leading: Icon(
                    domain.ssl ? TablerIcons.lock : TablerIcons.world,
                  ),
                  title: domain.domain,
                  subtitle: domain.port == 0 ? null : '${domain.port}',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (domain.ssl)
                        Text(
                          'SSL',
                          style: AppTextStyles.caption.copyWith(
                            color: context.scheme.primary,
                          ),
                        ),
                      IconButton(
                        tooltip: l10n.websites_removeDomain,
                        onPressed: () => _deleteDomain(context, ref, domain.id),
                        icon: const Icon(
                          TablerIcons.trash,
                          size: AppTokens.iconList,
                        ),
                      ),
                    ],
                  ),
                  onLongPress: () => _deleteDomain(context, ref, domain.id),
                ),
            ],
          ),
        const SizedBox(height: AppTokens.s16),
        OutlinedButton.icon(
          onPressed: () => _addDomain(context, ref),
          icon: const Icon(TablerIcons.plus),
          label: Text(l10n.websites_addDomain),
        ),
      ],
    );
  }

  Future<void> _addDomain(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final value = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.websites_addDomain, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            hint: 'example.com',
            autofocus: true,
          ),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.websites_addDomainAction,
            onPressed: () =>
                Navigator.of(sheetContext).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.addDomains(detail.website.id, [
        WebsiteDomainReq(domain: value),
      ]);
      if (!context.mounted) return;
      AppToast.success(context, l10n.websites_domainAdded);
      ref.invalidate(websiteDetailProvider(detail.website.id));
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _deleteDomain(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_removeDomain,
      message: l10n.websites_removeDomainMessage,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteDomain(id);
      if (!context.mounted) return;
      AppToast.success(context, l10n.websites_domainDeleted);
      ref.invalidate(websiteDetailProvider(detail.website.id));
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _SslTab extends StatelessWidget {
  const _SslTab({required this.detail});

  final WebsiteDetailDto detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ssl = detail.ssl;
    if (ssl == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.shield_off,
              size: 32,
              color: context.scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppTokens.s12),
            Text(l10n.websites_noSslCertificate),
            const SizedBox(height: AppTokens.s16),
            OutlinedButton.icon(
              onPressed: () => showAppSheet<bool>(
                context: context,
                builder: (_) => WebsiteSslSheet(
                  websiteId: detail.website.id,
                  domain: detail.website.primaryDomain,
                ),
              ),
              icon: const Icon(TablerIcons.shield_check),
              label: Text(l10n.websites_bindExistingCertificate),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        TonalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ssl.displayName, style: AppTextStyles.titleM),
              const SizedBox(height: AppTokens.s8),
              Row(
                children: [
                  StatusDot(status: ssl.status.toLowerCase()),
                  const SizedBox(width: AppTokens.s8),
                  Text(ssl.status, style: AppTextStyles.bodyS),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        SplitListGroup(
          children: [
            _Row(label: l10n.websites_sslProvider, value: ssl.provider),
            _Row(label: l10n.websites_type, value: ssl.type),
            _Row(label: l10n.websites_sslExpire, value: ssl.expireDate),
            _Row(label: l10n.websites_domain, value: ssl.primaryDomain),
          ],
        ),
        const SizedBox(height: AppTokens.s24),
        OutlinedButton.icon(
          onPressed: () => showAppSheet<bool>(
            context: context,
            builder: (_) => WebsiteSslSheet(
              websiteId: detail.website.id,
              domain: detail.website.primaryDomain,
            ),
          ),
          icon: const Icon(TablerIcons.shield_check),
          label: Text(l10n.websites_changeCertificate),
        ),
      ],
    );
  }
}

class _ProxyTab extends ConsumerWidget {
  const _ProxyTab({required this.detail});

  final WebsiteDetailDto detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final proxies = ref.watch(websiteProxiesProvider(detail.website.id));
    return AsyncStateView(
      value: proxies,
      onRetry: () => ref.invalidate(websiteProxiesProvider(detail.website.id)),
      loading: const SkeletonList(itemCount: 5),
      isEmpty: (items) => items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.arrows_exchange,
        title: l10n.websites_noReverseProxy,
        message: l10n.websites_noReverseProxyHint,
      ),
      builder: (items) => ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          for (final proxy in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s12),
              child: TonalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusDot(status: proxy.enable ? 'running' : 'stopped'),
                        const SizedBox(width: AppTokens.s8),
                        Expanded(
                          child: Text(
                            proxy.name,
                            style: AppTextStyles.titleS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Switch(
                          value: proxy.enable,
                          onChanged: (value) =>
                              _toggle(context, ref, proxy, value),
                        ),
                      ],
                    ),
                    Text(
                      '${proxy.match} -> ${proxy.proxyPass}',
                      style: AppTextStyles.caption.copyWith(
                        color: context.scheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.s8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _delete(context, ref, proxy),
                        icon: const Icon(TablerIcons.trash, size: 16),
                        label: Text(l10n.action_delete),
                        style: TextButton.styleFrom(
                          foregroundColor: context.appColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    WebsiteProxyDto proxy,
    bool value,
  ) async {
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsiteProxyStatus(
        detail.website.id,
        proxy.name,
        value ? 'enable' : 'disable',
      );
      ref.invalidate(websiteProxiesProvider(detail.website.id));
    } catch (error) {
      ref.invalidate(websiteProxiesProvider(detail.website.id));
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WebsiteProxyDto proxy,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_deleteReverseProxy,
      message: l10n.websites_deleteProxyMessage(proxy.name, proxy.match),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteWebsiteProxy(detail.website.id, proxy.name);
      ref.invalidate(websiteProxiesProvider(detail.website.id));
      if (!context.mounted) return;
      AppToast.success(context, l10n.websites_domainDeleted);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _LogsTab extends ConsumerWidget {
  const _LogsTab({required this.serverId, required this.detail});

  final int serverId;
  final WebsiteDetailDto detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        SplitListGroup(
          children: [
            SplitListTile(
              leading: const Icon(TablerIcons.file_text),
              title: l10n.websites_accessLog,
              subtitle: detail.accessLogPath,
              trailing: const Icon(TablerIcons.chevron_right),
              onTap: () => context.push(
                '/s/$serverId/files?path=${Uri.encodeComponent(detail.accessLogPath)}',
              ),
            ),
            SplitListTile(
              leading: const Icon(TablerIcons.file_alert),
              title: l10n.websites_errorLog,
              subtitle: detail.errorLogPath,
              trailing: const Icon(TablerIcons.chevron_right),
              onTap: () => context.push(
                '/s/$serverId/files?path=${Uri.encodeComponent(detail.errorLogPath)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        Text(
          l10n.websites_logsFileHint,
          style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyM,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

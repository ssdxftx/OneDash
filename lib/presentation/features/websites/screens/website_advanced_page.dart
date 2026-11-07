import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/website_auth_dto.dart';
import '../../../../data/dto/website/website_auth_req.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../../../data/dto/website/website_cors_dto.dart';
import '../../../../data/dto/website/website_leech_dto.dart';
import '../../../../data/dto/website/website_redirect_dto.dart';
import '../../../../data/dto/website/website_real_ip_dto.dart';
import '../../../../data/dto/website/website_update_req.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../providers/websites_provider.dart';

final _authProvider = FutureProvider.autoDispose.family<WebsiteAuthDto, int>((
  ref,
  id,
) {
  return ref
      .watch(websiteRepositoryProvider.future)
      .then((repository) => repository.getWebsiteAuth(id));
}, name: 'websiteAuthProvider');

final _corsProvider = FutureProvider.autoDispose.family<WebsiteCorsDto, int>((
  ref,
  id,
) {
  return ref
      .watch(websiteRepositoryProvider.future)
      .then((repository) => repository.getWebsiteCors(id));
}, name: 'websiteCorsProvider');

final _leechProvider = FutureProvider.autoDispose.family<WebsiteLeechDto, int>((
  ref,
  id,
) {
  return ref
      .watch(websiteRepositoryProvider.future)
      .then((repository) => repository.getWebsiteLeech(id));
}, name: 'websiteLeechProvider');

final _realIpProvider = FutureProvider.autoDispose
    .family<WebsiteRealIpDto, int>((ref, id) {
      return ref
          .watch(websiteRepositoryProvider.future)
          .then((repository) => repository.getWebsiteRealIp(id));
    }, name: 'websiteRealIpProvider');

final _pathAuthProvider = FutureProvider.autoDispose
    .family<List<WebsitePathAuthItemDto>, int>((ref, id) {
      return ref
          .watch(websiteRepositoryProvider.future)
          .then((repository) => repository.listWebsitePathAuths(id));
    }, name: 'websitePathAuthProvider');

final _redirectProvider = FutureProvider.autoDispose
    .family<List<WebsiteRedirectDto>, int>((ref, id) {
      return ref
          .watch(websiteRepositoryProvider.future)
          .then((repository) => repository.getWebsiteRedirects(id));
    }, name: 'websiteRedirectProvider');

class WebsiteAdvancedPage extends ConsumerStatefulWidget {
  const WebsiteAdvancedPage({
    super.key,
    required this.serverId,
    required this.websiteId,
    this.embedded = false,
  });

  final int serverId;
  final int websiteId;
  final bool embedded;

  @override
  ConsumerState<WebsiteAdvancedPage> createState() =>
      _WebsiteAdvancedPageState();
}

class _WebsiteAdvancedPageState extends ConsumerState<WebsiteAdvancedPage> {
  static const _groups = ['basic', 'security', 'rewrite', 'redirect'];
  String? _group;
  final Set<String> _visited = {'basic'};

  void _open(String group) {
    setState(() {
      _group = group;
      _visited.add(group);
    });
  }

  void _refresh() {
    ref.invalidate(websiteDetailProvider(widget.websiteId));
    ref.invalidate(_authProvider(widget.websiteId));
    ref.invalidate(_corsProvider(widget.websiteId));
    ref.invalidate(_leechProvider(widget.websiteId));
    ref.invalidate(_realIpProvider(widget.websiteId));
    ref.invalidate(_redirectProvider(widget.websiteId));
    ref.invalidate(_pathAuthProvider(widget.websiteId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = PopScope(
      canPop: _group == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_group != null) setState(() => _group = null);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(
            title: _group == null
                ? l10n.websites_advanced
                : _groupLabel(_group!, l10n),
            onClose: () => Navigator.of(context).pop(),
            leading: _group == null
                ? null
                : IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => setState(() => _group = null),
                    icon: const Icon(TablerIcons.arrow_left),
                  ),
            actions: [
              IconButton(
                tooltip: l10n.action_refresh,
                onPressed: _refresh,
                icon: const Icon(TablerIcons.refresh),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _group == null ? 0 : _groups.indexOf(_group!) + 1,
              children: [
                _entryList(l10n),
                for (final group in _groups)
                  _visited.contains(group)
                      ? _groupBody(group)
                      : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
    if (widget.embedded) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.86,
        child: content,
      );
    }
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.websites_advanced,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _refresh,
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _entryList(AppLocalizations l10n) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        AppTokens.s8,
        context.pagePadding,
        AppTokens.s24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _SectionButton(
          icon: TablerIcons.settings,
          title: l10n.websites_basicConfig,
          subtitle: l10n.websites_basicConfigHint,
          onTap: () => _open('basic'),
        ),
        const SizedBox(height: AppTokens.s8),
        _SectionButton(
          icon: TablerIcons.shield_lock,
          title: l10n.websites_security,
          subtitle: l10n.websites_securityHint,
          onTap: () => _open('security'),
        ),
        const SizedBox(height: AppTokens.s8),
        _SectionButton(
          icon: TablerIcons.file_code,
          title: l10n.websites_rewrite,
          subtitle: l10n.websites_rewriteHint,
          onTap: () => _open('rewrite'),
        ),
        const SizedBox(height: AppTokens.s8),
        _SectionButton(
          icon: TablerIcons.arrow_forward_up,
          title: l10n.websites_redirect,
          subtitle: l10n.websites_redirectHint,
          onTap: () => _open('redirect'),
        ),
      ],
    );
  }

  Widget _groupBody(String group) {
    return switch (group) {
      'basic' => _BasicTab(websiteId: widget.websiteId),
      'security' => _SecurityTab(websiteId: widget.websiteId),
      'rewrite' => _RewriteTab(websiteId: widget.websiteId),
      'redirect' => _RedirectTab(websiteId: widget.websiteId),
      _ => const SizedBox.shrink(),
    };
  }

  String _groupLabel(String group, AppLocalizations l10n) {
    return switch (group) {
      'basic' => l10n.websites_basicConfig,
      'security' => l10n.websites_security,
      'rewrite' => l10n.websites_rewrite,
      'redirect' => l10n.websites_redirect,
      _ => group,
    };
  }
}

Future<void> showWebsiteAdvancedSheet(
  BuildContext context, {
  required int serverId,
  required int websiteId,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (_) => WebsiteAdvancedPage(
      serverId: serverId,
      websiteId: websiteId,
      embedded: true,
    ),
  );
}

class _BasicTab extends ConsumerWidget {
  const _BasicTab({required this.websiteId});

  final int websiteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(websiteDetailProvider(websiteId));
    return AsyncStateView(
      value: detail,
      onRetry: () => ref.invalidate(websiteDetailProvider(websiteId)),
      loading: const SkeletonList(itemCount: 6),
      builder: (data) {
        final site = data.website;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            context.pagePadding,
            context.pagePadding,
            context.pagePadding + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            TonalCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(site.primaryDomain, style: AppTextStyles.titleM),
                        const SizedBox(height: 2),
                        Text(
                          site.remark.isEmpty ? site.type : site.remark,
                          style: AppTextStyles.bodyS.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.action_edit,
                    icon: const Icon(TablerIcons.edit),
                    onPressed: () => _editInfo(context, ref, data),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s24),
            _SectionButton(
              icon: TablerIcons.list,
              title: l10n.websites_indexConfig,
              subtitle: l10n.websites_indexConfigHint,
              onTap: () => _editIndex(context, ref),
            ),
            const SizedBox(height: AppTokens.s8),
            _SectionButton(
              icon: TablerIcons.gauge,
              title: l10n.websites_limitConfig,
              subtitle: l10n.websites_limitConfigHint,
              onTap: () => _editLimit(context, ref),
            ),
            const SizedBox(height: AppTokens.s8),
            _SectionButton(
              icon: TablerIcons.users,
              title: l10n.websites_dirPermission,
              subtitle: l10n.websites_dirPermissionHint,
              onTap: () => _editPermission(context, ref),
            ),
            const SizedBox(height: AppTokens.s8),
            _SectionButton(
              icon: TablerIcons.note,
              title: l10n.websites_descriptionPin,
              subtitle: l10n.websites_descriptionPinHint,
              onTap: () => _editDescription(context, ref, site, data.favorite),
            ),
            const SizedBox(height: AppTokens.s8),
            _SectionButton(
              icon: TablerIcons.brand_php,
              title: l10n.websites_switchPhp,
              subtitle: l10n.websites_switchPhpHint,
              onTap: () => _switchPhp(context, ref),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editDescription(
    BuildContext context,
    WidgetRef ref,
    WebsiteDto site,
    bool favorite,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool pinned = favorite;
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: l10n.websites_descriptionPin,
            onSave: () async => Navigator.of(context).pop(true),
            children: [
              AppTextField(
                controller: controller,
                label: l10n.websites_description,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_pin),
                value: pinned,
                onChanged: (value) => setState(() => pinned = value),
              ),
            ],
          ),
        ),
      ),
    );
    final description = controller.text.trim();
    controller.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(settingRepositoryProvider.future);
      await repository.saveDescription(
        id: '${site.id}',
        type: 'website',
        isPinned: pinned,
        description: description,
      );
      ref.invalidate(websiteDetailProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _switchPhp(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final runtimeRepository = await ref.read(
        runtimeRepositoryProvider.future,
      );
      final page = await runtimeRepository.searchRuntimes(const {
        'page': 1,
        'pageSize': 100,
      });
      final phpRuntimes = page.items
          .where((item) => item.type.toLowerCase().contains('php'))
          .toList();
      if (!context.mounted) return;
      final selected = await showAppSheet<int>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.websites_switchPhp, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            SplitListGroup(
              children: [
                SplitListTile(
                  leading: const Icon(TablerIcons.file),
                  title: l10n.websites_staticSite,
                  onTap: () => Navigator.of(sheetContext).pop(0),
                ),
                for (final runtime in phpRuntimes)
                  SplitListTile(
                    leading: const Icon(TablerIcons.brand_php),
                    title: runtime.name,
                    subtitle: runtime.version,
                    onTap: () => Navigator.of(sheetContext).pop(runtime.id),
                  ),
              ],
            ),
          ],
        ),
      );
      if (selected == null || !context.mounted) return;
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.switchPhpVersion(websiteId, selected);
      ref.invalidate(websiteDetailProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editInfo(
    BuildContext context,
    WidgetRef ref,
    WebsiteDetailDto detail,
  ) async {
    final l10n = AppLocalizations.of(context);
    final site = detail.website;
    final remark = TextEditingController(text: site.remark);
    final alias = TextEditingController(text: detail.alias);
    bool favorite = detail.favorite;
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: l10n.websites_editInfo,
            onSave: () async => Navigator.of(context).pop(true),
            children: [
              AppTextField(controller: remark, label: l10n.websites_remark),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: alias,
                label: l10n.websites_websiteAlias,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_favorite),
                value: favorite,
                onChanged: (value) => setState(() => favorite = value),
              ),
            ],
          ),
        ),
      ),
    );
    final update = WebsiteUpdateReq(
      id: websiteId,
      primaryDomain: site.primaryDomain,
      remark: remark.text.trim(),
      webSiteGroupId: 0,
      ipv6: false,
      alias: alias.text.trim(),
      favorite: favorite,
    );
    remark.dispose();
    alias.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsite(update);
      ref.invalidate(websiteDetailProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editIndex(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final config = await repository.getWebsiteIndexConfig(websiteId);
      if (!context.mounted) return;
      final controller = TextEditingController(
        text: config.indexFiles.join('\n'),
      );
      bool enable = config.enable;
      final saved = await showAppSheet<bool>(
        context: context,
        maxHeightFactor: 0.74,
        builder: (sheetContext) => SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.74,
          child: StatefulBuilder(
            builder: (pageContext, setState) => FormSheet(
              title: l10n.websites_indexConfig,
              onSave: () async => Navigator.of(context).pop(true),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.websites_enabled),
                  value: enable,
                  onChanged: (value) => setState(() => enable = value),
                ),
                AppTextField(
                  controller: controller,
                  label: l10n.websites_indexFiles,
                  hint: 'index.html\nindex.php',
                  maxLines: 6,
                ),
              ],
            ),
          ),
        ),
      );
      final files = controller.text
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      controller.dispose();
      if (saved != true || !context.mounted) return;
      await repository.updateWebsiteIndexConfig(websiteId, enable ? files : []);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editLimit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final config = await repository.getWebsiteLimitConfig(websiteId);
      if (!context.mounted) return;
      final server = TextEditingController(
        text: '${config.perServerLimit ?? 0}',
      );
      final ip = TextEditingController(text: '${config.perIpLimit ?? 0}');
      final rate = TextEditingController(text: '${config.rateKb ?? 0}');
      bool enable = config.enable;
      final saved = await showAppSheet<bool>(
        context: context,
        maxHeightFactor: 0.74,
        builder: (sheetContext) => SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.74,
          child: StatefulBuilder(
            builder: (pageContext, setState) => FormSheet(
              title: l10n.websites_limitConfig,
              onSave: () async => Navigator.of(context).pop(true),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.websites_enabled),
                  value: enable,
                  onChanged: (value) => setState(() => enable = value),
                ),
                AppTextField(
                  controller: server,
                  label: l10n.websites_perServer,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: ip,
                  label: l10n.websites_perIp,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: rate,
                  label: l10n.websites_rateKb,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      );
      final values = (
        int.tryParse(server.text) ?? 0,
        int.tryParse(ip.text) ?? 0,
        int.tryParse(rate.text) ?? 0,
      );
      server.dispose();
      ip.dispose();
      rate.dispose();
      if (saved != true || !context.mounted) return;
      await repository.updateWebsiteLimitConfig(
        websiteId,
        enable: enable,
        perServerLimit: values.$1,
        perIpLimit: values.$2,
        rateKb: values.$3,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editPermission(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final dir = await repository.getWebsiteDir(websiteId);
      if (!context.mounted) return;
      final user = TextEditingController(text: dir.user);
      final group = TextEditingController(text: dir.userGroup);
      final saved = await showAppSheet<bool>(
        context: context,
        maxHeightFactor: 0.74,
        builder: (sheetContext) => SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.74,
          child: StatefulBuilder(
            builder: (pageContext, setState) => FormSheet(
              title: l10n.websites_dirPermission,
              onSave: () async => Navigator.of(context).pop(true),
              children: [
                Text(
                  dir.dirs.join('\n'),
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTokens.s16),
                AppTextField(controller: user, label: l10n.websites_owner),
                const SizedBox(height: AppTokens.s12),
                AppTextField(controller: group, label: l10n.websites_group),
              ],
            ),
          ),
        ),
      );
      final owner = user.text.trim();
      final groupName = group.text.trim();
      user.dispose();
      group.dispose();
      if (saved != true || !context.mounted) return;
      await repository.updateWebsiteDirPermission(
        websiteId,
        user: owner,
        group: groupName,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: context.scheme.primary),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleS),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(TablerIcons.chevron_right),
        ],
      ),
    );
  }
}

class _SecurityTab extends ConsumerWidget {
  const _SecurityTab({required this.websiteId});

  final int websiteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(_authProvider(websiteId));
    final cors = ref.watch(_corsProvider(websiteId));
    final leech = ref.watch(_leechProvider(websiteId));
    final realIp = ref.watch(_realIpProvider(websiteId));
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        context.pagePadding,
        context.pagePadding,
        context.pagePadding + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _StatusCard(
          title: l10n.websites_accessAuth,
          subtitle: auth.valueOrNull == null
              ? l10n.action_loading
              : auth.value!.enable
              ? l10n.websites_enabled
              : l10n.websites_disabled,
          icon: TablerIcons.lock,
          onTap: () => _editAuth(context, ref, auth.valueOrNull),
        ),
        const SizedBox(height: AppTokens.s8),
        _StatusCard(
          title: 'CORS',
          subtitle: cors.valueOrNull?.cors == true
              ? l10n.websites_enabled
              : l10n.websites_disabled,
          icon: TablerIcons.world,
          onTap: () => _editCors(context, ref, cors.valueOrNull),
        ),
        const SizedBox(height: AppTokens.s8),
        _StatusCard(
          title: l10n.websites_leech,
          subtitle: leech.valueOrNull?.enable == true
              ? l10n.websites_enabled
              : l10n.websites_disabled,
          icon: TablerIcons.link,
          onTap: () => _editLeech(context, ref, leech.valueOrNull),
        ),
        const SizedBox(height: AppTokens.s8),
        _StatusCard(
          title: l10n.websites_realIp,
          subtitle: realIp.valueOrNull?.open == true
              ? l10n.websites_enabled
              : l10n.websites_disabled,
          icon: TablerIcons.network,
          onTap: () => _editRealIp(context, ref, realIp.valueOrNull),
        ),
        const SizedBox(height: AppTokens.s24),
        Row(
          children: [
            Expanded(
              child: Text(l10n.websites_pathAuth, style: AppTextStyles.titleS),
            ),
            TextButton.icon(
              onPressed: () => _editPathAuth(context, ref),
              icon: const Icon(TablerIcons.plus),
              label: Text(l10n.action_add),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s8),
        ref
            .watch(_pathAuthProvider(websiteId))
            .when(
              data: (items) => items.isEmpty
                  ? Text(
                      l10n.websites_noPathAuth,
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    )
                  : Column(
                      children: [
                        for (final item in items)
                          TonalCard(
                            onTap: () => _editPathAuth(context, ref, item),
                            child: Row(
                              children: [
                                const Icon(TablerIcons.lock),
                                const SizedBox(width: AppTokens.s12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.path,
                                        style: AppTextStyles.titleS,
                                      ),
                                      Text(
                                        '${item.name} · ${item.username}',
                                        style: AppTextStyles.caption.copyWith(
                                          color:
                                              context.scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: l10n.action_delete,
                                  icon: Icon(
                                    TablerIcons.trash,
                                    color: context.appColors.danger,
                                  ),
                                  onPressed: () =>
                                      _deletePathAuth(context, ref, item),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(
                describeError(error, l10n),
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.error,
                ),
              ),
            ),
      ],
    );
  }

  Future<void> _editPathAuth(
    BuildContext context,
    WidgetRef ref, [
    WebsitePathAuthItemDto? current,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final path = TextEditingController(text: current?.path ?? '/');
    final name = TextEditingController(text: current?.name ?? '');
    final username = TextEditingController(text: current?.username ?? '');
    final password = TextEditingController(text: current?.password ?? '');
    final remark = TextEditingController(text: current?.remark ?? '');
    String? formError;
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: current == null
                ? l10n.websites_addPathAuth
                : l10n.websites_editPathAuth,
            onSave: () async {
              if (path.text.trim().isEmpty ||
                  name.text.trim().isEmpty ||
                  username.text.trim().isEmpty ||
                  password.text.isEmpty) {
                setState(() => formError = l10n.websites_requiredFields);
                return;
              }
              Navigator.of(context).pop(true);
            },
            children: [
              AppTextField(controller: path, label: l10n.websites_path),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: name, label: l10n.files_name),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: username, label: l10n.websites_username),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: password,
                label: l10n.websites_password,
                obscure: true,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: remark, label: l10n.websites_remark),
              if (formError != null) ...[
                const SizedBox(height: AppTokens.s8),
                Text(
                  formError!,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.appColors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    final request = WebsitePathAuthUpdateReq(
      websiteId: websiteId,
      path: path.text.trim(),
      name: name.text.trim(),
      username: username.text.trim(),
      password: password.text,
      operate: current == null ? 'create' : 'edit',
      remark: remark.text.trim(),
    );
    path.dispose();
    name.dispose();
    username.dispose();
    password.dispose();
    remark.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsitePathAuth(request);
      ref.invalidate(_pathAuthProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _deletePathAuth(
    BuildContext context,
    WidgetRef ref,
    WebsitePathAuthItemDto item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: l10n.websites_deletePathAuth(item.path),
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsitePathAuth(
        WebsitePathAuthUpdateReq(
          websiteId: websiteId,
          path: item.path,
          name: item.name,
          username: item.username,
          password: item.password,
          operate: 'delete',
          remark: item.remark,
        ),
      );
      ref.invalidate(_pathAuthProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editAuth(
    BuildContext context,
    WidgetRef ref,
    WebsiteAuthDto? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (current == null) return;
    final first = current.items == null || current.items!.isEmpty
        ? null
        : current.items!.first;
    final user = TextEditingController(text: first?.username ?? '');
    final password = TextEditingController(text: first?.password ?? '');
    final remark = TextEditingController(text: first?.remark ?? '');
    bool enable = current.enable;
    String? formError;
    final request = await showAppSheet<WebsiteAuthUpdateReq>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: l10n.websites_accessAuth,
            onSave: () async {
              final usernameValue = user.text.trim();
              if (enable && usernameValue.isEmpty) {
                setState(() => formError = l10n.websites_usernameRequired);
                return;
              }
              Navigator.of(context).pop(
                WebsiteAuthUpdateReq(
                  websiteId: websiteId,
                  operate: enable
                      ? (first == null ? 'create' : 'edit')
                      : 'disable',
                  username: usernameValue,
                  password: password.text,
                  remark: remark.text.trim(),
                ),
              );
            },
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_enabled),
                value: enable,
                onChanged: (value) => setState(() => enable = value),
              ),
              AppTextField(controller: user, label: l10n.websites_username),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: password,
                label: l10n.websites_password,
                obscure: true,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: remark, label: l10n.websites_remark),
              if (formError != null) ...[
                const SizedBox(height: AppTokens.s8),
                Text(
                  formError!,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.appColors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    user.dispose();
    password.dispose();
    remark.dispose();
    if (request == null || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsiteAuth(request);
      ref.invalidate(_authProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editCors(
    BuildContext context,
    WidgetRef ref,
    WebsiteCorsDto? current,
  ) async {
    if (current == null) return;
    final l10n = AppLocalizations.of(context);
    final origins = TextEditingController(text: current.allowOrigins);
    final methods = TextEditingController(text: current.allowMethods);
    final headers = TextEditingController(text: current.allowHeaders);
    bool cors = current.cors;
    bool credentials = current.allowCredentials;
    bool preflight = current.preflight;
    final request = await showAppSheet<WebsiteCorsDto>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: 'CORS',
            onSave: () async => Navigator.of(context).pop(
              WebsiteCorsDto(
                websiteID: websiteId,
                cors: cors,
                allowOrigins: origins.text.trim(),
                allowMethods: methods.text.trim(),
                allowHeaders: headers.text.trim(),
                allowCredentials: credentials,
                preflight: preflight,
              ),
            ),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_enabled),
                value: cors,
                onChanged: (value) => setState(() => cors = value),
              ),
              AppTextField(
                controller: origins,
                label: l10n.websites_allowOrigins,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: methods,
                label: l10n.websites_allowMethods,
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: headers,
                label: l10n.websites_allowHeaders,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_allowCredentials),
                value: credentials,
                onChanged: (value) => setState(() => credentials = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_preflight),
                value: preflight,
                onChanged: (value) => setState(() => preflight = value),
              ),
            ],
          ),
        ),
      ),
    );
    origins.dispose();
    methods.dispose();
    headers.dispose();
    if (request == null || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsiteCors(request);
      ref.invalidate(_corsProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editLeech(
    BuildContext context,
    WidgetRef ref,
    WebsiteLeechDto? current,
  ) async {
    if (current == null) return;
    final l10n = AppLocalizations.of(context);
    final extensions = TextEditingController(text: current.extensions);
    final returnCode = TextEditingController(text: current.returnCode);
    bool enable = current.enable;
    bool blocked = current.blocked;
    bool logEnable = current.logEnable;
    final request = await showAppSheet<WebsiteLeechUpdateReq>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: l10n.websites_leech,
            onSave: () async => Navigator.of(context).pop(
              WebsiteLeechUpdateReq(
                websiteID: websiteId,
                enable: enable,
                cache: current.cache,
                cacheTime: current.cacheTime,
                cacheUint: current.cacheUint,
                extensions: extensions.text.trim(),
                returnCode: returnCode.text.trim(),
                domains: current.serverNames.join(','),
                noneRef: current.noneRef,
                logEnable: logEnable,
                blocked: blocked,
                serverNames: current.serverNames,
              ),
            ),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_enabled),
                value: enable,
                onChanged: (value) => setState(() => enable = value),
              ),
              AppTextField(
                controller: extensions,
                label: l10n.websites_allowedExtensions,
                hint: 'jpg,png,gif',
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: returnCode,
                label: l10n.websites_returnCode,
                hint: '404',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_blocked),
                value: blocked,
                onChanged: (value) => setState(() => blocked = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_logEnabled),
                value: logEnable,
                onChanged: (value) => setState(() => logEnable = value),
              ),
            ],
          ),
        ),
      ),
    );
    extensions.dispose();
    returnCode.dispose();
    if (request == null || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsiteLeech(request);
      ref.invalidate(_leechProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editRealIp(
    BuildContext context,
    WidgetRef ref,
    WebsiteRealIpDto? current,
  ) async {
    if (current == null) return;
    final l10n = AppLocalizations.of(context);
    final from = TextEditingController(text: current.ipFrom);
    final header = TextEditingController(text: current.ipHeader);
    final other = TextEditingController(text: current.ipOther);
    bool open = current.open;
    final request = await showAppSheet<WebsiteRealIpDto>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: l10n.websites_realIp,
            onSave: () async => Navigator.of(context).pop(
              WebsiteRealIpDto(
                websiteID: websiteId,
                open: open,
                ipFrom: from.text.trim(),
                ipHeader: header.text.trim(),
                ipOther: other.text.trim(),
              ),
            ),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_enabled),
                value: open,
                onChanged: (value) => setState(() => open = value),
              ),
              AppTextField(
                controller: from,
                label: l10n.websites_ipFrom,
                hint: '127.0.0.1',
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: header,
                label: l10n.websites_ipHeader,
                hint: 'X-Forwarded-For',
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(controller: other, label: l10n.websites_ipOther),
            ],
          ),
        ),
      ),
    );
    from.dispose();
    header.dispose();
    other.dispose();
    if (request == null || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsiteRealIp(request);
      ref.invalidate(_realIpProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: context.scheme.primary),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleS),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(TablerIcons.chevron_right),
        ],
      ),
    );
  }
}

class _RewriteTab extends ConsumerStatefulWidget {
  const _RewriteTab({required this.websiteId});

  final int websiteId;

  @override
  ConsumerState<_RewriteTab> createState() => _RewriteTabState();
}

class _RewriteTabState extends ConsumerState<_RewriteTab> {
  final _name = TextEditingController();
  final _content = TextEditingController();
  List<String> _templates = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final templates = await repository.getCustomRewriteTemplates();
      if (!mounted) return;
      setState(() {
        _templates = templates;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      showErrorToast(context, error);
    }
  }

  Future<void> _loadTemplate(String name) async {
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final content = await repository.getRewriteContent(
        widget.websiteId,
        name,
      );
      if (!mounted) return;
      setState(() {
        _name.text = name;
        _content.text = content;
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateRewrite(
        widget.websiteId,
        _name.text.trim(),
        _content.text,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      ref.invalidate(websiteDetailProvider(widget.websiteId));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) return const SkeletonList(itemCount: 4);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        context.pagePadding,
        context.pagePadding,
        context.pagePadding + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        if (_templates.isNotEmpty) ...[
          Text(l10n.websites_rewriteTemplates, style: AppTextStyles.bodyS),
          const SizedBox(height: AppTokens.s8),
          Wrap(
            spacing: AppTokens.s8,
            runSpacing: AppTokens.s8,
            children: [
              for (final template in _templates)
                ActionChip(
                  label: Text(template),
                  onPressed: () => _loadTemplate(template),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
        ],
        AppTextField(controller: _name, label: l10n.websites_rewriteName),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _content,
          label: l10n.websites_rewriteContent,
          maxLines: 14,
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(label: l10n.action_save, onPressed: _save),
        const SizedBox(height: AppTokens.s8),
        SecondaryButton(
          label: l10n.websites_saveAsCustomRewrite,
          onPressed: _saveAsCustom,
        ),
      ],
    );
  }

  Future<void> _saveAsCustom() async {
    final l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.manageCustomRewrite(
        name: _name.text.trim(),
        operate: 'add',
        content: _content.text,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      await _load();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}

class _RedirectTab extends ConsumerWidget {
  const _RedirectTab({required this.websiteId});

  final int websiteId;

  Future<void> _editSource(
    BuildContext context,
    WidgetRef ref,
    WebsiteRedirectDto item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: item.content);
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: l10n.websites_editSource,
            subtitle: item.name,
            onSave: () async => Navigator.of(context).pop(true),
            children: [AppTextField(controller: controller, maxLines: 18)],
          ),
        ),
      ),
    );
    final content = controller.text;
    controller.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.saveWebsiteRedirectFile(websiteId, item.name, content);
      ref.invalidate(_redirectProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    WebsiteRedirectDto? current,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: current?.name ?? '');
    final domains = TextEditingController(
      text: current?.domains.join(',') ?? '',
    );
    final path = TextEditingController(text: current?.path ?? '');
    final target = TextEditingController(text: current?.target ?? '');
    String type = current?.type ?? 'domain';
    String redirect = current?.redirect ?? '301';
    bool keepPath = current?.keepPath ?? true;
    bool enable = current?.enable ?? true;
    bool redirectRoot = current?.redirectRoot ?? false;
    final saved = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.74,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.74,
        child: StatefulBuilder(
          builder: (pageContext, setState) => FormSheet(
            title: current == null
                ? l10n.websites_addRedirect
                : l10n.websites_editRedirect,
            onSave: () async => Navigator.of(context).pop(true),
            children: [
              AppTextField(controller: name, label: l10n.files_name),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(
                  labelText: l10n.websites_redirectType,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'domain',
                    child: Text(l10n.websites_redirectDomain),
                  ),
                  DropdownMenuItem(
                    value: 'path',
                    child: Text(l10n.websites_redirectPath),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => type = value);
                },
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: type == 'domain' ? domains : path,
                label: type == 'domain'
                    ? l10n.websites_domains
                    : l10n.websites_path,
                hint: type == 'domain' ? 'old.example.com' : '/old',
              ),
              const SizedBox(height: AppTokens.s12),
              AppTextField(
                controller: target,
                label: l10n.websites_redirectTarget,
                hint: 'https://example.com',
              ),
              const SizedBox(height: AppTokens.s12),
              DropdownButtonFormField<String>(
                initialValue: redirect,
                decoration: InputDecoration(
                  labelText: l10n.websites_redirectCode,
                ),
                items: const [
                  DropdownMenuItem(value: '301', child: Text('301')),
                  DropdownMenuItem(value: '302', child: Text('302')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => redirect = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_keepPath),
                value: keepPath,
                onChanged: (value) => setState(() => keepPath = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_redirectRoot),
                value: redirectRoot,
                onChanged: (value) => setState(() => redirectRoot = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.websites_enabled),
                value: enable,
                onChanged: (value) => setState(() => enable = value),
              ),
            ],
          ),
        ),
      ),
    );
    final request = WebsiteRedirectDto(
      websiteID: websiteId,
      name: name.text.trim(),
      domains: domains.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      keepPath: keepPath,
      enable: enable,
      type: type,
      redirect: redirect,
      path: path.text.trim(),
      target: target.text.trim(),
      redirectRoot: redirectRoot,
    );
    name.dispose();
    domains.dispose();
    path.dispose();
    target.dispose();
    if (saved != true || !context.mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsiteRedirect(request.toJson());
      ref.invalidate(_redirectProvider(websiteId));
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final redirects = ref.watch(_redirectProvider(websiteId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.s16,
            AppTokens.s16,
            AppTokens.s16,
            0,
          ),
          child: PrimaryButton(
            label: l10n.websites_addRedirect,
            icon: TablerIcons.plus,
            onPressed: () => _edit(context, ref),
          ),
        ),
        const SizedBox(height: AppTokens.s12),
        Expanded(
          child: AsyncStateView(
            value: redirects,
            onRetry: () => ref.invalidate(_redirectProvider(websiteId)),
            loading: const SkeletonList(itemCount: 4),
            isEmpty: (items) => items.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.arrow_forward,
              title: l10n.websites_noRedirects,
              message: l10n.websites_noRedirectsHint,
            ),
            builder: (items) => ListView.separated(
              padding: EdgeInsets.fromLTRB(
                context.pagePadding,
                context.pagePadding,
                context.pagePadding,
                context.pagePadding + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final item = items[index];
                return TonalCard(
                  onTap: () => _edit(context, ref, item),
                  child: Row(
                    children: [
                      Icon(
                        item.enable
                            ? TablerIcons.arrow_forward
                            : TablerIcons.arrow_forward_up,
                        color: item.enable
                            ? context.appColors.success
                            : context.scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: AppTextStyles.titleS),
                            Text(
                              '${item.domains.join(', ')}${item.path} -> ${item.target}',
                              style: AppTextStyles.caption.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.websites_editSource,
                        icon: const Icon(TablerIcons.file_code),
                        onPressed: () => _editSource(context, ref, item),
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

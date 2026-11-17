import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/tokens.dart';
import '../../../shell/nav_visibility.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/action_sheet.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/back_to_servers_button.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/removable_list_item.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/selection_app_bar.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/entry_animation.dart';
import '../../../common/states/refreshable_empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../../servers/providers/servers_provider.dart';
import '../../../../data/dto/app/app_installed_check_req.dart';
import '../../../../data/dto/app/app_installed_check_res.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../containers/widgets/container_log_page.dart';
import '../providers/websites_provider.dart';
import 'website_accounts_page.dart';
import 'website_advanced_page.dart';
import 'website_detail_page.dart';
import 'website_ssl_manage_page.dart';
import '../widgets/website_log_page.dart';
import 'openresty_advanced_sheets.dart';
import 'openresty_config_sheet.dart';
import 'openresty_performance_sheet.dart';
import 'openresty_status_sheet.dart';
import 'website_groups_page.dart';

class WebsitesPage extends ConsumerStatefulWidget {
  const WebsitesPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<WebsitesPage> createState() => _WebsitesPageState();
}

class _WebsitesPageState extends ConsumerState<WebsitesPage>
    with EntryAnimation<WebsitesPage> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  bool _searching = false;
  String _selectedFilter = '';
  bool _selecting = false;
  final Set<int> _selected = {};
  final Set<int> _removing = {};
  final MenuController _menuController = MenuController();

  bool get _selectionMode => _selecting;

  void _toggle(WebsiteDto site) {
    setState(() {
      if (!_selected.remove(site.id)) _selected.add(site.id);
      _selecting = _selected.isNotEmpty;
    });
    ref.read(bottomNavSuppressedProvider.notifier).state = _selecting;
  }

  void _clearSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
    ref.read(bottomNavSuppressedProvider.notifier).state = false;
  }

  Future<void> _batchDelete() async {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList(growable: false);
    if (ids.isEmpty) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_delete,
      message: l10n.files_selectCount(ids.length),
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      for (final id in ids) {
        await repository.deleteWebsite(id);
      }
      if (!mounted) return;
      setState(() => _removing.addAll(ids));
      await Future<void>.delayed(context.motion(AppTokens.dBase));
      if (!mounted) return;
      _clearSelection();
      AppToast.success(context, l10n.websites_deleted);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      await ref.read(websitesProvider.notifier).refresh();
      if (mounted) setState(() => _removing.removeAll(ids));
    }
  }

  Future<void> _batchOperate(String operate) async {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList(growable: false);
    if (ids.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.batchOperateWebsites(ids, operate);
      if (!mounted) return;
      _clearSelection();
      AppToast.success(context, l10n.websites_batchSuccess);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      await ref.read(websitesProvider.notifier).refresh();
    }
  }

  Future<void> _batchGroup() async {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList(growable: false);
    if (ids.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final groups = await repository.searchWebsiteGroups();
      if (!mounted) return;
      final groupId = await showSelectionMenu<int>(
        context,
        title: l10n.websites_selectGroup,
        options: [
          for (final group in groups)
            SelectionOption(
              label: group.name,
              value: group.id,
              icon: TablerIcons.folder,
            ),
        ],
      );
      if (groupId == null || !mounted) return;
      await repository.batchSetWebsiteGroup(ids, groupId);
      if (!mounted) return;
      _clearSelection();
      AppToast.success(context, l10n.websites_batchSuccess);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      await ref.read(websitesProvider.notifier).refresh();
    }
  }

  Future<void> _batchSsl() async {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList(growable: false);
    if (ids.isEmpty) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final result = await repository.searchSsl({
        'page': 1,
        'pageSize': 100,
        'orderBy': 'created_at',
        'order': 'descending',
      });
      if (!mounted) return;
      if (result.items.isEmpty) {
        AppToast.warning(context, l10n.state_empty);
        return;
      }
      final sslId = await showSelectionMenu<int>(
        context,
        title: l10n.websites_selectSsl,
        options: [
          for (final ssl in result.items)
            SelectionOption(
              label: ssl.primaryDomain,
              value: ssl.id,
              icon: TablerIcons.shield_check,
            ),
        ],
      );
      if (sslId == null || !mounted) return;
      await repository.batchSetWebsiteHttps(ids: ids, sslId: sslId);
      if (!mounted) return;
      _clearSelection();
      AppToast.success(context, l10n.websites_batchSuccess);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      await ref.read(websitesProvider.notifier).refresh();
    }
  }

  static const _filters = [
    '',
    'deployment',
    'static',
    'proxy',
    'runtime',
    'subsite',
    'stream',
  ];

  @override
  void deactivate() {
    ref.read(bottomNavSuppressedProvider.notifier).state = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _filterLabel(String value, AppLocalizations l10n) {
    return switch (value) {
      'deployment' => l10n.websites_deployment,
      'static' => l10n.websites_static,
      'proxy' => l10n.websites_proxy,
      'runtime' => l10n.websites_runtime,
      'subsite' => l10n.websites_subsite,
      'stream' => l10n.websites_tunnel,
      _ => l10n.websites_all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final server = ref.watch(serverByIdProvider(widget.serverId)).valueOrNull;
    final websites = ref.watch(websitesProvider);
    final total = websites.valueOrNull?.total;

    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectionMode) _clearSelection();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (_selectionMode)
                SelectionAppBar(
                  selectedCount: _selected.length,
                  onCancel: _clearSelection,
                  height: AppTokens.appBarLargeHeight,
                )
              else
                AppBarLarge(
                  leading: const BackToServersButton(),
                  title: l10n.websites_title,
                  subtitle: [
                    if (server != null) server.displayName,
                    if (total != null) l10n.websites_count(total),
                  ].join(' · '),
                  onTitleTap: () => showServerSwitcher(
                    context,
                    ref,
                    currentServerId: widget.serverId,
                  ),
                  actions: [
                    AppIconButton(
                      icon: _searching ? TablerIcons.x : TablerIcons.search,
                      tooltip: l10n.action_search,
                      onPressed: () {
                        setState(() {
                          _searching = !_searching;
                          if (!_searching) {
                            _clearSelection();
                            _searchController.clear();
                            ref.read(websitesProvider.notifier).search('');
                          }
                        });
                      },
                    ),
                    AppIconButton(
                      icon: TablerIcons.plus,
                      tooltip: l10n.websites_create,
                      onPressed: _showCreateMenu,
                    ),
                    _moduleMenu(context, l10n),
                  ],
                ),
              AnimatedSize(
                duration: context.motion(AppTokens.dBase),
                curve: AppTokens.curveBase,
                alignment: Alignment.topCenter,
                child: _searching
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.pagePadding,
                          vertical: AppTokens.s8,
                        ),
                        child: SearchField(
                          controller: _searchController,
                          hint: l10n.action_search,
                          autofocus: true,
                          onChanged: (value) {
                            _clearSelection();
                            _debouncer(() {
                              ref.read(websitesProvider.notifier).search(value);
                            }, delay: const Duration(milliseconds: 300));
                          },
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              AppFilterChips<String>(
                options: _filters,
                labelOf: (value) => _filterLabel(value, l10n),
                selected: {_selectedFilter},
                wrap: true,
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
                onChanged: (selection) {
                  if (selection.isEmpty) return;
                  setState(() {
                    _selectedFilter = selection.first;
                    _clearSelection();
                  });
                  ref.read(websitesProvider.notifier).setType(selection.first);
                },
              ),
              Expanded(
                child: AsyncStateView(
                  value: websites,
                  contentKey: (_selectedFilter, _searchController.text),
                  onRetry: () => ref.read(websitesProvider.notifier).refresh(),
                  loading: const SkeletonList(itemCount: 8),
                  isEmpty: (result) => result.items.isEmpty,
                  empty: RefreshableEmptyState(
                    onRefresh: () =>
                        ref.read(websitesProvider.notifier).refresh(),
                    child: EmptyState(
                      icon: TablerIcons.world,
                      title: l10n.websites_empty_title,
                      message: l10n.websites_empty_message,
                      actionLabel: l10n.websites_create,
                      onAction: _menuController.open,
                    ),
                  ),
                  builder: (result) {
                    stopEntryAnimation(result.items.isNotEmpty);
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(websitesProvider.notifier).refresh(),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.extentAfter < 400) {
                            ref.read(websitesProvider.notifier).loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            context.pagePadding,
                            AppTokens.s8,
                            context.pagePadding,
                            AppTokens.bottomNavClearance +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          itemCount: result.items.length,
                          itemBuilder: (context, index) {
                            final site = result.items[index];
                            return RemovableListItem(
                              key: ValueKey('website-${site.id}'),
                              removing: _removing.contains(site.id),
                              animateIn:
                                  entryAnimationEnabled &&
                                  index < AppTokens.listEntryAnimationLimit,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppTokens.s12,
                                ),
                                child: _WebsiteCard(
                                  site: site,
                                  selected: _selected.contains(site.id),
                                  selectionMode: _selectionMode,
                                  onTap: _selectionMode
                                      ? () => _toggle(site)
                                      : () => _showSiteActions(site),
                                  onLongPress: () => _toggle(site),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AnimatedSize(
          duration: context.motion(AppTokens.dBase),
          curve: AppTokens.curveBase,
          alignment: Alignment.bottomCenter,
          child: _selectionMode
              ? SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.s16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.files_selectCount(_selected.length),
                            style: AppTextStyles.bodyM,
                          ),
                        ),
                        MenuAnchor(
                          menuChildren: [
                            MenuItemButton(
                              onPressed: () => _batchOperate('start'),
                              child: Text(l10n.action_enable),
                            ),
                            MenuItemButton(
                              onPressed: () => _batchOperate('stop'),
                              child: Text(l10n.action_disable),
                            ),
                            MenuItemButton(
                              onPressed: _batchGroup,
                              child: Text(l10n.websites_changeGroup),
                            ),
                            MenuItemButton(
                              onPressed: _batchSsl,
                              child: Text(l10n.websites_bindSsl),
                            ),
                          ],
                          builder: (context, controller, child) => IconButton(
                            tooltip: l10n.websites_batchActions,
                            icon: const Icon(TablerIcons.dots),
                            onPressed: () => controller.isOpen
                                ? controller.close()
                                : controller.open(),
                          ),
                        ),
                        const SizedBox(width: AppTokens.s8),
                        DangerButton(
                          expanded: false,
                          icon: TablerIcons.trash,
                          label: l10n.action_delete,
                          onPressed: _batchDelete,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    return switch (status.toLowerCase()) {
      'running' => l10n.websites_running,
      'stopped' => l10n.websites_stopped,
      _ => l10n.common_unknown,
    };
  }

  Future<void> _editDefaultHtml() async {
    final l10n = AppLocalizations.of(context);
    final type = await showSelectionMenu<String>(
      context,
      title: l10n.websites_htmlType,
      options: [
        SelectionOption(value: 'index', label: l10n.websites_htmlIndex),
        SelectionOption(value: '404', label: l10n.websites_html404),
        SelectionOption(value: 'php', label: l10n.websites_htmlPhp),
        SelectionOption(value: 'domain404', label: l10n.websites_htmlDomain404),
        SelectionOption(value: 'stop', label: l10n.websites_htmlStop),
      ],
    );
    if (type == null || !mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final current = await repository.getDefaultHtml(type);
      if (!mounted) return;
      final controller = TextEditingController(
        text: '${current['content'] ?? ''}',
      );
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.websites_defaultHtml,
            saveLabel: l10n.action_save,
            onSave: () async {
              await repository.updateDefaultHtml(
                type: type,
                content: controller.text,
              );
              if (!pageContext.mounted) return;
              Navigator.of(pageContext).pop(true);
            },
            children: [
              AppTextField(
                controller: controller,
                label: l10n.websites_htmlContent,
                maxLines: 16,
              ),
            ],
          ),
        ),
      );

      if (saved != true || !mounted) return;
      AppToast.success(context, l10n.websites_htmlSaved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showCreateMenu() async {
    final l10n = AppLocalizations.of(context);
    final type = await showSelectionMenu<String>(
      context,
      options: [
        SelectionOption(
          label: l10n.websites_proxy,
          value: 'proxy',
          icon: TablerIcons.arrows_exchange,
          subtitle: l10n.websites_proxyHint,
        ),
        SelectionOption(
          label: l10n.websites_static,
          value: 'static',
          icon: TablerIcons.file_text,
          subtitle: l10n.websites_staticHint,
        ),
        SelectionOption(
          label: l10n.websites_runtime,
          value: 'runtime',
          icon: TablerIcons.brand_php,
          subtitle: l10n.websites_runtimeHint,
        ),
        SelectionOption(
          label: l10n.websites_tunnel,
          value: 'stream',
          icon: TablerIcons.arrows_split,
          subtitle: l10n.websites_createStreamTitle,
        ),
        SelectionOption(
          label: l10n.websites_deployment,
          value: 'deployment',
          icon: TablerIcons.rocket,
          subtitle: l10n.websites_deploymentApp,
        ),
        SelectionOption(
          label: l10n.websites_subsite,
          value: 'subsite',
          icon: TablerIcons.folder_symlink,
          subtitle: l10n.websites_subsitePath,
        ),
      ],
    );
    if (!mounted || type == null) return;
    await context.push('/s/${widget.serverId}/websites/create?type=$type');
  }

  Widget _moduleMenu(BuildContext context, AppLocalizations l10n) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(-172, 8),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          context.scheme.surfaceContainer,
        ),
        elevation: const WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.rLg),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6),
        ),
      ),
      menuChildren: [
        SubmenuButton(
          menuChildren: [
            _createItem(
              context,
              l10n,
              TablerIcons.arrows_exchange,
              l10n.websites_proxy,
              l10n.websites_proxyHint,
              'proxy',
            ),
            _createItem(
              context,
              l10n,
              TablerIcons.file_text,
              l10n.websites_static,
              l10n.websites_staticHint,
              'static',
            ),
            _createItem(
              context,
              l10n,
              TablerIcons.brand_php,
              l10n.websites_runtime,
              l10n.websites_runtimeHint,
              'runtime',
            ),
            _createItem(
              context,
              l10n,
              TablerIcons.arrows_split,
              l10n.websites_tunnel,
              l10n.websites_createStreamTitle,
              'stream',
            ),
            _createItem(
              context,
              l10n,
              TablerIcons.rocket,
              l10n.websites_deployment,
              l10n.websites_deploymentApp,
              'deployment',
            ),
            _createItem(
              context,
              l10n,
              TablerIcons.folder_symlink,
              l10n.websites_subsite,
              l10n.websites_subsitePath,
              'subsite',
            ),
          ],
          child: _menuRow(
            context,
            TablerIcons.plus,
            l10n.websites_create,
            width: 160,
          ),
        ),
        _item(
          context,
          TablerIcons.file_code,
          l10n.websites_defaultHtml,
          _editDefaultHtml,
        ),
        _item(
          context,
          TablerIcons.search,
          l10n.action_search,
          () => setState(() {
            _searching = !_searching;
            if (!_searching) {
              _clearSelection();
              _searchController.clear();
              ref.read(websitesProvider.notifier).search('');
            }
          }),
        ),
        _item(
          context,
          _selectionMode ? TablerIcons.square_x : TablerIcons.checkbox,
          _selectionMode ? l10n.files_cancelSelection : l10n.files_selectAll,
          () {
            setState(() {
              if (_selectionMode) {
                _clearSelection();
              } else {
                _selecting = true;
                final items = ref.read(websitesProvider).valueOrNull?.items;
                _selected.addAll((items ?? const []).map((site) => site.id));
              }
            });
          },
        ),
        _item(
          context,
          TablerIcons.folder,
          l10n.websites_groupManagement,
          () => showWebsiteGroupsSheet(context, serverId: widget.serverId),
        ),
        _item(
          context,
          TablerIcons.layout,
          l10n.websites_templates,
          () => context.push('/s/${widget.serverId}/websites/templates'),
        ),
        _item(
          context,
          TablerIcons.certificate,
          l10n.websites_certificateAccounts,
          () => showWebsiteAccountsSheet(context),
        ),
        _item(
          context,
          TablerIcons.activity,
          l10n.websites_openRestyStatus,
          () => _openRestyAction(() => showOpenRestyStatusSheet(context)),
        ),
        _item(
          context,
          TablerIcons.file_text,
          l10n.websites_openRestyLogs,
          _openOpenRestyLogs,
        ),
        _item(
          context,
          TablerIcons.settings,
          l10n.websites_openRestyConfigFile,
          () => _openRestyAction(() => showOpenRestyConfigSheet(context)),
        ),
        _item(
          context,
          TablerIcons.adjustments,
          l10n.websites_openRestyPerformanceTitle,
          () => _openRestyAction(() => showOpenRestyPerformanceSheet(context)),
        ),
        _item(
          context,
          TablerIcons.packages,
          l10n.websites_openRestyModules,
          () => _openRestyAction(() => showOpenRestyModulesSheet(context)),
        ),
        _item(
          context,
          TablerIcons.hammer,
          l10n.websites_openRestyBuild,
          () => _openRestyAction(
            () => pushFormPage<void>(context, const OpenRestyBuildPage()),
          ),
        ),
        _item(
          context,
          TablerIcons.lock,
          l10n.websites_openRestyHttps,
          () => _openRestyAction(() => showOpenRestyHttpsSheet(context)),
        ),
        SubmenuButton(
          menuChildren: [
            _serviceItem('start', l10n.websites_openRestyStart),
            _serviceItem('stop', l10n.websites_openRestyStop),
            _serviceItem('restart', l10n.websites_openRestyRestart),
            _serviceItem('reload', l10n.websites_openRestyReload),
          ],
          child: _menuRow(
            context,
            TablerIcons.settings_cog,
            l10n.websites_openRestyService,
            width: 160,
          ),
        ),
      ],
      builder: (context, controller, child) => AppIconButton(
        icon: TablerIcons.dots,
        tooltip: l10n.websites_menu,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  Widget _menuRow(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    double width = 196,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.bodyM),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onPressed,
  ) {
    return MenuItemButton(
      onPressed: onPressed,
      child: _menuRow(context, icon, title),
    );
  }

  Widget _createItem(
    BuildContext context,
    AppLocalizations l10n,
    IconData icon,
    String title,
    String subtitle,
    String type,
  ) {
    return MenuItemButton(
      onPressed: () =>
          context.push('/s/${widget.serverId}/websites/create?type=$type'),
      child: _menuRow(context, icon, title, subtitle: subtitle),
    );
  }

  Widget _serviceItem(String operate, String label) {
    return MenuItemButton(
      onPressed: () => _runService(operate, label),
      child: _menuRow(context, TablerIcons.settings_cog, label),
    );
  }

  Future<AppInstalledCheckRes?> _checkOpenResty() async {
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final check = await repository.checkAppInstalled(
        const AppInstalledCheckReq(key: 'openresty'),
      );
      if (!check.isExist) {
        if (!mounted) return null;
        await _showOpenRestyUnavailable(installed: false);
        return null;
      }
      return check;
    } catch (error) {
      if (mounted) showErrorToast(context, error);
      return null;
    }
  }

  Future<void> _showOpenRestyUnavailable({required bool installed}) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(
            title: installed
                ? l10n.websites_openRestyStopped
                : l10n.websites_openRestyNotInstalled,
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
          const SizedBox(height: AppTokens.s16),
          Text(
            installed
                ? l10n.websites_openRestyServiceHint
                : l10n.websites_openRestyInstallHint,
            style: AppTextStyles.bodyM.copyWith(
              color: sheetContext.scheme.onSurfaceVariant,
            ),
          ),
          if (!installed) ...[
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: l10n.websites_openRestyInstall,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push('/s/${widget.serverId}/more/apps?key=openresty');
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openRestyAction(Future<void> Function() action) async {
    final check = await _checkOpenResty();
    if (check == null || !mounted) return;
    if (check.status.toLowerCase() == 'stopped') {
      await _showOpenRestyUnavailable(installed: true);
      return;
    }
    await action();
  }

  Future<void> _openOpenRestyLogs() async {
    final check = await _checkOpenResty();
    if (check == null || !mounted) return;
    if (check.containerName.trim().isEmpty) return;
    await openContainerLogs(
      context,
      ref,
      containerName: check.containerName,
      subtitle: 'OpenResty',
    );
  }

  Future<void> _runService(String operate, String label) async {
    final l10n = AppLocalizations.of(context);
    final check = await _checkOpenResty();
    if (check == null || !mounted) return;
    if (operate != 'reload') {
      final confirmed = await showConfirmSheet(
        context,
        title: label,
        message: l10n.websites_openRestyServiceConfirm(label),
        confirmLabel: label,
        danger: operate == 'stop',
      );
      if (!confirmed || !mounted) return;
    }
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      switch (operate) {
        case 'start':
          await repository.startInstalled(
            installId: check.appInstallId,
            detailId: 0,
          );
        case 'stop':
          await repository.stopInstalled(
            installId: check.appInstallId,
            detailId: 0,
          );
        case 'restart':
          await repository.restartInstalled(
            installId: check.appInstallId,
            detailId: 0,
          );
        case 'reload':
          await repository.reloadInstalled(
            installId: check.appInstallId,
            detailId: 0,
          );
      }
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<void> _showSiteActions(WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final running = site.status.toLowerCase() == 'running';
    final colors = context.appColors;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.9,
      builder: (sheetContext) => ActionSheetScaffold(
        infoCard: ActionSheetInfoCard(
          leading: Container(
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.rMd),
            ),
            child: Icon(
              TablerIcons.world,
              color: colors.info,
              size: AppTokens.iconNav,
            ),
          ),
          title: site.primaryDomain,
          subtitle: site.type,
          trailing: ActionSheetStatusPill(
            label: _statusLabel(site.status, l10n),
            color: running ? colors.success : colors.info,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActionSheetSection(
              title: l10n.containers_groupLifecycle,
              icon: TablerIcons.refresh,
              children: [
                ActionSheetRow(
                  icon: running
                      ? TablerIcons.player_pause
                      : TablerIcons.player_play,
                  iconColor: running ? colors.warning : colors.success,
                  title: running ? l10n.websites_stop : l10n.websites_start,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _operateSite(site, running ? 'stop' : 'start');
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.eye,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_open,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openSite(site);
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.copy,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_copyDomain,
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: site.primaryDomain),
                    );
                    if (!sheetContext.mounted) return;
                    Navigator.of(sheetContext).pop();
                    if (!mounted) return;
                    AppToast.success(
                      context,
                      l10n.common_copiedLabel(site.primaryDomain),
                    );
                  },
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.containers_groupConfig,
              icon: TablerIcons.settings,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.info_circle,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.error_details,
                  onTap: () => showWebsiteTabSheet(
                    sheetContext,
                    serverId: widget.serverId,
                    websiteId: site.id,
                    tab: 0,
                  ),
                ),
                ActionSheetRow(
                  icon: TablerIcons.world_www,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_domains,
                  onTap: () => showWebsiteTabSheet(
                    sheetContext,
                    serverId: widget.serverId,
                    websiteId: site.id,
                    tab: 1,
                  ),
                ),
                ActionSheetRow(
                  icon: TablerIcons.lock,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_sslCertificate,
                  onTap: () => showWebsiteSslSheet(
                    sheetContext,
                    serverId: widget.serverId,
                    websiteId: site.id,
                    domain: site.primaryDomain,
                  ),
                ),
                ActionSheetRow(
                  icon: TablerIcons.arrows_exchange,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_proxySettings,
                  onTap: () => showWebsiteTabSheet(
                    sheetContext,
                    serverId: widget.serverId,
                    websiteId: site.id,
                    tab: 3,
                  ),
                ),
                ActionSheetRow(
                  icon: TablerIcons.sitemap,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_loadBalance,
                  onTap: () => showWebsiteTabSheet(
                    sheetContext,
                    serverId: widget.serverId,
                    websiteId: site.id,
                    tab: 4,
                  ),
                ),
                ActionSheetRow(
                  icon: TablerIcons.adjustments,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_advanced,
                  onTap: () => showWebsiteAdvancedSheet(
                    sheetContext,
                    serverId: widget.serverId,
                    websiteId: site.id,
                  ),
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.websites_logs,
              icon: TablerIcons.file_text,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.file_text,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_logs,
                  subtitle: l10n.websites_liveLogHint,
                  onTap: () => showWebsiteLogsSheet(
                    sheetContext,
                    ref,
                    websiteId: site.id,
                    subtitle: site.primaryDomain,
                  ),
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.containers_groupDanger,
              icon: TablerIcons.alert_triangle,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.trash,
                  iconColor: colors.danger,
                  title: l10n.websites_delete,
                  danger: true,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _deleteSite(site);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _operateSite(WebsiteDto site, String operate) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.operateWebsite(site.id, operate);
      if (!mounted) return;
      AppToast.success(
        context,
        operate == 'start' ? l10n.websites_started : l10n.websites_stopped,
      );
      await ref.read(websitesProvider.notifier).refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _openSite(WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final protocol = site.protocol.toLowerCase() == 'https' ? 'https' : 'http';
    final uri = Uri.tryParse('$protocol://${site.primaryDomain}');
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      showErrorToast(
        context,
        ApiBusinessException(400, l10n.websites_openFailed),
      );
    }
  }

  Future<void> _deleteSite(WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final options = await showAppSheet<WebsiteDeleteOptions>(
      context: context,
      builder: (sheetContext) => WebsiteDeleteSheet(site: site),
    );
    if (options == null || !mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_deleteTitle(site.primaryDomain),
      message: l10n.websites_deleteMessage,
      confirmLabel: l10n.action_delete,
      requireText: site.primaryDomain,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteWebsite(
        site.id,
        deleteBackup: options.deleteBackup,
        forceDelete: options.forceDelete,
        deleteDB: options.deleteDB,
      );
      if (!mounted) return;
      setState(() => _removing.add(site.id));
      await Future<void>.delayed(context.motion(AppTokens.dBase));
      if (!mounted) return;
      AppToast.success(context, l10n.websites_deleted);
      await ref.read(websitesProvider.notifier).refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _removing.remove(site.id));
    }
  }
}

class WebsiteDeleteOptions {
  const WebsiteDeleteOptions({
    required this.deleteDB,
    required this.deleteBackup,
    required this.forceDelete,
  });

  final bool deleteDB;
  final bool deleteBackup;
  final bool forceDelete;
}

class WebsiteDeleteSheet extends StatefulWidget {
  const WebsiteDeleteSheet({super.key, required this.site});

  final WebsiteDto site;

  @override
  State<WebsiteDeleteSheet> createState() => WebsiteDeleteSheetState();
}

class WebsiteDeleteSheetState extends State<WebsiteDeleteSheet> {
  bool _deleteDB = false;
  bool _deleteBackup = false;
  bool _forceDelete = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasDatabase = widget.site.type == 'runtime';
    final scheme = context.scheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.websites_deleteTitle(widget.site.primaryDomain),
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppTokens.s8),
        Text(
          l10n.websites_deleteMessage,
          style: AppTextStyles.bodyM.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppTokens.s16),
        TonalCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              CheckboxListTile(
                value: _deleteDB,
                onChanged: hasDatabase
                    ? (value) => setState(() => _deleteDB = value ?? false)
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  hasDatabase
                      ? l10n.websites_deleteDatabaseCount(1)
                      : l10n.websites_deleteDatabaseCount(0),
                ),
                subtitle: hasDatabase
                    ? Text('${widget.site.dbType} · ${widget.site.dbID}')
                    : null,
              ),
              CheckboxListTile(
                value: _deleteBackup,
                onChanged: (value) =>
                    setState(() => _deleteBackup = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.websites_deleteBackup),
              ),
              CheckboxListTile(
                value: _forceDelete,
                onChanged: (value) =>
                    setState(() => _forceDelete = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.websites_forceDelete),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.action_cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: DangerButton(
                label: l10n.action_delete,
                onPressed: () => Navigator.of(context).pop(
                  WebsiteDeleteOptions(
                    deleteDB: _deleteDB,
                    deleteBackup: _deleteBackup,
                    forceDelete: _forceDelete,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WebsiteCard extends StatelessWidget {
  const _WebsiteCard({
    required this.site,
    required this.onTap,
    required this.onLongPress,
    required this.selected,
    required this.selectionMode,
  });

  final WebsiteDto site;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final typeLabel = websiteTypeLabel(site.type, l10n);
    final expiry = _parseDate(site.sslExpireDate).isAfter(DateTime(2000))
        ? _parseDate(site.sslExpireDate)
        : _parseDate(site.expireDate);
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    final expiryColor = daysLeft < 0
        ? context.appColors.danger
        : daysLeft < 7
        ? context.appColors.danger
        : daysLeft < 30
        ? context.appColors.warning
        : scheme.onSurfaceVariant;

    final expiryLabel = daysLeft < 0
        ? l10n.websites_expired_days(-daysLeft)
        : daysLeft == 0
        ? l10n.websites_expire_today
        : l10n.websites_expire_days(daysLeft);

    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectionMode)
                Padding(
                  padding: const EdgeInsets.only(top: AppTokens.s4),
                  child: Checkbox(value: selected, onChanged: (_) => onTap()),
                ),
              Padding(
                padding: const EdgeInsets.only(top: AppTokens.s8),
                child: StatusDot(status: site.status.toLowerCase()),
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  site.primaryDomain,
                  style: AppTextStyles.titleM,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!selectionMode) ...[
                const SizedBox(width: AppTokens.s4),
                Padding(
                  padding: const EdgeInsets.only(top: AppTokens.s4),
                  child: Icon(
                    TablerIcons.chevron_right,
                    size: AppTokens.iconList,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Wrap(
            spacing: AppTokens.s8,
            runSpacing: AppTokens.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill(
                label: _statusLabel(site.status, l10n),
                tone: context.appColors.status(site.status),
                dense: true,
                showDot: true,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppTokens.rXs),
                ),
                child: Text(
                  typeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (site.protocol.toUpperCase() == 'HTTPS')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.s8,
                    vertical: AppTokens.chipPaddingY,
                  ),
                  decoration: BoxDecoration(
                    color: expiryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppTokens.rXs),
                  ),
                  child: Text(
                    l10n.websites_ssl,
                    style: AppTextStyles.caption.copyWith(
                      color: expiryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (expiry.isAfter(DateTime(2000))) ...[
            const SizedBox(height: AppTokens.s8),
            Row(
              children: [
                Icon(TablerIcons.calendar_event, size: 14, color: expiryColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    expiryLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: expiryColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    return switch (status.toLowerCase()) {
      'running' => l10n.websites_running,
      'stopped' => l10n.websites_stopped,
      _ => l10n.common_unknown,
    };
  }

  DateTime _parseDate(String raw) {
    return DateTime.tryParse(raw) ?? DateTime(1970);
  }
}

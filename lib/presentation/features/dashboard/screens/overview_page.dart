import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/app_toast.dart';
import '../../../../data/repositories_impl/dashboard_repository_impl.dart';
import '../../../../data/repositories_impl/host_repository_impl.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_mapper.dart';
import '../../../common/states/error_state.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../../servers/providers/servers_provider.dart';
import '../providers/overview_provider.dart';
import '../widgets/dashboard_cards.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage>
    with WidgetsBindingObserver {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setVisible(true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setVisible(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _setVisible(false);
    }
  }

  void _setVisible(bool visible) {
    if (!mounted || _visible == visible) return;
    _visible = visible;
    ref.read(overviewProvider(widget.serverId).notifier).setVisible(visible);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final server = ref.watch(serverByIdProvider(widget.serverId)).valueOrNull;
    final overview = ref.watch(overviewProvider(widget.serverId));

    return Scaffold(
      body: VisibilityDetector(
        key: Key('overview-${widget.serverId}'),
        onVisibilityChanged: (info) => _setVisible(info.visibleFraction > 0.5),
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(overviewProvider(widget.serverId).notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBarLarge(
                title: server?.displayName ?? l10n.nav_overview,
                subtitle: server == null
                    ? null
                    : '${server.host}:${server.port}',
                onTitleTap: () => showServerSwitcher(
                  context,
                  ref,
                  currentServerId: widget.serverId,
                ),
                actions: [
                  AppIconButton(
                    icon: TablerIcons.refresh,
                    tooltip: l10n.action_refresh,
                    onPressed: () => ref
                        .read(overviewProvider(widget.serverId).notifier)
                        .refresh(),
                  ),
                  AppIconButton(
                    icon: TablerIcons.adjustments,
                    tooltip: l10n.dashboard_monitorOptions,
                    onPressed: () async {
                      final current = ref.read(
                        overviewSelectionProvider(widget.serverId),
                      );
                      final next = await showAppSheet<MonitorSelection>(
                        context: context,
                        builder: (_) => _MonitorOptionsSheet(
                          serverId: widget.serverId,
                          initial: current,
                        ),
                      );
                      if (next == null || !mounted) return;
                      ref
                              .read(
                                overviewSelectionProvider(
                                  widget.serverId,
                                ).notifier,
                              )
                              .state =
                          next;
                    },
                  ),
                  AppIconButton(
                    icon: TablerIcons.terminal_2,
                    tooltip: l10n.dashboard_terminal,
                    onPressed: () =>
                        context.push('/s/${widget.serverId}/terminal'),
                  ),
                ],
              ),
              ...overview.when(
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                loading: () => [
                  const SliverToBoxAdapter(
                    child: SkeletonShimmer(
                      child: Padding(
                        padding: EdgeInsets.all(AppTokens.s16),
                        child: Column(
                          children: [
                            SkeletonCard(height: 142),
                            SizedBox(height: AppTokens.s12),
                            SkeletonCard(height: 231),
                            SizedBox(height: AppTokens.s12),
                            SkeletonCard(height: 141),
                            SizedBox(height: AppTokens.s12),
                            SkeletonCard(height: 196),
                            SizedBox(height: AppTokens.s12),
                            SkeletonCard(height: 173),
                            SizedBox(height: AppTokens.s12),
                            SkeletonCard(height: 281),
                            SizedBox(height: AppTokens.s12),
                            SkeletonCard(height: 260),
                            SizedBox(height: AppTokens.s12),
                            SkeletonCard(height: 250),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                error: (error, stack) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorState(
                      data: mapError(error, l10n),
                      onRetry: () => ref
                          .read(overviewProvider(widget.serverId).notifier)
                          .refresh(),
                    ),
                  ),
                ],
                data: (state) => [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      context.pagePadding,
                      AppTokens.s8,
                      context.pagePadding,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          if (state.stale)
                            _OfflineBanner(
                              message: l10n.dashboard_offline_banner,
                              lastUpdated: state.lastUpdated,
                            ),
                          ...buildDashboardCards(
                            context: context,
                            l10n: l10n,
                            dashboard: state.dashboard,
                            state: state,
                          ),
                          _DashboardExtrasSection(serverId: widget.serverId),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      AppTokens.bottomNavClearance +
                      MediaQuery.paddingOf(context).bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.message, required this.lastUpdated});

  final String message;
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTokens.s12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s12,
        vertical: AppTokens.s8,
      ),
      decoration: BoxDecoration(
        color: context.appColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.rMd),
      ),
      child: Row(
        children: [
          Icon(
            TablerIcons.wifi_off,
            size: AppTokens.iconList,
            color: context.appColors.warning,
          ),
          const SizedBox(width: AppTokens.s8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyS.copyWith(
                color: context.appColors.warning,
              ),
            ),
          ),
          Text(
            '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}',
            style: AppTextStyles.caption.copyWith(
              color: context.appColors.warning,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitorOptionsSheet extends ConsumerStatefulWidget {
  const _MonitorOptionsSheet({required this.serverId, required this.initial});

  final int serverId;
  final MonitorSelection initial;

  @override
  ConsumerState<_MonitorOptionsSheet> createState() =>
      _MonitorOptionsSheetState();
}

class _MonitorOptionsSheetState extends ConsumerState<_MonitorOptionsSheet> {
  late String _io = widget.initial.io;
  late String _net = widget.initial.net;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ioOptions = ref.watch(overviewIoOptionsProvider(widget.serverId));
    final netOptions = ref.watch(overviewNetOptionsProvider(widget.serverId));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dashboard_monitorOptions, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        ioOptions.when(
          data: (items) => DropdownButtonFormField<String>(
            initialValue: _io,
            decoration: InputDecoration(labelText: l10n.dashboard_monitorDisk),
            items: [
              DropdownMenuItem(
                value: 'all',
                child: Text(l10n.dashboard_monitorAll),
              ),
              for (final item in items)
                DropdownMenuItem(value: item, child: Text(item)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _io = value);
            },
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(
            describeError(error, l10n),
            style: AppTextStyles.bodyS.copyWith(color: context.scheme.error),
          ),
        ),
        const SizedBox(height: AppTokens.s12),
        netOptions.when(
          data: (items) => DropdownButtonFormField<String>(
            initialValue: _net,
            decoration: InputDecoration(
              labelText: l10n.dashboard_monitorNetwork,
            ),
            items: [
              DropdownMenuItem(
                value: 'all',
                child: Text(l10n.dashboard_monitorAll),
              ),
              for (final item in items)
                DropdownMenuItem(value: item, child: Text(item)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _net = value);
            },
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(
            describeError(error, l10n),
            style: AppTextStyles.bodyS.copyWith(color: context.scheme.error),
          ),
        ),
        const SizedBox(height: AppTokens.s12),
        SecondaryButton(
          label: l10n.dashboard_cleanMonitor,
          expanded: true,
          onPressed: () async {
            final confirmed = await showConfirmSheet(
              context,
              title: l10n.dashboard_cleanMonitor,
              message: l10n.dashboard_cleanMonitorConfirm,
              confirmLabel: l10n.action_confirm,
              danger: true,
            );
            if (!confirmed || !context.mounted) return;
            try {
              final repository = await ref.read(
                hostRepositoryProvider(widget.serverId).future,
              );
              await repository.cleanMonitor();
              if (!context.mounted) return;
              AppToast.success(context, l10n.action_done);
            } catch (error) {
              if (!context.mounted) return;
              showErrorToast(context, error);
            }
          },
        ),
        const SizedBox(height: AppTokens.s20),
        PrimaryButton(
          label: l10n.action_confirm,
          expanded: true,
          onPressed: () => Navigator.of(context).pop((io: _io, net: _net)),
        ),
      ],
    );
  }
}

class _DashboardExtrasData {
  const _DashboardExtrasData({
    required this.quick,
    required this.launcher,
    required this.topCpu,
    required this.topMem,
    required this.node,
  });

  final List<Map<String, dynamic>> quick;
  final List<Map<String, dynamic>> launcher;
  final List<Map<String, dynamic>> topCpu;
  final List<Map<String, dynamic>> topMem;
  final Map<String, dynamic> node;
}

final _dashboardExtrasProvider = FutureProvider.autoDispose
    .family<_DashboardExtrasData, int>((ref, serverId) async {
      final repository = await ref.watch(dashboardRepositoryProvider.future);
      final results = await Future.wait<Object>([
        repository.getQuickOptions(),
        repository.getAppLauncher(),
        repository.getTopCpu(),
        repository.getTopMem(),
        repository.getNodeCurrent(),
      ]);
      return _DashboardExtrasData(
        quick: results[0] as List<Map<String, dynamic>>,
        launcher: results[1] as List<Map<String, dynamic>>,
        topCpu: results[2] as List<Map<String, dynamic>>,
        topMem: results[3] as List<Map<String, dynamic>>,
        node: results[4] as Map<String, dynamic>,
      );
    }, name: 'dashboardExtrasProvider');

class _DashboardExtrasSection extends ConsumerWidget {
  const _DashboardExtrasSection({required this.serverId});

  final int serverId;

  double _num(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is num ? value.toDouble() : 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final extras = ref.watch(_dashboardExtrasProvider(serverId));
    return extras.when(
      skipLoadingOnRefresh: true,
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (data) => Column(
        children: [
          const SizedBox(height: AppTokens.s12),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.dashboard_quickJumps,
                        style: AppTextStyles.titleM,
                      ),
                    ),
                    TextButton(
                      onPressed: () => showAppSheet<void>(
                        context: context,
                        builder: (_) => _QuickManageSheet(initial: data.quick),
                      ),
                      child: Text(l10n.dashboard_manageQuick),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
                Wrap(
                  spacing: AppTokens.s8,
                  runSpacing: AppTokens.s8,
                  children: [
                    for (final item in data.quick.where(
                      (item) => item['isShow'] == true,
                    ))
                      Chip(
                        label: Text('${item['title'] ?? item['name'] ?? ''}'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.dashboard_launcher,
                        style: AppTextStyles.titleM,
                      ),
                    ),
                    TextButton(
                      onPressed: () => showAppSheet<void>(
                        context: context,
                        builder: (_) => const _LauncherManageSheet(),
                      ),
                      child: Text(l10n.dashboard_manageLauncher),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
                if (data.launcher.isEmpty)
                  Text(
                    l10n.dashboard_noData,
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final item in data.launcher.take(6))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTokens.s8),
                      child: Row(
                        children: [
                          const Icon(TablerIcons.apps),
                          const SizedBox(width: AppTokens.s8),
                          Expanded(
                            child: Text(
                              '${item['name'] ?? item['key'] ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item['isInstall'] == true
                                ? l10n.dashboard_appInstalled
                                : l10n.dashboard_appNotInstalled,
                            style: AppTextStyles.caption.copyWith(
                              color: item['isInstall'] == true
                                  ? context.appColors.success
                                  : context.scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dashboard_nodeInfo, style: AppTextStyles.titleM),
                const SizedBox(height: AppTokens.s8),
                Wrap(
                  spacing: AppTokens.s16,
                  runSpacing: AppTokens.s8,
                  children: [
                    Text(
                      'Load1 ${_num(data.node, 'load1').toStringAsFixed(2)}',
                    ),
                    Text(
                      'Load5 ${_num(data.node, 'load5').toStringAsFixed(2)}',
                    ),
                    Text(
                      'Load15 ${_num(data.node, 'load15').toStringAsFixed(2)}',
                    ),
                    Text(
                      'CPU ${_num(data.node, 'cpuUsedPercent').toStringAsFixed(1)}%',
                    ),
                    Text(
                      'MEM ${_num(data.node, 'memoryUsedPercent').toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          _TopProcessCard(title: l10n.dashboard_topCpu, processes: data.topCpu),
          const SizedBox(height: AppTokens.s12),
          _TopProcessCard(title: l10n.dashboard_topMem, processes: data.topMem),
        ],
      ),
    );
  }
}

class _TopProcessCard extends StatelessWidget {
  const _TopProcessCard({required this.title, required this.processes});

  final String title;
  final List<Map<String, dynamic>> processes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleM),
          const SizedBox(height: AppTokens.s8),
          if (processes.isEmpty)
            Text(
              l10n.dashboard_noData,
              style: AppTextStyles.caption.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            )
          else
            for (final item in processes.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.s8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item['name'] ?? item['cmd'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item['pid'] ?? ''}',
                      style: AppTextStyles.caption.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    Text(
                      '${(item['percent'] as num?)?.toStringAsFixed(1) ?? '0'}%',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _QuickManageSheet extends ConsumerStatefulWidget {
  const _QuickManageSheet({required this.initial});

  final List<Map<String, dynamic>> initial;

  @override
  ConsumerState<_QuickManageSheet> createState() => _QuickManageSheetState();
}

class _QuickManageSheetState extends ConsumerState<_QuickManageSheet> {
  late final List<Map<String, dynamic>> _quicks = widget.initial
      .map(Map<String, dynamic>.from)
      .toList(growable: false);
  List<Map<String, dynamic>> _directories = const [];

  @override
  void initState() {
    super.initState();
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    try {
      final repository = await ref.read(dashboardRepositoryProvider.future);
      final items = await repository.getQuickDirectories();
      if (!mounted) return;
      setState(() => _directories = items);
    } catch (_) {
      // Directories are optional on older panels.
    }
  }

  Future<void> _saveQuicks() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(dashboardRepositoryProvider.future);
      await repository.changeQuick([
        for (final item in _quicks)
          {'id': item['id'], 'isShow': item['isShow'] == true},
      ]);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _editDirectory([Map<String, dynamic>? directory]) async {
    final l10n = AppLocalizations.of(context);
    final path = TextEditingController(text: '${directory?['path'] ?? ''}');
    final alias = TextEditingController(text: '${directory?['alias'] ?? ''}');
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: directory == null
              ? l10n.dashboard_addQuickDirectory
              : l10n.dashboard_editQuickDirectory,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(
              controller: path,
              label: l10n.dashboard_quickDirectoryPath,
            ),
            const SizedBox(height: AppTokens.s12),
            AppTextField(
              controller: alias,
              label: l10n.dashboard_quickDirectoryAlias,
            ),
          ],
        ),
      ),
    );
    final pathValue = path.text.trim();
    final aliasValue = alias.text.trim();
    path.dispose();
    alias.dispose();
    if (saved != true || pathValue.isEmpty || !mounted) return;
    try {
      final repository = await ref.read(dashboardRepositoryProvider.future);
      if (directory == null) {
        await repository.createQuickDirectory(
          path: pathValue,
          alias: aliasValue,
        );
      } else {
        await repository.updateQuickDirectory(
          id: (directory['id'] as num?)?.toInt() ?? 0,
          path: pathValue,
          alias: aliasValue,
          legacy: directory['legacy'] == true,
        );
      }
      await _loadDirectories();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _deleteDirectory(Map<String, dynamic> directory) async {
    try {
      final repository = await ref.read(dashboardRepositoryProvider.future);
      await repository.deleteQuickDirectory(
        id: (directory['id'] as num?)?.toInt() ?? 0,
        legacy: directory['legacy'] == true,
      );
      await _loadDirectories();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dashboard_manageQuick, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s12),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final item in _quicks)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${item['title'] ?? item['name'] ?? ''}'),
                  subtitle: Text('${item['detail'] ?? ''}'),
                  value: item['isShow'] == true,
                  onChanged: (value) => setState(() => item['isShow'] = value),
                ),
              const SizedBox(height: AppTokens.s12),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: l10n.action_save,
                  onPressed: _saveQuicks,
                ),
              ),
              const SizedBox(height: AppTokens.s16),
              SectionHeader(
                title: l10n.dashboard_quickDirectories,
                trailing: TextButton(
                  onPressed: _editDirectory,
                  child: Text(l10n.action_add),
                ),
              ),
              if (_directories.isEmpty)
                EmptyState(
                  icon: TablerIcons.folder,
                  title: l10n.dashboard_quickDirectories,
                  compact: true,
                )
              else
                SplitListGroup(
                  children: [
                    for (final directory in _directories)
                      SplitListTile(
                        leading: const Icon(TablerIcons.folder),
                        title:
                            '${directory['alias'] ?? directory['path'] ?? ''}',
                        subtitle: '${directory['path'] ?? ''}',
                        onTap: () => _editDirectory(directory),
                        trailing: IconButton(
                          tooltip: l10n.action_delete,
                          icon: const Icon(TablerIcons.trash),
                          onPressed: () => _deleteDirectory(directory),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LauncherManageSheet extends ConsumerStatefulWidget {
  const _LauncherManageSheet();

  @override
  ConsumerState<_LauncherManageSheet> createState() =>
      _LauncherManageSheetState();
}

class _LauncherManageSheetState extends ConsumerState<_LauncherManageSheet> {
  List<Map<String, dynamic>> _options = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repository = await ref.read(dashboardRepositoryProvider.future);
      final items = await repository.getAppLauncherOptions();
      if (!mounted) return;
      setState(() => _options = items);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _toggle(Map<String, dynamic> item, bool show) async {
    try {
      final repository = await ref.read(dashboardRepositoryProvider.future);
      await repository.updateAppLauncherShow(
        key: '${item['key'] ?? ''}',
        show: show,
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dashboard_manageLauncher, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s12),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final item in _options)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${item['key'] ?? ''}'),
                  value: item['isShow'] == true,
                  onChanged: (value) => _toggle(item, value),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

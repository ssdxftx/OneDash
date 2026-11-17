import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/back_to_servers_button.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/app_toast.dart';
import '../../../../data/repositories_impl/dashboard_repository_impl.dart';
import '../../../../data/repositories_impl/host_repository_impl.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_mapper.dart';
import '../../../common/states/error_state.dart';
import '../../../common/states/error_toast.dart';
import '../../app_store/screens/installed_app_page.dart';
import '../../app_store/widgets/installed_app_card.dart';
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
                leading: const BackToServersButton(),
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
    required this.launcher,
    required this.topCpu,
    required this.topMem,
    required this.node,
  });

  final List<Map<String, dynamic>> launcher;
  final List<Map<String, dynamic>> topCpu;
  final List<Map<String, dynamic>> topMem;
  final Map<String, dynamic> node;
}

final _dashboardExtrasProvider = FutureProvider.autoDispose
    .family<_DashboardExtrasData, int>((ref, serverId) async {
      final repository = await ref.watch(dashboardRepositoryProvider.future);
      final results = await Future.wait<Object>([
        repository.getAppLauncher(),
        repository.getTopCpu(),
        repository.getTopMem(),
        repository.getNodeCurrent(),
      ]);
      return _DashboardExtrasData(
        launcher: results[0] as List<Map<String, dynamic>>,
        topCpu: results[1] as List<Map<String, dynamic>>,
        topMem: results[2] as List<Map<String, dynamic>>,
        node: results[3] as Map<String, dynamic>,
      );
    }, name: 'dashboardExtrasProvider');

class _DashboardExtrasSection extends ConsumerWidget {
  const _DashboardExtrasSection({required this.serverId});

  final int serverId;

  Map<String, dynamic>? _firstDetail(Map<String, dynamic> item) {
    final raw = item['detail'];
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return Map<String, dynamic>.from(raw.first as Map);
    }
    return null;
  }

  String? _launcherStatus(Map<String, dynamic> item) {
    if (item['isInstall'] != true) return null;
    return _firstDetail(item)?['status']?.toString();
  }

  String _launcherSubtitle(Map<String, dynamic> item, AppLocalizations l10n) {
    if (item['isInstall'] != true) {
      final description = '${item['description'] ?? ''}'.trim();
      return description.isEmpty ? l10n.dashboard_appNotInstalled : description;
    }
    final detail = _firstDetail(item);
    final version = '${detail?['version'] ?? ''}'.trim();
    if (version.isEmpty) return l10n.dashboard_appNotInstalled;
    final port = detail?['httpPort'];
    return port is num && port > 0 ? '$version · $port' : version;
  }

  void _openLauncher(BuildContext context, Map<String, dynamic> item) {
    final detail = _firstDetail(item);
    final installId = (detail?['installID'] as num?)?.toInt() ?? 0;
    if (item['isInstall'] == true && installId > 0) {
      showInstalledAppSheet(
        context,
        serverId: serverId,
        installId: '$installId',
        detailId: (detail?['detailID'] as num?)?.toInt(),
      );
      return;
    }
    context.push('/s/$serverId/more/apps');
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTokens.s12),
          SectionHeader(
            title: l10n.dashboard_launcher,
            trailing: TextButton(
              onPressed: () => showAppSheet<void>(
                context: context,
                builder: (_) => const _LauncherManageSheet(),
              ),
              child: Text(l10n.dashboard_manageLauncher),
            ),
          ),
          if (data.launcher.isEmpty)
            Text(
              l10n.dashboard_noData,
              style: AppTextStyles.caption.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            )
          else
            for (final item in data.launcher.take(6)) ...[
              InstalledAppCard(
                name: '${item['name'] ?? item['key'] ?? ''}',
                icon: item['icon'] as String?,
                status: _launcherStatus(item),
                subtitle: _launcherSubtitle(item, l10n),
                onTap: () => _openLauncher(context, item),
              ),
              const SizedBox(height: AppTokens.s8),
            ],
          const SizedBox(height: AppTokens.s12),
          NodeInfoCard(node: data.node),
          const SizedBox(height: AppTokens.s12),
          _TopProcessCard(
            title: l10n.dashboard_topCpu,
            processes: data.topCpu,
            icon: TablerIcons.cpu,
            accent: context.appColors.chart1,
          ),
          const SizedBox(height: AppTokens.s12),
          _TopProcessCard(
            title: l10n.dashboard_topMem,
            processes: data.topMem,
            icon: TablerIcons.device_sd_card,
            accent: context.appColors.chart3,
            showMemory: true,
          ),
        ],
      ),
    );
  }
}

class _TopProcessCard extends StatelessWidget {
  const _TopProcessCard({
    required this.title,
    required this.processes,
    required this.icon,
    required this.accent,
    this.showMemory = false,
  });

  final String title;
  final List<Map<String, dynamic>> processes;
  final IconData icon;
  final Color accent;
  final bool showMemory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final items = processes.take(5).toList(growable: false);
    return SizedBox(
      width: double.infinity,
      child: TonalCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                AppTokens.s12,
                AppTokens.s16,
                AppTokens.s4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: AppTokens.iconInline,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleS.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  if (items.isNotEmpty)
                    Text(
                      'TOP ${items.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s16,
                  AppTokens.s8,
                  AppTokens.s16,
                  AppTokens.s16,
                ),
                child: Text(
                  l10n.dashboard_noData,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                _ProcessRankRow(
                  index: index,
                  item: items[index],
                  accent: accent,
                  showMemory: showMemory,
                ),
                if (index < items.length - 1)
                  Divider(height: 1, indent: 56, color: scheme.outlineVariant),
              ],
            if (items.isNotEmpty) const SizedBox(height: AppTokens.s8),
          ],
        ),
      ),
    );
  }
}

class _ProcessRankRow extends StatelessWidget {
  const _ProcessRankRow({
    required this.index,
    required this.item,
    required this.accent,
    required this.showMemory,
  });

  final int index;
  final Map<String, dynamic> item;
  final Color accent;
  final bool showMemory;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final name = '${item['name'] ?? item['cmd'] ?? ''}'.trim();
    final pid = '${item['pid'] ?? ''}';
    final user = '${item['user'] ?? ''}'.trim();
    final percent = (item['percent'] as num?)?.toDouble() ?? 0;
    final memory = (item['memory'] as num?)?.toInt() ?? 0;
    final ratio = (percent / 100).clamp(0.0, 1.0);
    final primary = showMemory && memory > 0
        ? formatBytes(memory)
        : '${percent.toStringAsFixed(1)}%';
    final secondary = showMemory && memory > 0
        ? '${percent.toStringAsFixed(1)}%'
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s16,
        AppTokens.s8,
        AppTokens.s16,
        AppTokens.s8,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: AppTextStyles.caption.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? pid : name,
                  style: AppTextStyles.bodyM.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.isEmpty ? 'PID $pid' : 'PID $pid · $user',
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.s12),
          SizedBox(
            width: 76,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  primary,
                  style: AppTextStyles.bodyS.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondary != null)
                  Text(
                    secondary,
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        color: accent.withValues(alpha: 0.12),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio,
                        child: Container(height: 4, color: accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

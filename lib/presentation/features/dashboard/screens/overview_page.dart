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
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/states/error_mapper.dart';
import '../../../common/states/error_state.dart';
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

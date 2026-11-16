import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/container_info_dto.dart';
import '../../../../data/dto/container/container_stats_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/log_view.dart';
import '../../../common/components/metric_card.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/formatters/value_labels.dart';

final _containerInfoProvider = FutureProvider.autoDispose
    .family<ContainerInfoDto, String>((ref, name) {
      return ref
          .watch(containerRepositoryProvider.future)
          .then((repository) => repository.getContainerInfo(name));
    });

class ContainerDetailPage extends ConsumerStatefulWidget {
  const ContainerDetailPage({
    super.key,
    required this.serverId,
    required this.containerName,
    this.embedded = false,
  });

  final int serverId;
  final String containerName;
  final bool embedded;

  @override
  ConsumerState<ContainerDetailPage> createState() =>
      _ContainerDetailPageState();
}

class _ContainerDetailPageState extends ConsumerState<ContainerDetailPage>
    with WidgetsBindingObserver {
  final LogBuffer _logBuffer = LogBuffer();
  Timer? _timer;
  bool _paused = false;
  bool _fetching = false;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = null;
    if (_tabIndex != 1 || _paused) return;
    _timer = Timer.periodic(AppTokens.logFollowPoll, (_) => _fetchLogs());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _setPaused(bool value) {
    _paused = value;
    if (value) {
      _stopTimer();
    } else {
      _startTimer();
      if (_tabIndex == 1) _fetchLogs();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
      if (_tabIndex == 1 && !_paused) _fetchLogs();
    } else {
      _stopTimer();
    }
  }

  Future<void> _fetchLogs() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final log = await repository.getContainerLog(
        containerName: widget.containerName,
        since: '1h',
        tail: '300',
        follow: false,
        timestamp: true,
      );
      if (!mounted) return;
      final incoming = log
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList(growable: false);
      if (listEquals(_logBuffer.lines, incoming)) return;
      final current = _logBuffer.lines;
      final isAppend =
          incoming.length >= current.length &&
          listEquals(incoming.sublist(0, current.length), current);
      if (isAppend) {
        _logBuffer.addAll(incoming.sublist(current.length));
      } else {
        _logBuffer.replaceAll(incoming);
      }
      setState(() {});
    } catch (_) {
      // 日志轮询失败静默，等待下一次。
    } finally {
      _fetching = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(_containerInfoProvider(widget.containerName));
    final body = SegmentedTabsView(
      scrollable: !widget.embedded,
      labels: [l10n.nav_overview, l10n.containers_logs, l10n.containers_config],
      onChanged: (index) {
        if (index == _tabIndex) return;
        setState(() => _tabIndex = index);
        if (index == 1) {
          _startTimer();
          _fetchLogs();
        } else {
          _stopTimer();
        }
      },
      children: [
        _OverviewTab(
          containerName: widget.containerName,
          active: _tabIndex == 0,
        ),
        LogView(
          lines: _logBuffer.lines,
          paused: _paused,
          onPauseChanged: (value) => setState(() => _setPaused(value)),
          onClear: () => setState(_logBuffer.clear),
        ),
        _ConfigTab(containerName: widget.containerName),
      ],
    );
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(
            title: widget.containerName,
            subtitle: info.valueOrNull?.image,
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppTokens.s8),
          Expanded(child: body),
        ],
      );
    }
    return Scaffold(
      appBar: AppBarLarge(
        title: widget.containerName,
        subtitle: info.valueOrNull?.image,
        actions: [
          AppIconButton(
            icon: TablerIcons.terminal_2,
            tooltip: l10n.containers_terminal,
            onPressed: () => context.push(
              '/s/${widget.serverId}/terminal?container=${Uri.encodeComponent(widget.containerName)}',
            ),
          ),
        ],
      ),
      body: body,
    );
  }
}

Future<void> showContainerDetailSheet(
  BuildContext context, {
  required int serverId,
  required String containerName,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.94,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.82,
      child: ContainerDetailPage(
        serverId: serverId,
        containerName: containerName,
        embedded: true,
      ),
    ),
  );
}

class _OverviewTab extends ConsumerStatefulWidget {
  const _OverviewTab({required this.containerName, required this.active});

  final String containerName;
  final bool active;

  @override
  ConsumerState<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<_OverviewTab>
    with WidgetsBindingObserver {
  ContainerStatsDto? _stats;
  Timer? _timer;
  bool _inFlight = false;
  bool _appActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.active) {
      _load();
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant _OverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active == widget.active) return;
    if (widget.active) {
      _load();
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    _stopTimer();
    if (!_appActive) return;
    _timer = Timer.periodic(AppTokens.containerStatsPoll, (_) => _load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    if (_appActive && widget.active) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _load() async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final stats = await repository.getContainerStats(widget.containerName);
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (_) {
      // 监控失败保留上一帧数据。
    } finally {
      _inFlight = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(_containerInfoProvider(widget.containerName));
    final stats = _stats;
    return AsyncStateView(
      value: info,
      onRetry: () =>
          ref.invalidate(_containerInfoProvider(widget.containerName)),
      builder: (data) => ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          TonalCard(
            child: Row(
              children: [
                const Icon(TablerIcons.box, size: AppTokens.iconList),
                const SizedBox(width: AppTokens.s8),
                Expanded(
                  child: Text(
                    data.name,
                    style: AppTextStyles.titleM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppTokens.s8),
                Flexible(
                  child: Text(
                    data.image,
                    style: AppTextStyles.bodyS.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          Row(
            children: [
              Expanded(
                child: TonalCard(
                  child: Column(
                    children: [
                      Text(l10n.dashboard_cpu, style: AppTextStyles.bodyS),
                      const SizedBox(height: AppTokens.s8),
                      MetricRing(
                        value: stats?.cpuPercent ?? 0,
                        label: l10n.dashboard_cpu,
                        size: 72,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: TonalCard(
                  child: Column(
                    children: [
                      Text(l10n.dashboard_memory, style: AppTextStyles.bodyS),
                      const SizedBox(height: AppTokens.s8),
                      MetricRing(
                        value: stats == null
                            ? 0
                            : (stats.memory /
                                      (stats.memory + stats.cache + 1) *
                                      100)
                                  .clamp(0, 100)
                                  .toDouble(),
                        label: l10n.dashboard_memory,
                        size: 72,
                      ),
                      Text(
                        stats == null
                            ? displayValue(context, null)
                            : formatBytes(stats.memory * 1024 * 1024),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          SplitListGroup(
            children: [
              if (data.image.trim().isNotEmpty)
                SplitListTile(title: l10n.containers_images, value: data.image),
              if (data.hostname.trim().isNotEmpty)
                SplitListTile(
                  title: l10n.containers_hostname,
                  value: data.hostname,
                ),
              if (data.restartPolicy.trim().isNotEmpty)
                SplitListTile(
                  title: l10n.containers_restartPolicy,
                  value: data.restartPolicy,
                ),
              if (data.workingDir.trim().isNotEmpty)
                SplitListTile(
                  title: l10n.containers_workingDir,
                  value: data.workingDir,
                ),
              if (data.volumes.isNotEmpty)
                SplitListTile(
                  title: l10n.containers_mountedVolumes,
                  subtitle: data.volumes.map((v) => v.sourceDir).join('\n'),
                  subtitleMaxLines: null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfigTab extends ConsumerWidget {
  const _ConfigTab({required this.containerName});

  final String containerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(_containerInfoProvider(containerName));
    return AsyncStateView(
      value: info,
      onRetry: () => ref.invalidate(_containerInfoProvider(containerName)),
      builder: (data) => ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          SplitListGroup(
            children: [
              if (data.env.isNotEmpty)
                SplitListTile(
                  title: l10n.containers_envVars,
                  subtitle: data.env.join('\n'),
                  subtitleMaxLines: null,
                  subtitleStyle: AppTextStyles.bodyM.copyWith(
                    fontFamily: 'monospace',
                    color: context.scheme.onSurface,
                  ),
                ),
              if (data.cmd != null && data.cmd!.isNotEmpty)
                SplitListTile(
                  title: l10n.containers_command,
                  subtitle: data.cmd!.join(' '),
                  subtitleMaxLines: null,
                  subtitleStyle: AppTextStyles.bodyM.copyWith(
                    fontFamily: 'monospace',
                    color: context.scheme.onSurface,
                  ),
                ),
              if (data.entrypoint != null && data.entrypoint!.isNotEmpty)
                SplitListTile(
                  title: l10n.containers_entrypoint,
                  subtitle: data.entrypoint!.join(' '),
                  subtitleMaxLines: null,
                  subtitleStyle: AppTextStyles.bodyM.copyWith(
                    fontFamily: 'monospace',
                    color: context.scheme.onSurface,
                  ),
                ),
              if (data.networks.isNotEmpty)
                SplitListTile(
                  title: l10n.nav_network,
                  subtitle: data.networks.map((n) => n.network).join(', '),
                ),
              SplitListTile(
                title: l10n.containers_memory,
                subtitle: data.memory == 0
                    ? l10n.containers_unlimited
                    : formatBytes(data.memory),
              ),
              SplitListTile(
                title: l10n.containers_privilegedMode,
                subtitle: data.privileged ? l10n.common_yes : l10n.common_no,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

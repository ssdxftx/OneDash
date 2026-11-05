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
import '../../../common/components/log_view.dart';
import '../../../common/components/metric_card.dart';
import '../../../common/components/segmented_tabs.dart';
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

final _containerStatsProvider = FutureProvider.autoDispose
    .family<ContainerStatsDto, String>((ref, name) {
      return ref
          .watch(containerRepositoryProvider.future)
          .then((repository) => repository.getContainerStats(name));
    });

class ContainerDetailPage extends ConsumerStatefulWidget {
  const ContainerDetailPage({
    super.key,
    required this.serverId,
    required this.containerName,
  });

  final int serverId;
  final String containerName;

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
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_tabIndex == 1 && !_paused) _fetchLogs();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
      if (_tabIndex == 1 && !_paused) _fetchLogs();
    } else {
      _timer?.cancel();
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(_containerInfoProvider(widget.containerName));
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
      body: SegmentedTabsView(
        labels: [
          l10n.nav_overview,
          l10n.containers_logs,
          l10n.containers_config,
        ],
        onChanged: (index) {
          if (index == 1 && _tabIndex != 1) {
            _tabIndex = index;
            _fetchLogs();
            return;
          }
          _tabIndex = index;
        },
        children: [
          _OverviewTab(containerName: widget.containerName),
          LogView(
            lines: _logBuffer.lines,
            paused: _paused,
            onPauseChanged: (value) => setState(() => _paused = value),
            onClear: () => setState(_logBuffer.clear),
          ),
          _ConfigTab(containerName: widget.containerName),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.containerName});

  final String containerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(_containerInfoProvider(containerName));
    final stats = ref.watch(_containerStatsProvider(containerName));
    return AsyncStateView(
      value: info,
      onRetry: () => ref.invalidate(_containerInfoProvider(containerName)),
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
                        value: stats.valueOrNull?.cpuPercent ?? 0,
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
                        value: stats.valueOrNull == null
                            ? 0
                            : (stats.value!.memory /
                                      (stats.value!.memory +
                                          stats.value!.cache +
                                          1) *
                                      100)
                                  .clamp(0, 100)
                                  .toDouble(),
                        label: l10n.dashboard_memory,
                        size: 72,
                      ),
                      Text(
                        stats.valueOrNull == null
                            ? displayValue(context, null)
                            : formatBytes(stats.value!.memory),
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

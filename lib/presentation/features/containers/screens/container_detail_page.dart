import 'dart:async';

import 'package:flutter/material.dart';
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
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';

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

class _ContainerDetailPageState extends ConsumerState<ContainerDetailPage> {
  final LogBuffer _logBuffer = LogBuffer();
  Timer? _timer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_paused) _fetchLogs();
    });
  }

  Future<void> _fetchLogs() async {
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
      final lines = log.split('\n');
      _logBuffer.clear();
      _logBuffer.addAll(lines);
      setState(() {});
    } catch (_) {
      // 日志轮询失败静默，等待下一次。
    }
  }

  @override
  void dispose() {
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
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          TonalCard(
            child: Row(
              children: [
                const StatusDot(status: 'running'),
                const SizedBox(width: AppTokens.s8),
                Expanded(child: Text(data.name, style: AppTextStyles.titleM)),
                Text(data.image, style: AppTextStyles.bodyS),
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
                            ? '-'
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
              SplitListTile(title: 'Image', subtitle: data.image),
              SplitListTile(title: 'Hostname', subtitle: data.hostname),
              SplitListTile(
                title: 'Restart policy',
                subtitle: data.restartPolicy,
              ),
              SplitListTile(title: 'Working dir', subtitle: data.workingDir),
              if (data.volumes.isNotEmpty)
                SplitListTile(
                  title: 'Volumes',
                  subtitle: data.volumes.map((v) => v.sourceDir).join('\n'),
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
    final info = ref.watch(_containerInfoProvider(containerName));
    return AsyncStateView(
      value: info,
      onRetry: () => ref.invalidate(_containerInfoProvider(containerName)),
      builder: (data) => ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          SplitListGroup(
            children: [
              SplitListTile(
                title: 'Environment',
                subtitle: data.env.isEmpty ? '-' : data.env.join('\n'),
              ),
              SplitListTile(
                title: 'Command',
                subtitle: data.cmd?.join(' ') ?? '-',
              ),
              SplitListTile(
                title: 'Entrypoint',
                subtitle: data.entrypoint?.join(' ') ?? '-',
              ),
              SplitListTile(
                title: 'Network',
                subtitle: data.networks.map((n) => n.network).join(', '),
              ),
              SplitListTile(
                title: 'Memory',
                subtitle: data.memory == 0
                    ? 'unlimited'
                    : formatBytes(data.memory),
              ),
              SplitListTile(
                title: 'Privileged',
                subtitle: data.privileged ? 'yes' : 'no',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

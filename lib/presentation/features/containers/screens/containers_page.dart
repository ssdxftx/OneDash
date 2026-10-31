import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/container_search_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../servers/providers/servers_provider.dart';
import '../providers/containers_provider.dart';
import '../../../common/states/error_toast.dart';

class ContainersPage extends ConsumerStatefulWidget {
  const ContainersPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<ContainersPage> createState() => _ContainersPageState();
}

class _ContainersPageState extends ConsumerState<ContainersPage> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String _filter = 'all';

  static const _filters = ['all', 'running', 'stopped', 'abnormal'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _label(String value, AppLocalizations l10n) {
    return switch (value) {
      'running' => l10n.containers_running,
      'stopped' => l10n.containers_stopped,
      'abnormal' => l10n.containers_abnormal,
      _ => l10n.containers_all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final server = ref.watch(serverByIdProvider(widget.serverId)).valueOrNull;
    final containers = ref.watch(containersProvider);
    final total = containers.valueOrNull?.items.length;
    final docker = ref.watch(dockerStatusProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppBarLarge(
              title: l10n.containers_title,
              subtitle: [
                if (server != null) server.displayName,
                if (total != null) l10n.containers_count(total),
              ].join(' · '),
              onTitleLongPress: () => showServerSwitcher(
                context,
                ref,
                currentServerId: widget.serverId,
              ),
              actions: [
                AppIconButton(
                  icon: _searching ? TablerIcons.x : TablerIcons.search,
                  tooltip: l10n.action_search,
                  onPressed: () {
                    setState(() => _searching = !_searching);
                    if (!_searching) {
                      _searchController.clear();
                      ref.read(containersProvider.notifier).search('');
                    }
                  },
                ),
                AppIconButton(
                  icon: TablerIcons.refresh,
                  tooltip: l10n.action_refresh,
                  onPressed: () =>
                      ref.read(containersProvider.notifier).refresh(),
                ),
              ],
            ),
            if (_searching)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s16,
                  vertical: AppTokens.s8,
                ),
                child: SearchField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) =>
                      ref.read(containersProvider.notifier).search(value),
                ),
              ),
            if (docker.valueOrNull != null && !docker.value!.isAvailable)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
                padding: const EdgeInsets.all(AppTokens.s12),
                decoration: BoxDecoration(
                  color: context.appColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.rMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      TablerIcons.alert_triangle,
                      size: AppTokens.iconList,
                      color: context.appColors.warning,
                    ),
                    const SizedBox(width: AppTokens.s8),
                    Expanded(
                      child: Text(
                        l10n.containers_dockerNotRunningShort,
                        style: AppTextStyles.bodyS.copyWith(
                          color: context.appColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            AppFilterChips<String>(
              options: _filters,
              labelOf: (value) => _label(value, l10n),
              selected: {_filter},
              onChanged: (selection) {
                if (selection.isEmpty) return;
                setState(() => _filter = selection.first);
                ref.read(containersProvider.notifier).setFilter(_filter);
              },
            ),
            Expanded(
              child: AsyncStateView(
                value: containers,
                onRetry: () => ref.read(containersProvider.notifier).refresh(),
                loading: const SkeletonList(itemCount: 8, itemHeight: 60),
                isEmpty: (state) => state.items.isEmpty,
                empty: EmptyState(
                  icon: TablerIcons.box,
                  title: l10n.containers_empty_title,
                  message: l10n.containers_empty_message,
                ),
                builder: (state) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(containersProvider.notifier).refresh(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppTokens.s16,
                      AppTokens.s8,
                      AppTokens.s16,
                      AppTokens.s32,
                    ),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      final stats = state.stats[item.containerID];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTokens.s12),
                        child: _ContainerCard(
                          item: item,
                          cpu: stats?.cpuPercent,
                          memory: stats == null
                              ? null
                              : formatBytes(stats.memoryUsage.toInt()),
                          onTap: () => context.push(
                            '/s/${widget.serverId}/containers/${Uri.encodeComponent(item.name)}',
                          ),
                          onLongPress: () => _showActions(item),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showActions(ContainerItemDto item) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            item.imageName,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.player_play),
                title: l10n.containers_start,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _operate(item, 'start');
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.player_stop),
                title: l10n.containers_stop,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _operate(item, 'stop');
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.refresh),
                title: l10n.containers_restart,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _operate(item, 'restart');
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.terminal_2),
                title: l10n.containers_terminal,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(
                    '/s/${widget.serverId}/terminal?container=${Uri.encodeComponent(item.name)}',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  Future<void> _operate(ContainerItemDto item, String operation) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.operateContainer(
        names: [item.name],
        operation: operation,
        taskID: const Uuid().v4(),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      await ref.read(containersProvider.notifier).refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }
}

String _stateLabel(String state, AppLocalizations l10n) {
  return switch (state.toLowerCase()) {
    'running' => l10n.containers_running,
    'stopped' || 'exited' => l10n.containers_stopped,
    'paused' => l10n.containers_pause,
    _ => l10n.containers_abnormal,
  };
}

class _ContainerCard extends StatelessWidget {
  const _ContainerCard({
    required this.item,
    required this.cpu,
    required this.memory,
    required this.onTap,
    required this.onLongPress,
  });

  final ContainerItemDto item;
  final double? cpu;
  final String? memory;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusDot(status: item.state.toLowerCase()),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _stateLabel(item.state, l10n),
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppTokens.s4),
              Icon(
                TablerIcons.chevron_right,
                size: AppTokens.iconList,
                color: scheme.onSurfaceVariant,
              ),
              if (item.isFromCompose)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.s8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppTokens.rXs),
                  ),
                  child: Text(
                    l10n.containers_compose,
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s4),
          Text(
            item.imageName,
            style: AppTextStyles.bodyS.copyWith(
              color: scheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTokens.s8),
          Row(
            children: [
              Text(
                'CPU ${cpu == null ? '—' : '${cpu!.toStringAsFixed(1)}%'}',
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppTokens.s12),
              Text(
                'MEM ${memory ?? '—'}',
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (item.ports != null && item.ports!.isNotEmpty)
                Flexible(
                  child: Text(
                    item.ports!.join(', '),
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

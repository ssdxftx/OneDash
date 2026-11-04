import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/container_search_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/refreshable_empty_state.dart';
import '../../servers/providers/servers_provider.dart';
import '../providers/containers_provider.dart';
import '../widgets/container_actions.dart';

class ContainersPage extends ConsumerStatefulWidget {
  const ContainersPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<ContainersPage> createState() => _ContainersPageState();
}

class _ContainersPageState extends ConsumerState<ContainersPage> {
  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer();
  bool _searching = false;
  bool _selecting = false;
  String _filter = 'all';
  final Set<String> _selected = {};

  bool get _selectionMode => _selecting;

  void _toggle(String name) {
    setState(() {
      _selecting = true;
      if (!_selected.remove(name)) _selected.add(name);
    });
  }

  void _clearSelection() => setState(() {
    _selecting = false;
    _selected.clear();
  });

  Future<void> _batchDelete() async {
    final l10n = AppLocalizations.of(context);
    final names = _selected.toList(growable: false);
    if (names.isEmpty) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.containers_remove,
      message: l10n.files_selectCount(names.length),
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    final repository = await ref.read(containerRepositoryProvider.future);
    if (!mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: l10n.containers_remove,
      task: (controller) async {
        await repository.operateContainer(
          names: names,
          operation: 'remove',
          taskID: taskID,
        );
        await repository.waitForTask(
          taskID,
          onUpdate: (log) {
            if (log.lines.isNotEmpty) controller.log(log.lines.last);
          },
        );
      },
    );
    if (!success || !mounted) return;
    _clearSelection();
    AppToast.success(context, l10n.action_done);
    await ref.read(containersProvider.notifier).refresh();
  }

  static const _filters = ['all', 'running', 'stopped', 'abnormal'];

  @override
  void dispose() {
    _searchDebouncer.dispose();
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
                  icon: TablerIcons.refresh,
                  tooltip: l10n.action_refresh,
                  onPressed: () =>
                      ref.read(containersProvider.notifier).refresh(),
                ),
                AppIconButton(
                  icon: _searching ? TablerIcons.x : TablerIcons.search,
                  tooltip: l10n.action_search,
                  onPressed: () {
                    setState(() {
                      _searching = !_searching;
                      if (!_searching) {
                        _clearSelection();
                        _searchController.clear();
                        ref.read(containersProvider.notifier).search('');
                      }
                    });
                  },
                ),
                AppIconButton(
                  icon: TablerIcons.dots,
                  tooltip: l10n.action_more,
                  onPressed: () async {
                    final value = await showSelectionMenu<String>(
                      context,
                      options: [
                        SelectionOption(
                          label: _selectionMode
                              ? l10n.files_cancelSelection
                              : l10n.files_selectAll,
                          value: 'select',
                          icon: _selectionMode
                              ? TablerIcons.square_x
                              : TablerIcons.checkbox,
                        ),
                        SelectionOption(
                          label: l10n.containers_dockerSettings,
                          value: 'docker',
                          icon: TablerIcons.brand_docker,
                        ),
                        SelectionOption(
                          label: l10n.containers_resources,
                          value: 'resources',
                          icon: TablerIcons.chart_pie,
                        ),
                        SelectionOption(
                          label: l10n.containers_prune,
                          value: 'prune',
                          icon: TablerIcons.eraser,
                        ),
                      ],
                    );
                    if (!context.mounted || value == null) return;
                    if (value == 'select') {
                      setState(() {
                        if (_selectionMode) {
                          _clearSelection();
                        } else {
                          _selecting = true;
                          final items = ref
                              .read(containersProvider)
                              .valueOrNull
                              ?.items;
                          _selected.addAll(
                            (items ?? const [])
                                .where((item) => !item.isFromCompose)
                                .map((item) => item.name),
                          );
                        }
                      });
                    } else if (value == 'docker') {
                      await context.push(
                        '/s/${widget.serverId}/containers/docker',
                      );
                    } else if (value == 'resources') {
                      await context.push(
                        '/s/${widget.serverId}/containers/resources',
                      );
                    } else if (value == 'prune') {
                      await _prune();
                    }
                  },
                ),
                AppIconButton(
                  icon: TablerIcons.plus,
                  tooltip: l10n.containers_create,
                  onPressed: () =>
                      context.push('/s/${widget.serverId}/containers/create'),
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
                  onChanged: (value) {
                    _clearSelection();
                    _searchDebouncer(() {
                      ref.read(containersProvider.notifier).search(value);
                    }, delay: const Duration(milliseconds: 300));
                  },
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
                setState(() {
                  _filter = selection.first;
                  _clearSelection();
                });
                ref.read(containersProvider.notifier).setFilter(_filter);
              },
            ),
            Expanded(
              child: AsyncStateView(
                value: containers,
                onRetry: () => ref.read(containersProvider.notifier).refresh(),
                loading: const SkeletonList(itemCount: 8, itemHeight: 60),
                isEmpty: (state) => state.items.isEmpty,
                empty: RefreshableEmptyState(
                  onRefresh: () =>
                      ref.read(containersProvider.notifier).refresh(),
                  child: EmptyState(
                    icon: TablerIcons.box,
                    title: l10n.containers_empty_title,
                    message: l10n.containers_empty_message,
                    actionLabel: l10n.containers_create,
                    onAction: () =>
                        context.push('/s/${widget.serverId}/containers/create'),
                  ),
                ),
                builder: (state) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(containersProvider.notifier).refresh(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppTokens.pagePadding,
                      AppTokens.s8,
                      AppTokens.pagePadding,
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
                          selected: _selected.contains(item.name),
                          selectable: !item.isFromCompose,
                          selectionMode: _selectionMode,
                          onTap: _selectionMode
                              ? () {
                                  if (!item.isFromCompose) _toggle(item.name);
                                }
                              : () => _showActions(item),
                          onLongPress: () {
                            if (!item.isFromCompose) _toggle(item.name);
                          },
                          onToggle: () => _operateQuick(
                            item,
                            item.state.toLowerCase() == 'running'
                                ? 'stop'
                                : 'start',
                          ),
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
      bottomNavigationBar: _selectionMode
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
          : null,
    );
  }

  Future<void> _operateQuick(ContainerItemDto item, String operation) async {
    final l10n = AppLocalizations.of(context);
    final repository = await ref.read(containerRepositoryProvider.future);
    if (!mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: operation == 'start'
          ? l10n.containers_start
          : l10n.containers_stop,
      task: (controller) async {
        await repository.operateContainer(
          names: [item.name],
          operation: operation,
          taskID: taskID,
        );
        await repository.waitForTask(
          taskID,
          onUpdate: (log) {
            if (log.lines.isNotEmpty) controller.log(log.lines.last);
          },
        );
      },
    );
    if (!success || !mounted) return;
    AppToast.success(context, l10n.action_done);
    await ref.read(containersProvider.notifier).refresh();
  }

  Future<void> _showActions(ContainerItemDto item) async {
    await showContainerActionsPage(
      context,
      ref,
      serverId: widget.serverId,
      item: item,
      onChanged: () => ref.read(containersProvider.notifier).refresh(),
    );
  }

  Future<void> _prune() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.containers_prune,
      message: l10n.containers_pruneConfirm,
      confirmLabel: l10n.containers_prune,
    );
    if (!confirmed || !mounted) return;
    final repository = await ref.read(containerRepositoryProvider.future);
    if (!mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: l10n.containers_prune,
      task: (controller) async {
        await repository.pruneContainers(taskID: taskID);
        await repository.waitForTask(
          taskID,
          onUpdate: (log) {
            if (log.lines.isNotEmpty) controller.log(log.lines.last);
          },
        );
      },
    );
    if (!success || !mounted) return;
    AppToast.success(context, l10n.action_done);
    await ref.read(containersProvider.notifier).refresh();
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
    required this.selected,
    required this.selectable,
    required this.selectionMode,
    required this.onToggle,
  });

  final ContainerItemDto item;
  final double? cpu;
  final String? memory;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool selected;
  final bool selectable;
  final bool selectionMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (selectable && selectionMode)
                Checkbox(value: selected, onChanged: (_) => onTap()),
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
              if (!selectionMode) ...[
                const SizedBox(width: AppTokens.s4),
                IconButton(
                  tooltip: item.state.toLowerCase() == 'running'
                      ? l10n.containers_stop
                      : l10n.containers_start,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    item.state.toLowerCase() == 'running'
                        ? TablerIcons.player_pause
                        : TablerIcons.player_play,
                    size: AppTokens.iconList,
                  ),
                  onPressed: onToggle,
                ),
              ],
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

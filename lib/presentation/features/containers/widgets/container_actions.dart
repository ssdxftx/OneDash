import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/container_search_dto.dart';
import '../../../../data/dto/container/container_stats_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/action_sheet.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../screens/container_create_page.dart';
import '../screens/container_detail_page.dart';
import 'container_log_page.dart';

Future<void> showContainerActions(
  BuildContext context,
  WidgetRef ref, {
  required int serverId,
  required ContainerItemDto item,
  required Future<void> Function() onChanged,
  Future<void> Function(String name)? onRemoving,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.9,
    builder: (sheetContext) => _ContainerActionsBody(
      hostContext: context,
      ref: ref,
      serverId: serverId,
      item: item,
      onChanged: onChanged,
      onRemoving: onRemoving,
    ),
  );
}

class _ContainerActionsBody extends StatelessWidget {
  const _ContainerActionsBody({
    required this.hostContext,
    required this.ref,
    required this.serverId,
    required this.item,
    required this.onChanged,
    this.onRemoving,
  });

  final BuildContext hostContext;
  final WidgetRef ref;
  final int serverId;
  final ContainerItemDto item;
  final Future<void> Function() onChanged;
  final Future<void> Function(String name)? onRemoving;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = item.state.toLowerCase();
    final running = state == 'running';
    final paused = state == 'paused';
    final stopped =
        state == 'exited' || state == 'stopped' || state == 'created';
    final colors = context.appColors;
    final infoCard = ActionSheetInfoCard(
      leading: _ContainerGlyph(state: state),
      title: item.name,
      subtitle: item.imageName,
      trailing: ActionSheetStatusPill(
        label: _stateLabel(item.state, l10n),
        color: colors.status(state),
      ),
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActionSheetSection(
          title: l10n.containers_groupMaintenance,
          icon: TablerIcons.tool,
          children: [
            ActionSheetRow(
              icon: TablerIcons.terminal_2,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.containers_terminal,
              onTap: () {
                Navigator.of(context).pop();
                hostContext.push(
                  '/s/$serverId/terminal?container=${Uri.encodeComponent(item.name)}',
                );
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.file_text,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.containers_viewLogs,
              onTap: () {
                Navigator.of(context).pop();
                _showLogs(hostContext, ref, item.name);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.eraser,
              iconColor: colors.warning,
              title: l10n.containers_cleanLogs,
              onTap: () async {
                Navigator.of(context).pop();
                await _cleanLogs(hostContext, ref, item, onChanged);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.users,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.containers_users,
              onTap: () async {
                Navigator.of(context).pop();
                await _showUsers(hostContext, ref, item.name);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.activity,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.containers_liveMonitor,
              onTap: () {
                Navigator.of(context).pop();
                _showMonitor(hostContext, ref, item);
              },
            ),
          ],
        ),
        ActionSheetSection(
          title: l10n.containers_groupLifecycle,
          icon: TablerIcons.refresh,
          children: [
            ActionSheetRow(
              icon: TablerIcons.info_circle,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.error_details,
              onTap: () => showContainerDetailSheet(
                hostContext,
                serverId: serverId,
                containerName: item.name,
              ),
            ),
            ActionSheetRow(
              icon: TablerIcons.player_play,
              iconColor: colors.success,
              title: l10n.containers_start,
              enabled: stopped,
              onTap: () {
                Navigator.of(context).pop();
                _operate(hostContext, ref, item, 'start', onChanged);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.player_stop,
              iconColor: colors.warning,
              title: l10n.containers_stop,
              enabled: running || paused,
              onTap: () {
                Navigator.of(context).pop();
                _operate(hostContext, ref, item, 'stop', onChanged);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.refresh,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.containers_restart,
              enabled: running,
              onTap: () {
                Navigator.of(context).pop();
                _operate(hostContext, ref, item, 'restart', onChanged);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.player_pause,
              iconColor: colors.warning,
              title: l10n.containers_pause,
              enabled: running,
              onTap: () {
                Navigator.of(context).pop();
                _operate(hostContext, ref, item, 'pause', onChanged);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.player_play,
              iconColor: colors.success,
              title: l10n.containers_resume,
              enabled: paused,
              onTap: () {
                Navigator.of(context).pop();
                _operate(hostContext, ref, item, 'unpause', onChanged);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.hand_stop,
              iconColor: colors.danger,
              title: l10n.containers_kill,
              enabled: running || paused,
              onTap: () {
                Navigator.of(context).pop();
                _operate(hostContext, ref, item, 'kill', onChanged);
              },
            ),
          ],
        ),
        ActionSheetSection(
          title: l10n.containers_groupConfig,
          icon: TablerIcons.settings,
          children: [
            ActionSheetRow(
              icon: TablerIcons.edit,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.containers_edit,
              subtitle: l10n.containers_editSubtitle,
              onTap: () => showContainerEditSheet(
                hostContext,
                serverId: serverId,
                containerName: item.name,
              ),
            ),
            ActionSheetRow(
              icon: TablerIcons.arrow_up_circle,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.containers_upgrade,
              subtitle: l10n.containers_upgradeSubtitle,
              onTap: () {
                Navigator.of(context).pop();
                _upgrade(hostContext, ref, item, onChanged);
              },
            ),
            ActionSheetRow(
              icon: TablerIcons.camera,
              iconColor: context.scheme.onSurfaceVariant,
              title: l10n.containers_commit,
              subtitle: l10n.containers_commitSubtitle,
              onTap: () {
                Navigator.of(context).pop();
                _commit(hostContext, ref, item, onChanged);
              },
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
              title: l10n.containers_remove,
              subtitle: l10n.containers_removeSubtitle,
              danger: true,
              onTap: () {
                Navigator.of(context).pop();
                _remove(hostContext, ref, item, onChanged, onRemoving);
              },
            ),
          ],
        ),
      ],
    );
    return ActionSheetScaffold(infoCard: infoCard, child: content);
  }
}

Future<void> _operate(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto item,
  String operation,
  Future<void> Function() onChanged, {
  Future<void> Function()? beforeRefresh,
}) async {
  final l10n = AppLocalizations.of(context);
  final repository = await ref.read(containerRepositoryProvider.future);
  if (!context.mounted) return;
  final taskID = const Uuid().v4();
  final success = await TaskProgressSheet.run(
    context,
    title: _operationLabel(operation, l10n),
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
  if (!success || !context.mounted) return;
  AppToast.success(context, l10n.action_done);
  await beforeRefresh?.call();
  await onChanged();
}

Future<void> _remove(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto item,
  Future<void> Function() onChanged,
  Future<void> Function(String name)? onRemoving,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showConfirmSheet(
    context,
    title: l10n.containers_removeTitle,
    message: l10n.containers_removeMessage(item.name),
    confirmLabel: l10n.action_delete,
    requireText: item.name,
  );
  if (!confirmed || !context.mounted) return;
  await _operate(
    context,
    ref,
    item,
    'remove',
    onChanged,
    beforeRefresh: onRemoving == null ? null : () => onRemoving(item.name),
  );
}

Future<void> _upgrade(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto item,
  Future<void> Function() onChanged,
) async {
  final l10n = AppLocalizations.of(context);
  final options = await showAppSheet<_UpgradeOptions>(
    context: context,
    builder: (sheetContext) =>
        _UpgradeSheet(image: item.imageName, forcePull: false),
  );
  if (options == null || !context.mounted) return;
  final repository = await ref.read(containerRepositoryProvider.future);
  if (!context.mounted) return;
  final taskID = const Uuid().v4();
  final success = await TaskProgressSheet.run(
    context,
    title: l10n.containers_upgrade,
    task: (controller) async {
      await repository.upgradeContainer(
        taskID: taskID,
        names: [item.name],
        image: options.image,
        forcePull: options.forcePull,
      );
      await repository.waitForTask(
        taskID,
        onUpdate: (log) {
          if (log.lines.isNotEmpty) controller.log(log.lines.last);
        },
      );
    },
  );
  if (!success || !context.mounted) return;
  AppToast.success(context, l10n.action_done);
  await onChanged();
}

Future<void> _commit(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto item,
  Future<void> Function() onChanged,
) async {
  final l10n = AppLocalizations.of(context);
  final options = await showAppSheet<_CommitOptions>(
    context: context,
    builder: (sheetContext) => _CommitSheet(containerName: item.name),
  );
  if (options == null || !context.mounted) return;
  final repository = await ref.read(containerRepositoryProvider.future);
  if (!context.mounted) return;
  final taskID = const Uuid().v4();
  final success = await TaskProgressSheet.run(
    context,
    title: l10n.containers_commit,
    task: (controller) async {
      await repository.commitContainer(
        containerID: item.containerID,
        containerName: item.name,
        newImageName: options.imageName,
        comment: options.comment,
        author: options.author,
        pause: options.pause,
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
  if (!success || !context.mounted) return;
  AppToast.success(context, l10n.action_done);
  await onChanged();
}

Future<void> _cleanLogs(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto item,
  Future<void> Function() onChanged,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showConfirmSheet(
    context,
    title: l10n.containers_cleanLogs,
    message: l10n.containers_cleanLogsConfirm(item.name),
    confirmLabel: l10n.action_clear,
  );
  if (!confirmed || !context.mounted) return;
  try {
    final repository = await ref.read(containerRepositoryProvider.future);
    await repository.cleanContainerLog(containerName: item.name);
    if (!context.mounted) return;
    AppToast.success(context, l10n.action_done);
    await onChanged();
  } catch (error) {
    if (!context.mounted) return;
    showErrorToast(context, error);
  }
}

Future<void> _showLogs(
  BuildContext context,
  WidgetRef ref,
  String containerName,
) {
  return openContainerLogs(
    context,
    ref,
    containerName: containerName,
    subtitle: containerName,
  );
}

Future<void> _showUsers(
  BuildContext context,
  WidgetRef ref,
  String name,
) async {
  final l10n = AppLocalizations.of(context);
  try {
    final repository = await ref.read(containerRepositoryProvider.future);
    final users = await repository.loadContainerUsers(name);
    if (!context.mounted) return;
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.containers_users, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          if (users.isEmpty)
            EmptyState(
              compact: true,
              icon: TablerIcons.users,
              title: l10n.state_empty,
            )
          else
            SplitListGroup(
              children: [
                for (final user in users)
                  SplitListTile(
                    leading: const Icon(TablerIcons.user),
                    title: user,
                  ),
              ],
            ),
        ],
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    showErrorToast(context, error);
  }
}

Future<void> _showMonitor(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto item,
) {
  return showAppSheet<void>(
    context: context,
    builder: (sheetContext) =>
        _ContainerMonitorSheet(containerID: item.containerID, name: item.name),
  );
}

String _stateLabel(String state, AppLocalizations l10n) {
  return switch (state.toLowerCase()) {
    'running' => l10n.containers_running,
    'stopped' || 'exited' || 'created' => l10n.containers_stopped,
    'paused' => l10n.containers_pause,
    _ => l10n.containers_abnormal,
  };
}

String _operationLabel(String operation, AppLocalizations l10n) {
  return switch (operation) {
    'start' => l10n.containers_start,
    'stop' => l10n.containers_stop,
    'restart' => l10n.containers_restart,
    'pause' => l10n.containers_pause,
    'unpause' => l10n.containers_resume,
    'kill' => l10n.containers_kill,
    'remove' => l10n.containers_remove,
    _ => l10n.action_done,
  };
}

class _ContainerGlyph extends StatelessWidget {
  const _ContainerGlyph({required this.state});

  final String state;

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.status(state);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.rMd),
      ),
      child: Icon(TablerIcons.box, color: color, size: AppTokens.iconNav),
    );
  }
}

class _UpgradeOptions {
  const _UpgradeOptions({required this.image, required this.forcePull});

  final String image;
  final bool forcePull;
}

class _UpgradeSheet extends StatefulWidget {
  const _UpgradeSheet({required this.image, required this.forcePull});

  final String image;
  final bool forcePull;

  @override
  State<_UpgradeSheet> createState() => _UpgradeSheetState();
}

class _UpgradeSheetState extends State<_UpgradeSheet> {
  late final TextEditingController _image = TextEditingController(
    text: widget.image,
  );
  late bool _forcePull = widget.forcePull;

  @override
  void dispose() {
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.containers_upgrade, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        AppTextField(controller: _image, label: l10n.containers_image),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.containers_forcePull),
          value: _forcePull,
          onChanged: (value) => setState(() => _forcePull = value),
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.containers_upgrade,
          onPressed: () {
            final image = _image.text.trim();
            if (image.isEmpty) return;
            Navigator.of(
              context,
            ).pop(_UpgradeOptions(image: image, forcePull: _forcePull));
          },
        ),
      ],
    );
  }
}

class _CommitOptions {
  const _CommitOptions({
    required this.imageName,
    required this.comment,
    required this.author,
    required this.pause,
  });

  final String imageName;
  final String comment;
  final String author;
  final bool pause;
}

class _CommitSheet extends StatefulWidget {
  const _CommitSheet({required this.containerName});

  final String containerName;

  @override
  State<_CommitSheet> createState() => _CommitSheetState();
}

class _CommitSheetState extends State<_CommitSheet> {
  late final TextEditingController _image = TextEditingController(
    text: '${widget.containerName}:latest',
  );
  final _comment = TextEditingController();
  final _author = TextEditingController();
  bool _pause = true;

  @override
  void dispose() {
    _image.dispose();
    _comment.dispose();
    _author.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.containers_commit, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _image,
          label: l10n.containers_newImageName,
          hint: '${widget.containerName}:latest',
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _comment,
          label: l10n.containers_commitComment,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _author, label: l10n.containers_commitAuthor),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.containers_pauseDuringCommit),
          value: _pause,
          onChanged: (value) => setState(() => _pause = value),
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.containers_commit,
          onPressed: () {
            final image = _image.text.trim();
            if (image.isEmpty) return;
            Navigator.of(context).pop(
              _CommitOptions(
                imageName: image,
                comment: _comment.text.trim(),
                author: _author.text.trim(),
                pause: _pause,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ContainerMonitorSheet extends ConsumerStatefulWidget {
  const _ContainerMonitorSheet({required this.containerID, required this.name});

  final String containerID;
  final String name;

  @override
  ConsumerState<_ContainerMonitorSheet> createState() =>
      _ContainerMonitorSheetState();
}

class _ContainerMonitorSheetState extends ConsumerState<_ContainerMonitorSheet>
    with WidgetsBindingObserver {
  Timer? _timer;
  ContainerStatsDto? _stats;
  Object? _error;
  bool _loading = true;
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
      _load();
    } else {
      _timer?.cancel();
    }
  }

  Future<void> _load() async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final stats = await repository.getContainerStats(widget.containerID);
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    } finally {
      _inFlight = false;
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
    final stats = _stats;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.containers_liveMonitor, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s4),
        Text(
          widget.name,
          style: AppTextStyles.bodyS.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTokens.s24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Text(
            describeError(_error!, l10n),
            style: AppTextStyles.bodyM.copyWith(color: context.scheme.error),
          )
        else if (stats != null)
          SplitListGroup(
            children: [
              SplitListTile(
                title: l10n.dashboard_cpu,
                value: '${stats.cpuPercent.toStringAsFixed(1)}%',
              ),
              SplitListTile(
                title: l10n.dashboard_memory,
                value: formatBytes(stats.memory),
              ),
              SplitListTile(
                title: l10n.containers_cache,
                value: formatBytes(stats.cache),
              ),
              SplitListTile(
                title: l10n.containers_diskRead,
                value: formatBytes(stats.ioRead),
              ),
              SplitListTile(
                title: l10n.containers_diskWrite,
                value: formatBytes(stats.ioWrite),
              ),
              SplitListTile(
                title: l10n.containers_networkRX,
                value: formatBytes(stats.networkRX),
              ),
              SplitListTile(
                title: l10n.containers_networkTX,
                value: formatBytes(stats.networkTX),
              ),
            ],
          ),
      ],
    );
  }
}

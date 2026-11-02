import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/host_tool/supervisor_dto.dart';
import '../../../../data/repositories_impl/host_tool_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class SupervisorViewData {
  const SupervisorViewData({required this.status, required this.processes});

  final SupervisorToolStatus status;
  final List<SupervisorProcessConfig> processes;
}

final _supervisorProvider = FutureProvider.autoDispose<SupervisorViewData>((
  ref,
) async {
  final repository = await ref.watch(hostToolRepositoryProvider.future);
  final status = await repository.getSupervisorStatus();
  final processes = status.isReady
      ? await repository.getSupervisorProcesses()
      : const <SupervisorProcessConfig>[];
  return SupervisorViewData(status: status, processes: processes);
}, name: 'supervisorProvider');

class SupervisorPage extends ConsumerWidget {
  const SupervisorPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(_supervisorProvider);
    final ready = value.valueOrNull?.status.isReady ?? false;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.supervisor_title,
        actions: [
          if (ready)
            AppIconButton(
              icon: TablerIcons.file_settings,
              tooltip: l10n.supervisor_configFile,
              onPressed: () => _editConfig(context, ref),
            ),
          if (ready)
            AppIconButton(
              icon: TablerIcons.plus,
              tooltip: l10n.supervisor_createProcess,
              onPressed: () => _openForm(context, ref),
            ),
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_supervisorProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: value,
        onRetry: () => ref.invalidate(_supervisorProvider),
        loading: const SkeletonList(itemCount: 8),
        builder: (data) => _buildBody(context, ref, data),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SupervisorViewData data,
  ) {
    final l10n = AppLocalizations.of(context);
    final status = data.status;
    if (!status.isExist) {
      return EmptyState(
        icon: TablerIcons.server_off,
        title: l10n.supervisor_notInstalledTitle,
        message: l10n.supervisor_notInstalledSubtitle,
      );
    }
    if (!status.ctlExist) {
      return EmptyState(
        icon: TablerIcons.terminal_2,
        title: l10n.supervisor_ctlMissingTitle,
        message: l10n.supervisor_ctlMissingSubtitle,
        actionLabel: l10n.supervisor_initSupervisor,
        onAction: () => _openInit(context, ref, status),
      );
    }
    if (status.init) {
      return EmptyState(
        icon: TablerIcons.tool,
        title: l10n.supervisor_needInitTitle,
        message: l10n.supervisor_needInitSubtitle,
        actionLabel: l10n.supervisor_initSupervisor,
        onAction: () => _openInit(context, ref, status),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_supervisorProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusDot(status: status.isRunning ? 'running' : 'stopped'),
                    const SizedBox(width: AppTokens.s8),
                    Expanded(
                      child: Text(
                        status.isRunning
                            ? l10n.common_running
                            : l10n.common_stopped,
                        style: AppTextStyles.titleM,
                      ),
                    ),
                    Text(
                      status.version,
                      style: AppTextStyles.caption.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s12),
                Wrap(
                  spacing: AppTokens.s8,
                  runSpacing: AppTokens.s8,
                  children: [
                    if (status.isRunning)
                      SecondaryButton(
                        label: l10n.supervisor_serviceStop,
                        icon: TablerIcons.player_stop,
                        expanded: false,
                        onPressed: () =>
                            _operateService(context, ref, l10n, 'stop'),
                      )
                    else
                      PrimaryButton(
                        label: l10n.supervisor_serviceStart,
                        icon: TablerIcons.player_play,
                        expanded: false,
                        onPressed: () =>
                            _operateService(context, ref, l10n, 'start'),
                      ),
                    SecondaryButton(
                      label: l10n.supervisor_serviceRestart,
                      icon: TablerIcons.refresh,
                      expanded: false,
                      onPressed: () =>
                          _operateService(context, ref, l10n, 'restart'),
                    ),
                    SecondaryButton(
                      label: l10n.supervisor_initSupervisor,
                      icon: TablerIcons.tool,
                      expanded: false,
                      onPressed: () => _openInit(context, ref, status),
                    ),
                  ],
                ),
                if (!status.isRunning) ...[
                  const SizedBox(height: AppTokens.s12),
                  Text(
                    l10n.supervisor_serviceStoppedWarn,
                    style: AppTextStyles.bodyS.copyWith(
                      color: context.appColors.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.supervisor_title),
          if (data.processes.isEmpty)
            EmptyState(
              icon: TablerIcons.cpu,
              title: l10n.supervisor_emptyTitle,
              message: l10n.supervisor_emptySubtitle,
              actionLabel: l10n.supervisor_createProcess,
              onAction: () => _openForm(context, ref),
            )
          else
            for (final process in data.processes) ...[
              _ProcessCard(
                process: process,
                onTap: () => _openActions(context, ref, process),
              ),
              const SizedBox(height: AppTokens.s12),
            ],
        ],
      ),
    );
  }

  Future<void> _operateService(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String operate,
  ) async {
    final label = switch (operate) {
      'start' => l10n.supervisor_serviceStart,
      'stop' => l10n.supervisor_serviceStop,
      _ => l10n.supervisor_serviceRestart,
    };
    final confirmed = await showConfirmSheet(
      context,
      title: label,
      message: l10n.supervisor_serviceOperateConfirm(label),
      confirmLabel: label,
      danger: operate != 'start',
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(hostToolRepositoryProvider.future);
      await repository.operateSupervisor(operate);
      if (!context.mounted) return;
      AppToast.success(context, l10n.supervisor_operationSuccess);
      ref.invalidate(_supervisorProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error, prefix: l10n.supervisor_operationFailed);
    }
  }

  Future<void> _operateProcess(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    SupervisorProcessConfig process,
    String operate,
  ) async {
    final label = switch (operate) {
      'start' => l10n.containers_start,
      'stop' => l10n.containers_stop,
      'restart' => l10n.containers_restart,
      _ => l10n.common_delete,
    };
    final confirmed = await showConfirmSheet(
      context,
      title: label,
      message: operate == 'delete'
          ? l10n.supervisor_deleteConfirm(process.name)
          : l10n.supervisor_processOperateConfirm(label, process.name),
      confirmLabel: label,
      danger: operate != 'start',
    );
    if (!confirmed || !context.mounted) return;
    try {
      final repository = await ref.read(hostToolRepositoryProvider.future);
      await repository.operateSupervisorProcess(
        name: process.name,
        operate: operate,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.supervisor_operationSuccess);
      ref.invalidate(_supervisorProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error, prefix: l10n.supervisor_operationFailed);
    }
  }

  Future<void> _openInit(
    BuildContext context,
    WidgetRef ref,
    SupervisorToolStatus status,
  ) async {
    final result =
        await showAppSheet<({String configPath, String serviceName})>(
          context: context,
          builder: (context) => _InitSheet(status: status),
        );
    if (result == null || !context.mounted) return;
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(hostToolRepositoryProvider.future);
      await repository.initSupervisor(
        configPath: result.configPath,
        serviceName: result.serviceName,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.supervisor_initSuccess);
      ref.invalidate(_supervisorProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error, prefix: l10n.supervisor_initFailed);
    }
  }

  Future<void> _editConfig(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(hostToolRepositoryProvider.future);
      final content = await repository.supervisorConfig(operate: 'get');
      if (!context.mounted) return;
      final controller = TextEditingController(text: content);
      final saved = await showAppSheet<bool>(
        context: context,
        maxHeightFactor: 0.92,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.supervisor_configFile, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            AppTextField(controller: controller, maxLines: 16),
            const SizedBox(height: AppTokens.s16),
            PrimaryButton(
              label: l10n.action_save,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      );
      final value = controller.text;
      controller.dispose();
      if (saved != true || !context.mounted) return;
      await repository.supervisorConfig(operate: 'update', content: value);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
      ref.invalidate(_supervisorProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showProcessFile(
    BuildContext context,
    WidgetRef ref,
    SupervisorProcessConfig process,
    String file,
  ) async {
    final l10n = AppLocalizations.of(context);
    final isConfig = file == 'config';
    try {
      final repository = await ref.read(hostToolRepositoryProvider.future);
      final content = await repository.supervisorProcessFile(
        name: process.name,
        file: file,
        operate: 'get',
      );
      if (!context.mounted) return;
      final controller = TextEditingController(text: content);
      final saved = await showAppSheet<bool>(
        context: context,
        maxHeightFactor: 0.92,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isConfig ? l10n.supervisor_editConfig : file,
              style: AppTextStyles.titleL,
            ),
            const SizedBox(height: AppTokens.s4),
            Text(
              process.name,
              style: AppTextStyles.caption.copyWith(
                color: sheetContext.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.s16),
            if (isConfig)
              AppTextField(controller: controller, maxLines: 16)
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: SelectableText(
                    content.isEmpty ? l10n.state_empty : content,
                    style: AppTextStyles.caption.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            if (isConfig) ...[
              const SizedBox(height: AppTokens.s16),
              PrimaryButton(
                label: l10n.action_save,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
            ],
          ],
        ),
      );
      final value = controller.text;
      controller.dispose();
      if (!isConfig || saved != true || !context.mounted) return;
      await repository.supervisorProcessFile(
        name: process.name,
        file: 'config',
        operate: 'update',
        content: value,
      );
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
      ref.invalidate(_supervisorProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    SupervisorProcessConfig? process,
  }) async {
    final result = await showAppSheet<SupervisorProcessConfig>(
      context: context,
      builder: (context) => _ProcessFormSheet(initial: process),
    );
    if (result == null || !context.mounted) return;
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(hostToolRepositoryProvider.future);
      await repository.submitSupervisorProcess(
        result,
        operate: process == null ? 'create' : 'update',
      );
      if (!context.mounted) return;
      AppToast.success(
        context,
        process == null
            ? l10n.supervisor_createSuccess
            : l10n.supervisor_updateSuccess,
      );
      ref.invalidate(_supervisorProvider);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error, prefix: l10n.supervisor_saveFailed);
    }
  }

  Future<void> _openActions(
    BuildContext context,
    WidgetRef ref,
    SupervisorProcessConfig process,
  ) async {
    final l10n = AppLocalizations.of(context);
    final action = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(process.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            process.command,
            style: AppTextStyles.bodyS.copyWith(
              color: sheetContext.scheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.player_play),
                title: l10n.containers_start,
                subtitle: l10n.supervisor_processStartSubtitle,
                onTap: () => Navigator.of(sheetContext).pop('start'),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.player_stop),
                title: l10n.containers_stop,
                subtitle: l10n.supervisor_processStopSubtitle,
                onTap: () => Navigator.of(sheetContext).pop('stop'),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.refresh),
                title: l10n.containers_restart,
                subtitle: l10n.supervisor_processRestartSubtitle,
                onTap: () => Navigator.of(sheetContext).pop('restart'),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.edit),
                title: l10n.common_edit,
                onTap: () => Navigator.of(sheetContext).pop('edit'),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.file_settings),
                title: l10n.supervisor_editConfig,
                onTap: () => Navigator.of(sheetContext).pop('config'),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.file_text),
                title: l10n.supervisor_viewOutLog,
                onTap: () => Navigator.of(sheetContext).pop('out.log'),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.file_alert),
                title: l10n.supervisor_viewErrLog,
                onTap: () => Navigator.of(sheetContext).pop('err.log'),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.common_delete,
                subtitle: l10n.supervisor_deleteSubtitle,
                danger: true,
                onTap: () => Navigator.of(sheetContext).pop('delete'),
              ),
            ],
          ),
        ],
      ),
    );
    if (action == null || !context.mounted) return;
    if (action == 'edit') {
      await _openForm(context, ref, process: process);
    } else if (action == 'config' || action.endsWith('.log')) {
      await _showProcessFile(context, ref, process, action);
    } else {
      await _operateProcess(context, ref, l10n, process, action);
    }
  }
}

class _ProcessCard extends StatelessWidget {
  const _ProcessCard({required this.process, required this.onTap});

  final SupervisorProcessConfig process;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final state = supervisorGroupState(process.status);
    final label = switch (state) {
      SupervisorGroupState.starting => l10n.supervisor_stateStarting,
      SupervisorGroupState.running => l10n.common_running,
      SupervisorGroupState.warning => l10n.containers_abnormal,
      SupervisorGroupState.stopped => l10n.common_stopped,
    };
    return TonalCard(
      onTap: onTap,
      child: Row(
        children: [
          StatusDot(
            status: switch (state) {
              SupervisorGroupState.running => 'running',
              SupervisorGroupState.starting => 'warning',
              SupervisorGroupState.warning => 'warning',
              SupervisorGroupState.stopped => 'stopped',
            },
          ),
          const SizedBox(width: AppTokens.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  process.name,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  process.command,
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Icon(TablerIcons.chevron_right),
        ],
      ),
    );
  }
}

class _InitSheet extends StatefulWidget {
  const _InitSheet({required this.status});

  final SupervisorToolStatus status;

  @override
  State<_InitSheet> createState() => _InitSheetState();
}

class _InitSheetState extends State<_InitSheet> {
  late final TextEditingController _configPath = TextEditingController(
    text: widget.status.configPath.isEmpty
        ? '/etc/supervisor/supervisord.conf'
        : widget.status.configPath,
  );
  late final TextEditingController _serviceName = TextEditingController(
    text: widget.status.serviceName.isEmpty
        ? 'supervisord'
        : widget.status.serviceName,
  );
  String? _error;

  @override
  void dispose() {
    _configPath.dispose();
    _serviceName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.supervisor_initTitle, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s8),
        Text(
          l10n.supervisor_initWarning,
          style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _configPath,
          label: l10n.supervisor_primaryConfig,
          errorText: _error,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _serviceName,
          label: l10n.supervisor_serviceName,
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
              child: PrimaryButton(
                label: l10n.supervisor_initSupervisor,
                onPressed: () {
                  final configPath = _configPath.text.trim();
                  final serviceName = _serviceName.text.trim();
                  if (configPath.isEmpty || serviceName.isEmpty) {
                    setState(
                      () =>
                          _error = l10n.supervisor_configPathAndServiceRequired,
                    );
                    return;
                  }
                  Navigator.of(
                    context,
                  ).pop((configPath: configPath, serviceName: serviceName));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProcessFormSheet extends StatefulWidget {
  const _ProcessFormSheet({this.initial});

  final SupervisorProcessConfig? initial;

  @override
  State<_ProcessFormSheet> createState() => _ProcessFormSheetState();
}

class _ProcessFormSheetState extends State<_ProcessFormSheet> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _command = TextEditingController(
    text: widget.initial?.command ?? '',
  );
  late final _dir = TextEditingController(text: widget.initial?.dir ?? '');
  late final _user = TextEditingController(text: widget.initial?.user ?? '');
  late final _numprocs = TextEditingController(
    text: widget.initial?.numprocs ?? '1',
  );
  late final _environment = TextEditingController(
    text: widget.initial?.environment ?? '',
  );
  late bool _autoRestart = widget.initial?.autoRestart != 'false';
  late bool _autoStart = widget.initial?.autoStart != 'false';
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _command.dispose();
    _dir.dispose();
    _user.dispose();
    _numprocs.dispose();
    _environment.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final command = _command.text.trim();
    final dir = _dir.text.trim();
    final user = _user.text.trim();
    final numprocs = int.tryParse(_numprocs.text.trim());
    if (name.isEmpty || command.isEmpty || dir.isEmpty || user.isEmpty) {
      setState(() => _error = l10n.supervisor_requiredFields);
      return;
    }
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$').hasMatch(name)) {
      setState(() => _error = l10n.supervisor_nameRule);
      return;
    }
    if (numprocs == null || numprocs < 1 || numprocs > 9999) {
      setState(() => _error = l10n.supervisor_numprocsRule);
      return;
    }
    Navigator.of(context).pop(
      SupervisorProcessConfig(
        name: name,
        command: command,
        dir: dir,
        user: user,
        numprocs: '$numprocs',
        autoRestart: _autoRestart ? 'true' : 'false',
        autoStart: _autoStart ? 'true' : 'false',
        environment: _environment.text.trim(),
        status: const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.initial == null
              ? l10n.supervisor_createProcess
              : l10n.supervisor_editProcess,
          style: AppTextStyles.titleL,
        ),
        if (_error != null) ...[
          const SizedBox(height: AppTokens.s8),
          Text(
            _error!,
            style: AppTextStyles.bodyS.copyWith(color: context.scheme.error),
          ),
        ],
        const SizedBox(height: AppTokens.s16),
        AppTextField(controller: _name, label: l10n.supervisor_name),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _command,
          label: l10n.supervisor_command,
          maxLines: 2,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _dir, label: l10n.supervisor_workDir),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _user, label: l10n.supervisor_user),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _numprocs,
          label: l10n.supervisor_numprocs,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _environment,
          label: l10n.supervisor_environment,
          maxLines: 2,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.supervisor_autoRestart, style: AppTextStyles.bodyM),
          subtitle: Text(
            l10n.supervisor_autoRestartSubtitle,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          value: _autoRestart,
          onChanged: (value) => setState(() => _autoRestart = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.supervisor_autoStart, style: AppTextStyles.bodyM),
          subtitle: Text(
            l10n.supervisor_autoStartSubtitle,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          value: _autoStart,
          onChanged: (value) => setState(() => _autoStart = value),
        ),
        const SizedBox(height: AppTokens.s16),
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
              child: PrimaryButton(label: l10n.action_save, onPressed: _submit),
            ),
          ],
        ),
      ],
    );
  }
}

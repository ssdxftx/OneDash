import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/error_toast.dart';
import '../providers/containers_provider.dart';

class DockerSettingsPage extends ConsumerStatefulWidget {
  const DockerSettingsPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<DockerSettingsPage> createState() => _DockerSettingsPageState();
}

class _DockerSettingsPageState extends ConsumerState<DockerSettingsPage> {
  final _logMaxSize = TextEditingController();
  final _logMaxFile = TextEditingController();
  final _fixedCidrV6 = TextEditingController();
  final _daemonJson = TextEditingController();
  bool _ip6Tables = false;
  bool _experimental = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final config = await repository.getDaemonConfig();
      final file = await repository.getDaemonJsonFile();
      if (!mounted) return;
      setState(() {
        _logMaxSize.text = config.logMaxSize;
        _logMaxFile.text = config.logMaxFile;
        _fixedCidrV6.text = config.fixedCidrV6;
        _ip6Tables = config.ip6Tables;
        _experimental = config.experimental;
        _daemonJson.text = file;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      showErrorToast(context, error);
    }
  }

  @override
  void dispose() {
    _logMaxSize.dispose();
    _logMaxFile.dispose();
    _fixedCidrV6.dispose();
    _daemonJson.dispose();
    super.dispose();
  }

  Future<void> _editDaemonKey() async {
    final l10n = AppLocalizations.of(context);
    final key = TextEditingController();
    final value = TextEditingController();
    final saved = await pushFormPage<bool>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.containers_daemonKeyValue,
          onSave: () async => Navigator.of(pageContext).pop(true),
          children: [
            AppTextField(controller: key, label: l10n.containers_daemonKey),
            const SizedBox(height: AppTokens.s12),
            AppTextField(controller: value, label: l10n.containers_daemonValue),
          ],
        ),
      ),
    );
    final keyValue = key.text.trim();
    final valueText = value.text.trim();
    key.dispose();
    value.dispose();
    if (saved != true || keyValue.isEmpty || !mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.updateDaemonByKey(keyValue, valueText);
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      await _load();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showStats() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final stats = await repository.getItemStats();
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.containers_diskUsage, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            SplitListGroup(
              children: [
                SplitListTile(
                  title: l10n.containers_usageContainers,
                  value: formatBytes(stats.containerUsage),
                ),
                SplitListTile(
                  title: l10n.containers_usageImages,
                  value: formatBytes(stats.imageUsage),
                ),
                SplitListTile(
                  title: l10n.containers_usageVolumes,
                  value: formatBytes(stats.volumeUsage),
                ),
                SplitListTile(
                  title: l10n.containers_usageBuildCache,
                  value: formatBytes(stats.buildCacheUsage),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _operate(String operation) async {
    final l10n = AppLocalizations.of(context);
    final repository = await ref.read(containerRepositoryProvider.future);
    if (!mounted) return;
    final success = await TaskProgressSheet.run(
      context,
      title: _operationLabel(operation, l10n),
      task: (_) => repository.dockerOperate(operation),
    );
    if (!success || !mounted) return;
    ref.invalidate(dockerStatusProvider);
    AppToast.success(context, l10n.action_done);
  }

  Future<void> _saveLog() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.updateLogOption(
        logMaxSize: _logMaxSize.text.trim(),
        logMaxFile: _logMaxFile.text.trim(),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveIpv6() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.updateIpv6Option(
        fixedCidrV6: _fixedCidrV6.text.trim(),
        ip6Tables: _ip6Tables,
        experimental: _experimental,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveDaemon() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.updateDaemonJsonByFile(_daemonJson.text);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final docker = ref.watch(dockerStatusProvider);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.containers_dockerSettings,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _load,
          ),
          AppIconButton(
            icon: TablerIcons.key,
            tooltip: l10n.containers_daemonKeyValue,
            onPressed: _editDaemonKey,
          ),
          AppIconButton(
            icon: TablerIcons.chart_pie,
            tooltip: l10n.containers_diskUsage,
            onPressed: _showStats,
          ),
        ],
      ),
      body: _loading
          ? const SkeletonList(itemCount: 6)
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                AppTokens.s8,
                AppTokens.s16,
                AppTokens.s32,
              ),
              children: [
                SectionHeader(title: l10n.containers_dockerService),
                AsyncStateView(
                  value: docker,
                  loading: const SkeletonCard(height: 88),
                  onRetry: () => ref.invalidate(dockerStatusProvider),
                  builder: (status) => TonalCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              TablerIcons.brand_docker,
                              color: status.isAvailable
                                  ? context.appColors.success
                                  : context.appColors.danger,
                            ),
                            const SizedBox(width: AppTokens.s8),
                            Expanded(
                              child: Text(
                                status.isAvailable
                                    ? l10n.containers_dockerRunning
                                    : l10n.containers_dockerStopped,
                                style: AppTextStyles.titleM,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.s12),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: l10n.containers_start,
                                onPressed: status.isActive
                                    ? null
                                    : () => _operate('start'),
                              ),
                            ),
                            const SizedBox(width: AppTokens.s8),
                            Expanded(
                              child: SecondaryButton(
                                label: l10n.containers_stop,
                                onPressed: status.isActive
                                    ? () => _operate('stop')
                                    : null,
                              ),
                            ),
                            const SizedBox(width: AppTokens.s8),
                            Expanded(
                              child: SecondaryButton(
                                label: l10n.action_restart,
                                onPressed: status.isActive
                                    ? () => _operate('restart')
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.s24),
                SectionHeader(title: l10n.containers_logSettings),
                TonalCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _logMaxSize,
                              label: l10n.containers_logMaxSize,
                              hint: '10m',
                            ),
                          ),
                          const SizedBox(width: AppTokens.s12),
                          Expanded(
                            child: AppTextField(
                              controller: _logMaxFile,
                              label: l10n.containers_logMaxFile,
                              hint: '3',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.s12),
                      PrimaryButton(
                        label: l10n.action_save,
                        loading: _saving,
                        onPressed: _saving ? null : _saveLog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.s24),
                SectionHeader(title: l10n.containers_ipv6),
                TonalCard(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _fixedCidrV6,
                        label: l10n.containers_fixedCidrV6,
                        hint: 'fd00::/64',
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.containers_ip6Tables),
                        value: _ip6Tables,
                        onChanged: (value) =>
                            setState(() => _ip6Tables = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.containers_experimental),
                        value: _experimental,
                        onChanged: (value) =>
                            setState(() => _experimental = value),
                      ),
                      const SizedBox(height: AppTokens.s12),
                      PrimaryButton(
                        label: l10n.action_save,
                        loading: _saving,
                        onPressed: _saving ? null : _saveIpv6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.s24),
                const SectionHeader(title: 'daemon.json'),
                TonalCard(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _daemonJson,
                        hint: '{\n  "log-driver": "json-file"\n}',
                        maxLines: 12,
                      ),
                      const SizedBox(height: AppTokens.s12),
                      PrimaryButton(
                        label: l10n.action_save,
                        loading: _saving,
                        onPressed: _saving ? null : _saveDaemon,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _operationLabel(String operation, AppLocalizations l10n) {
    return switch (operation) {
      'start' => l10n.containers_start,
      'stop' => l10n.containers_stop,
      'restart' => l10n.action_restart,
      _ => operation,
    };
  }
}

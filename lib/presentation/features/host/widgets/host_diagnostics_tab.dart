import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/host/host_diagnostics_dto.dart';
import '../../../../data/repositories_impl/host_repository_impl.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class HostDiagnosticsTab extends ConsumerStatefulWidget {
  const HostDiagnosticsTab({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<HostDiagnosticsTab> createState() => _HostDiagnosticsTabState();
}

class _HostDiagnosticsTabState extends ConsumerState<HostDiagnosticsTab> {
  DiagnosticsSummaryDto? _summary;
  GoroutineSnapshotDto? _snapshot;
  bool _loading = true;
  bool _capturing = false;
  bool _checkingComponent = false;
  String _profileType = 'cpu';
  ComponentInfoDto? _componentResult;
  final _duration = TextEditingController(text: '15');
  final _component = TextEditingController(text: 'ffmpeg');

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _duration.dispose();
    _component.dispose();
    super.dispose();
  }

  Future<void> _checkComponent() async {
    final name = _component.text.trim();
    if (name.isEmpty) return;
    setState(() => _checkingComponent = true);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final result = await repository.getComponentInfo(name);
      if (!mounted) return;
      setState(() => _componentResult = result);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _checkingComponent = false);
    }
  }

  String _profileLabel(AppLocalizations l10n, String type) {
    return switch (type) {
      'heap' => l10n.host_diagProfileHeap,
      'goroutine' => l10n.host_diagProfileGoroutine,
      'mutex' => l10n.host_diagProfileMutex,
      'block' => l10n.host_diagProfileBlock,
      _ => l10n.host_diagProfileCpu,
    };
  }

  Future<void> _captureProfile() async {
    final l10n = AppLocalizations.of(context);
    final duration = int.tryParse(_duration.text.trim()) ?? 15;
    setState(() => _capturing = true);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final bytes = await repository.createDiagnosticsProfile(
        type: _profileType,
        duration: duration.clamp(5, 30),
      );
      if (!mounted) return;
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(
        ':',
        '-',
      );
      final path = await FilePicker.saveFile(
        dialogTitle: l10n.host_diagCapture,
        fileName: '1panel-$_profileType-$stamp.pprof',
        type: FileType.any,
        bytes: Uint8List.fromList(bytes),
      );
      if (!mounted || path == null) return;
      AppToast.success(context, l10n.host_diagProfileSaved);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final summary = await repository.getDiagnosticsSummary();
      final snapshot = await repository.getGoroutineSnapshot();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _snapshot = snapshot;
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showStack(GoroutineGroupDto group) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.host_diagStack, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s8),
          Text(
            '${group.state} · ${group.top} · ${group.count}',
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SelectableText(
            group.stack.join('\n'),
            style: AppTextStyles.bodyS.copyWith(
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading && _summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final summary = _summary;
    if (summary == null) {
      return EmptyState(
        icon: TablerIcons.stethoscope,
        title: l10n.host_diagnosticsEmptyTitle,
        message: l10n.state_empty,
      );
    }
    final snapshot = _snapshot;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.pagePadding),
        children: [
          SectionHeader(title: l10n.host_diagSummary),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.cpu),
                title: l10n.host_diagRss,
                value: formatBytes(summary.rss),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.stack_2),
                title: l10n.host_diagHeap,
                value: formatBytes(summary.heapAlloc),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.box),
                title: l10n.host_diagObjects,
                value: '${summary.heapObjects}',
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.activity),
                title: l10n.host_diagGoroutines,
                value: '${summary.goroutines}',
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.host_diagComponent),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _component,
                  label: l10n.host_diagComponentName,
                ),
                const SizedBox(height: AppTokens.s12),
                PrimaryButton(
                  label: l10n.host_diagCheck,
                  loading: _checkingComponent,
                  onPressed: _checkComponent,
                ),
                if (_componentResult != null) ...[
                  const SizedBox(height: AppTokens.s16),
                  SplitListGroup(
                    children: [
                      SplitListTile(
                        title: l10n.host_diagComponentExists,
                        value: _componentResult!.exists
                            ? l10n.common_yes
                            : l10n.host_diagComponentMissing,
                      ),
                      if (_componentResult!.exists) ...[
                        SplitListTile(
                          title: l10n.toolbox_version,
                          value: _componentResult!.version.isEmpty
                              ? '-'
                              : _componentResult!.version,
                        ),
                        SplitListTile(
                          title: l10n.host_diagComponentPath,
                          value: _componentResult!.path.isEmpty
                              ? '-'
                              : _componentResult!.path,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.host_diagCapture),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _profileType,
                  decoration: InputDecoration(
                    labelText: l10n.host_diagProfileType,
                  ),
                  items: [
                    for (final type in const [
                      'cpu',
                      'heap',
                      'goroutine',
                      'mutex',
                      'block',
                    ])
                      DropdownMenuItem(
                        value: type,
                        child: Text(_profileLabel(l10n, type)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _profileType = value);
                  },
                ),
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _duration,
                  label: l10n.host_diagDuration,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTokens.s16),
                PrimaryButton(
                  label: l10n.host_diagStartCapture,
                  loading: _capturing,
                  onPressed: _captureProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(
            title: l10n.host_diagSnapshot,
            trailing: TextButton.icon(
              onPressed: _load,
              icon: const Icon(TablerIcons.refresh, size: AppTokens.iconList),
              label: Text(l10n.action_refresh),
            ),
          ),
          if (snapshot == null || snapshot.groups.isEmpty)
            EmptyState(
              icon: TablerIcons.stack_2,
              title: l10n.host_diagSnapshotEmptyTitle,
              message: l10n.state_empty,
              compact: true,
            )
          else ...[
            TonalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.host_diagTotal}: ${snapshot.total} · '
                    '${l10n.host_diagGroups}: ${snapshot.groupCount}',
                    style: AppTextStyles.bodyS,
                  ),
                  if (snapshot.capturedAt.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      '${l10n.host_diagCapturedAt}: '
                      '${snapshot.capturedAt.replaceFirst('T', ' ').split('.').first}',
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (snapshot.truncated) ...[
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      l10n.host_diagTruncated,
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.scheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            SplitListGroup(
              children: [
                for (final group in snapshot.groups)
                  SplitListTile(
                    leading: const Icon(TablerIcons.binary_tree),
                    title: group.state,
                    subtitle: group.top,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${group.count}'),
                        const SizedBox(width: AppTokens.s4),
                        const Icon(TablerIcons.chevron_right),
                      ],
                    ),
                    onTap: () => _showStack(group),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppTokens.s24),
          SecondaryButton(
            label: l10n.action_refresh,
            icon: TablerIcons.refresh,
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
    );
  }
}

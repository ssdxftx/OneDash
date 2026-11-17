import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/api/process_api.dart';
import '../../../common/components/action_sheet.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/error_toast.dart';
import 'process_list_item.dart';

Future<void> showProcessDetailSheet(
  BuildContext context, {
  required int serverId,
  required int pid,
  Map<String, dynamic>? summary,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.92,
    builder: (_) =>
        _ProcessDetailSheet(serverId: serverId, pid: pid, summary: summary),
  );
}

class _ProcessDetailSheet extends ConsumerStatefulWidget {
  const _ProcessDetailSheet({
    required this.serverId,
    required this.pid,
    this.summary,
  });

  final int serverId;
  final int pid;
  final Map<String, dynamic>? summary;

  @override
  ConsumerState<_ProcessDetailSheet> createState() =>
      _ProcessDetailSheetState();
}

class _ProcessDetailSheetState extends ConsumerState<_ProcessDetailSheet> {
  Map<String, dynamic>? _detail;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = await ref.read(dioClientProvider(widget.serverId).future);
      final detail = await ProcessApi(client).getProcessByPID(widget.pid);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _stop() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.process_stopTitle,
      message: l10n.process_stopContent(widget.pid),
      confirmLabel: l10n.process_stopAction,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final client = await ref.read(dioClientProvider(widget.serverId).future);
      await ProcessApi(client).stopProcess(widget.pid);
      if (!mounted) return;
      navigator.pop();
      AppToast.success(navigator.context, l10n.process_stopRequested);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error, prefix: l10n.process_stopFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = widget.summary;
    final detail = _detail;
    final name = processText(
      detail?['name'] ?? summary?['name'],
      'PID ${widget.pid}',
    );
    final status = processText(detail?['status'] ?? summary?['status'], '');

    return ActionSheetScaffold(
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: context.appColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTokens.rMd),
          ),
          child: Icon(
            TablerIcons.cpu,
            size: 28,
            color: context.appColors.success,
          ),
        ),
        title: name,
        subtitle: 'PID ${widget.pid}',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status.isNotEmpty)
              ActionSheetStatusPill(
                label: status,
                color: context.appColors.status(processStatusTone(status)),
              ),
            const SizedBox(width: AppTokens.s4),
            IconButton(
              tooltip: l10n.process_stopTitle,
              onPressed: _stop,
              icon: const Icon(TablerIcons.player_stop),
              color: context.appColors.danger,
            ),
          ],
        ),
      ),
      child: _loading
          ? _DetailLoading(label: l10n.process_readingDetail)
          : _error != null
          ? _DetailError(
              label: l10n.process_readFailed,
              message: '$_error',
              retryLabel: l10n.action_retry,
              onRetry: _load,
            )
          : _DetailContent(detail: detail!, pid: widget.pid),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.s40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: AppTokens.spinner,
              height: AppTokens.spinner,
              child: CircularProgressIndicator(
                strokeWidth: AppTokens.spinnerStroke,
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            Text(
              label,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({
    required this.label,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String label;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.s32),
      child: Column(
        children: [
          Icon(
            TablerIcons.alert_circle,
            size: AppTokens.iconEmpty,
            color: context.appColors.danger,
          ),
          const SizedBox(height: AppTokens.s12),
          Text(label, style: AppTextStyles.titleS),
          const SizedBox(height: AppTokens.s4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail, required this.pid});

  final Map<String, dynamic> detail;
  final int pid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final openFiles = (detail['openFiles'] as List?) ?? const [];
    final connects = (detail['connects'] as List?) ?? const [];
    final envs = (detail['envs'] as List?) ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSection(
          title: l10n.process_basicInfo,
          icon: TablerIcons.info_circle,
          rows: [
            _DetailRow(label: 'PID', value: '$pid'),
            _DetailRow(label: 'PPID', value: processText(detail['PPID'])),
            _DetailRow(
              label: l10n.process_user,
              value: processText(detail['username']),
            ),
            _DetailRow(
              label: l10n.process_status,
              value: processText(detail['status']),
            ),
            _DetailRow(
              label: l10n.process_startTime,
              value: processText(detail['startTime']),
            ),
            _DetailRow(
              label: l10n.process_threadCount,
              value: processText(detail['numThreads']),
            ),
            _DetailRow(
              label: l10n.process_connectionCount,
              value: processText(detail['numConnections']),
            ),
            _DetailRow(
              label: l10n.process_commandLine,
              value: processText(detail['cmdLine']),
              mono: true,
            ),
          ],
        ),
        _DetailSection(
          title: l10n.process_cpuDisk,
          icon: TablerIcons.activity,
          rows: [
            _DetailRow(label: 'CPU', value: processText(detail['cpuPercent'])),
            _DetailRow(
              label: l10n.process_diskRead,
              value: processText(detail['diskRead']),
            ),
            _DetailRow(
              label: l10n.process_diskWrite,
              value: processText(detail['diskWrite']),
            ),
          ],
        ),
        _DetailSection(
          title: l10n.process_memoryDetails,
          icon: TablerIcons.cpu_2,
          rows: [
            _DetailRow(label: 'RSS', value: processText(detail['rss'])),
            _DetailRow(label: 'VMS', value: processText(detail['vms'])),
            _DetailRow(label: 'PSS', value: processText(detail['pss'])),
            _DetailRow(label: 'USS', value: processText(detail['uss'])),
            _DetailRow(label: 'HWM', value: processText(detail['hwm'])),
            _DetailRow(label: 'Shared', value: processText(detail['shared'])),
            _DetailRow(label: 'Swap', value: processText(detail['swap'])),
            _DetailRow(label: 'Dirty', value: processText(detail['dirty'])),
          ],
        ),
        if (openFiles.isNotEmpty)
          _DetailSection(
            title: l10n.process_openFiles,
            icon: TablerIcons.file,
            rows: [
              for (final file in openFiles)
                if (file is Map)
                  _DetailRow(
                    label: 'fd ${processText(file['fd'])}',
                    value: processText(file['path']),
                    mono: true,
                  ),
            ],
          ),
        if (connects.isNotEmpty)
          _DetailSection(
            title: l10n.process_networkConnections,
            icon: TablerIcons.network,
            rows: [
              for (final connect in connects)
                if (connect is Map)
                  SplitListTile(
                    leading: const Icon(TablerIcons.plug_connected),
                    title:
                        '${processText(connect['type'], 'unknown')} ${processText(connect['status'], '')}'
                            .trim(),
                    subtitle:
                        '${_formatAddress(connect['localaddr'])} → ${_formatAddress(connect['remoteaddr'])}',
                    subtitleStyle: AppTextStyles.caption.copyWith(
                      fontFamily: 'monospace',
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
            ],
          ),
        if (envs.isNotEmpty) ...[
          _DetailSectionHeader(
            title: l10n.process_environmentVariables,
            icon: TablerIcons.terminal,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTokens.s12),
            decoration: BoxDecoration(
              color: context.scheme.surfaceContainerLow,
              border: Border.all(color: context.scheme.outlineVariant),
              borderRadius: BorderRadius.circular(AppTokens.rMd),
            ),
            child: SelectableText(
              envs.join('\n'),
              style: AppTextStyles.caption.copyWith(
                fontFamily: 'monospace',
                height: 1.5,
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppTokens.s20),
        ],
      ],
    );
  }

  static String _formatAddress(Object? address) {
    if (address == null) return '--';
    if (address is Map) {
      final ip = '${address['ip'] ?? ''}';
      final port = '${address['port'] ?? ''}';
      if (ip.isEmpty && port.isEmpty) return '--';
      return '$ip:$port';
    }
    final text = '$address';
    return text.isEmpty ? '--' : text;
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionHeader(title: title, icon: icon),
        SplitListGroup(children: rows),
        const SizedBox(height: AppTokens.s20),
      ],
    );
  }
}

class _DetailSectionHeader extends StatelessWidget {
  const _DetailSectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTokens.s4, bottom: AppTokens.s8),
      child: Row(
        children: [
          Icon(icon, size: AppTokens.iconList, color: context.scheme.primary),
          const SizedBox(width: AppTokens.s8),
          Text(
            title,
            style: AppTextStyles.titleS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return SplitListTile(
      title: label,
      value: value,
      valueStyle: mono
          ? AppTextStyles.caption.copyWith(
              fontFamily: 'monospace',
              color: context.scheme.onSurface,
            )
          : null,
    );
  }
}

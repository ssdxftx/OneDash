import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/host/ssh_log_dto.dart';
import '../../../../data/repositories_impl/host_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

Future<void> showHostSshLogsSheet(
  BuildContext context, {
  required int serverId,
}) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.94,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.86,
      child: _HostSshLogsSheet(serverId: serverId),
    ),
  );
}

class _HostSshLogsSheet extends ConsumerStatefulWidget {
  const _HostSshLogsSheet({required this.serverId});

  final int serverId;

  @override
  ConsumerState<_HostSshLogsSheet> createState() => _HostSshLogsSheetState();
}

class _HostSshLogsSheetState extends ConsumerState<_HostSshLogsSheet> {
  final _info = TextEditingController();
  String _status = 'All';
  int _days = 7;
  bool _loading = true;
  bool _exporting = false;
  int _requestId = 0;
  Object? _error;
  List<SshLogDto> _logs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _info.dispose();
    super.dispose();
  }

  SshLogSearchReq _request() {
    final now = DateTime.now();
    return SshLogSearchReq(
      page: 1,
      pageSize: 100,
      info: _info.text.trim(),
      status: _status,
      startTime: now.subtract(Duration(days: _days)),
      endTime: now,
    );
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final result = await repository.searchSshLogs(_request());
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _logs = result.items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _export() async {
    if (_exporting) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _exporting = true);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final path = await repository.exportSshLogs(_request());
      if (!mounted) return;
      AppToast.success(context, l10n.host_sshLogExported(path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    return switch (status) {
      'Success' => l10n.host_sshLogSuccess,
      'Failed' => l10n.host_sshLogFailed,
      _ => l10n.host_sshLogAll,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FormSheet(
      title: l10n.host_sshLogs,
      subtitle: l10n.host_sshLogsHint,
      saveLabel: l10n.host_sshLogSearch,
      onSave: _load,
      actions: [
        IconButton(
          tooltip: l10n.host_sshLogExport,
          icon: _exporting
              ? const SizedBox(
                  width: AppTokens.spinner,
                  height: AppTokens.spinner,
                  child: CircularProgressIndicator(
                    strokeWidth: AppTokens.spinnerStroke,
                  ),
                )
              : const Icon(TablerIcons.download),
          onPressed: _exporting ? null : _export,
        ),
      ],
      children: [
        AppTextField(
          controller: _info,
          label: l10n.host_sshLogInfo,
          helper: l10n.host_sshLogInfoHint,
        ),
        const SizedBox(height: AppTokens.s12),
        Text(l10n.host_sshLogStatus, style: AppTextStyles.titleS),
        const SizedBox(height: AppTokens.s8),
        AppFilterChips<String>(
          options: const ['All', 'Success', 'Failed'],
          labelOf: (value) => _statusLabel(l10n, value),
          selected: {_status},
          onChanged: (values) {
            if (values.isEmpty) return;
            setState(() => _status = values.first);
            _load();
          },
        ),
        const SizedBox(height: AppTokens.s12),
        Text(l10n.host_sshLogRange, style: AppTextStyles.titleS),
        const SizedBox(height: AppTokens.s8),
        Wrap(
          spacing: AppTokens.s8,
          children: [
            for (final days in const [1, 7, 30])
              ChoiceChip(
                label: Text(l10n.host_sshLogDays('$days')),
                selected: _days == days,
                onSelected: (_) {
                  setState(() => _days = days);
                  _load();
                },
              ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        if (_loading)
          const SkeletonList(itemCount: 4)
        else if (_error != null)
          EmptyState(
            icon: TablerIcons.alert_triangle,
            title: l10n.host_sshLogLoadFailed,
            message: describeError(_error!, l10n),
            actionLabel: l10n.action_retry,
            onAction: _load,
          )
        else if (_logs.isEmpty)
          EmptyState(
            icon: TablerIcons.terminal_2,
            title: l10n.host_sshLogEmpty,
            message: l10n.host_sshLogsHint,
          )
        else
          for (final log in _logs)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s8),
              child: TonalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusDot(
                          status: log.status == 'Success' ? 'running' : 'error',
                        ),
                        const SizedBox(width: AppTokens.s8),
                        Expanded(
                          child: Text(
                            '${log.user} · ${log.address}',
                            style: AppTextStyles.titleS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          log.dateStr,
                          style: AppTextStyles.caption.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (log.message.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.s4),
                      Text(
                        log.message,
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

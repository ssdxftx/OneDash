import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../../../data/dto/common/task_log_dto.dart';
import '../components/app_bar_large.dart';
import '../components/app_toast.dart';
import '../components/bottom_sheet_surface.dart';
import '../components/buttons.dart';
import '../components/status_pill.dart';
import '../states/error_mapper.dart';
import '../states/error_state.dart';

typedef TaskLogReader = Future<TaskLogDto> Function(String taskID);

/// 任务日志详情弹层：拉全文、执行中自动轮询、结束停止、可复制。
Future<void> showTaskLogSheet(
  BuildContext context, {
  required String title,
  required String taskID,
  required TaskLogReader reader,
  VoidCallback? onFinished,
}) async {
  await showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.78,
    builder: (_) => _TaskLogSheet(
      title: title,
      taskID: taskID,
      reader: reader,
      onFinished: onFinished,
    ),
  );
}

class _TaskLogSheet extends StatefulWidget {
  const _TaskLogSheet({
    required this.title,
    required this.taskID,
    required this.reader,
    this.onFinished,
  });

  final String title;
  final String taskID;
  final TaskLogReader reader;
  final VoidCallback? onFinished;

  @override
  State<_TaskLogSheet> createState() => _TaskLogSheetState();
}

class _TaskLogSheetState extends State<_TaskLogSheet> {
  Timer? _timer;
  TaskLogDto? _log;
  Object? _error;
  bool _loading = true;
  bool _executing = true;
  bool _finishedNotified = false;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final log = await widget.reader(widget.taskID);
      if (!mounted) return;
      final executing = log.taskStatus.trim().isNotEmpty
          ? log.isExecuting
          : !log.end;
      setState(() {
        _log = log;
        _executing = executing;
        _error = null;
        _loading = false;
      });
      if (!executing) {
        _timer?.cancel();
        if (!_finishedNotified) {
          _finishedNotified = true;
          widget.onFinished?.call();
        }
      }
    } catch (error) {
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _error = error;
        _loading = false;
        _executing = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _loading = true;
      _executing = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _load());
    _load();
  }

  Future<void> _copy() async {
    final text = _log?.lines.join('\n') ?? '';
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    AppToast.success(context, AppLocalizations.of(context).taskLog_copied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final log = _log;
    final busy = _loading || _executing;
    final failed = (log?.taskStatus ?? '').toLowerCase() == 'failed';
    final statusTone = _executing
        ? context.appColors.warning
        : (failed ? context.appColors.danger : context.appColors.success);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(TablerIcons.logs, size: 22, color: context.scheme.primary),
            const SizedBox(width: AppTokens.s8),
            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleM,
              ),
            ),
            if (busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              AppIconButton(
                icon: TablerIcons.copy,
                tooltip: l10n.taskLog_copy,
                onPressed: _copy,
              ),
          ],
        ),
        if (log != null) ...[
          const SizedBox(height: AppTokens.s8),
          Row(
            children: [
              StatusPill(
                label: _executing
                    ? l10n.taskLog_executing
                    : (failed ? l10n.common_failed : l10n.common_success),
                tone: statusTone,
              ),
              if (log.path.isNotEmpty) ...[
                const SizedBox(width: AppTokens.s8),
                Expanded(
                  child: Text(
                    log.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: AppTokens.s16),
        if (_error != null)
          ErrorState(
            data: ErrorViewData(
              icon: TablerIcons.file_alert,
              title: l10n.taskLog_readFailedTitle,
              message: mapError(_error!, l10n).message,
              detail: mapError(_error!, l10n).detail,
              actionLabel: l10n.common_retry,
            ),
            onRetry: _retry,
          )
        else if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (log == null || log.lines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                log != null && log.total == 0
                    ? l10n.taskLog_expired
                    : l10n.taskLog_emptyTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in log.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: SizedBox(
                        width: double.infinity,
                        child: SelectableText(
                          line,
                          style: AppTextStyles.bodyS.copyWith(
                            fontFamily: 'monospace',
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppTokens.s16),
        SecondaryButton(
          label: l10n.action_close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../states/error_toast.dart';
import 'bottom_sheet_surface.dart';
import 'buttons.dart';

typedef TaskRunner = Future<void> Function(TaskProgressController controller);

/// 把日志行推给长任务面板。
class TaskProgressController {
  void Function(String line)? _onLine;

  void log(String line) {
    final value = line.trim();
    if (value.isEmpty) return;
    _onLine?.call(value);
  }
}

/// 长任务三态面板：执行中、成功、失败。
class TaskProgressSheet extends StatefulWidget {
  const TaskProgressSheet({
    super.key,
    required this.title,
    required this.task,
    this.successMessage,
  });

  final String title;
  final TaskRunner task;
  final String? successMessage;

  /// 打开面板并执行任务。关闭面板返回 false。
  static Future<bool> run(
    BuildContext context, {
    required String title,
    required TaskRunner task,
    String? successMessage,
  }) async {
    final result = await showAppSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      maxHeightFactor: 0.7,
      builder: (sheetContext) => TaskProgressSheet(
        title: title,
        task: task,
        successMessage: successMessage,
      ),
    );
    return result ?? false;
  }

  @override
  State<TaskProgressSheet> createState() => _TaskProgressSheetState();
}

class _TaskProgressSheetState extends State<TaskProgressSheet> {
  final TaskProgressController _controller = TaskProgressController();
  bool _running = true;
  String? _line;
  String? _pendingLine;
  Object? _error;
  Timer? _closeTimer;
  Timer? _lineTimer;

  @override
  void initState() {
    super.initState();
    _controller._onLine = (line) {
      if (!mounted) return;
      _pendingLine = line;
      if (_lineTimer?.isActive ?? false) return;
      _lineTimer = Timer(const Duration(milliseconds: 150), () {
        if (!mounted || _pendingLine == null) return;
        setState(() => _line = _pendingLine);
      });
    };
    _run();
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _lineTimer?.cancel();
    _controller._onLine = null;
    super.dispose();
  }

  Future<void> _run() async {
    _closeTimer?.cancel();
    _lineTimer?.cancel();
    _pendingLine = null;
    setState(() {
      _running = true;
      _error = null;
      _line = null;
    });
    try {
      await widget.task(_controller);
      if (!mounted) return;
      setState(() => _running = false);
      _closeTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final error = _error;
    return PopScope(
      canPop: !_running,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_running)
                const SizedBox(
                  width: AppTokens.s20,
                  height: AppTokens.s20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (error != null)
                Icon(
                  TablerIcons.alert_triangle,
                  color: context.appColors.danger,
                )
              else
                Icon(
                  TablerIcons.circle_check,
                  color: context.appColors.success,
                ),
              const SizedBox(width: AppTokens.s12),
              Expanded(child: Text(widget.title, style: AppTextStyles.titleL)),
            ],
          ),
          if (_running) ...[
            const SizedBox(height: AppTokens.s16),
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: AppTokens.s12),
            Text(
              _line ?? l10n.task_runningHint,
              style: AppTextStyles.bodyS.copyWith(
                color: scheme.onSurfaceVariant,
                fontFamily: _line == null ? null : 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ] else if (error != null) ...[
            const SizedBox(height: AppTokens.s12),
            Text(
              describeError(error, l10n),
              style: AppTextStyles.bodyM.copyWith(color: scheme.error),
            ),
          ] else ...[
            const SizedBox(height: AppTokens.s12),
            Text(
              widget.successMessage ?? l10n.action_done,
              style: AppTextStyles.bodyM.copyWith(
                color: context.appColors.success,
              ),
            ),
          ],
          if (_running) ...[
            const SizedBox(height: AppTokens.s20),
            SecondaryButton(
              label: l10n.containers_continueInBackground,
              icon: TablerIcons.arrow_back,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ] else if (error != null) ...[
            const SizedBox(height: AppTokens.s20),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: l10n.action_close,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: PrimaryButton(
                    label: l10n.common_retry,
                    onPressed: _run,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

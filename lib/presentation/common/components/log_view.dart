import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';

/// 固定容量环形日志缓冲，超出后丢弃头部。
class LogBuffer {
  LogBuffer({this.capacity = AppTokens.logBufferLines});

  final int capacity;
  final ListQueue<String> _lines = ListQueue<String>();

  List<String> get lines => List.unmodifiable(_lines);
  int get length => _lines.length;
  bool get isEmpty => _lines.isEmpty;

  void add(String line) {
    _lines.addLast(line);
    while (_lines.length > capacity) {
      _lines.removeFirst();
    }
  }

  void addAll(Iterable<String> lines) {
    for (final line in lines) {
      add(line);
    }
  }

  void clear() => _lines.clear();
}

class LogView extends StatefulWidget {
  const LogView({
    super.key,
    required this.lines,
    this.paused = false,
    this.onPauseChanged,
    this.onClear,
    this.onExport,
    this.showLineNumbers = false,
    this.emptyLabel,
  });

  final List<String> lines;
  final bool paused;
  final ValueChanged<bool>? onPauseChanged;
  final VoidCallback? onClear;
  final VoidCallback? onExport;
  final bool showLineNumbers;
  final String? emptyLabel;

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final ScrollController _controller = ScrollController();
  bool _atBottom = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant LogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.paused && widget.lines.length != oldWidget.lines.length) {
      if (_atBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    }
  }

  void _handleScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 24;
    if (atBottom != _atBottom) setState(() => _atBottom = atBottom);
  }

  void _scrollToBottom() {
    if (!_controller.hasClients) return;
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.consoleBackground,
        borderRadius: BorderRadius.circular(AppTokens.rMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          _LogToolbar(
            paused: widget.paused,
            onPauseChanged: widget.onPauseChanged,
            onClear: widget.onClear,
            onExport: widget.onExport,
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          Expanded(
            child: Stack(
              children: [
                if (widget.lines.isEmpty)
                  Center(
                    child: Text(
                      widget.emptyLabel ?? l10n.log_empty,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppTokens.consoleMuted,
                      ),
                    ),
                  )
                else
                  Scrollbar(
                    controller: _controller,
                    child: ListView.builder(
                      controller: _controller,
                      padding: const EdgeInsets.all(AppTokens.s12),
                      itemCount: widget.lines.length,
                      itemBuilder: (context, index) {
                        final line = widget.lines[index];
                        return Text(
                          widget.showLineNumbers ? '${index + 1}  $line' : line,
                          style: AppTextStyles.bodyS.copyWith(
                            fontFamily: 'monospace',
                            color: AppTokens.consoleForeground,
                            height: 1.5,
                          ),
                        );
                      },
                    ),
                  ),
                if (!_atBottom)
                  Positioned(
                    right: AppTokens.s16,
                    bottom: AppTokens.s16,
                    child: IconButton.filled(
                      tooltip: l10n.log_jumpLatest,
                      onPressed: _scrollToBottom,
                      icon: const Icon(TablerIcons.arrow_down),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogToolbar extends StatelessWidget {
  const _LogToolbar({
    required this.paused,
    this.onPauseChanged,
    this.onClear,
    this.onExport,
  });

  final bool paused;
  final ValueChanged<bool>? onPauseChanged;
  final VoidCallback? onClear;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: AppTokens.s4,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: paused ? l10n.log_resume : l10n.log_pause,
            onPressed: onPauseChanged == null
                ? null
                : () => onPauseChanged!(!paused),
            icon: Icon(
              paused ? TablerIcons.player_play : TablerIcons.player_pause,
              size: AppTokens.iconList,
            ),
          ),
          IconButton(
            tooltip: l10n.log_clear,
            onPressed: onClear,
            icon: const Icon(TablerIcons.trash, size: AppTokens.iconList),
          ),
          const Spacer(),
          IconButton(
            tooltip: l10n.log_export,
            onPressed: onExport,
            icon: const Icon(TablerIcons.download, size: AppTokens.iconList),
          ),
        ],
      ),
    );
  }
}

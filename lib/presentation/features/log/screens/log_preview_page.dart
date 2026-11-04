import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/states/error_toast.dart';

/// A loadable log source shown as a chip above the log body.
class LogSourceOption {
  const LogSourceOption({required this.label, required this.load});

  final String label;
  final Future<List<String>> Function() load;
}

enum LogDisplayMode { raw, structured }

/// Fullscreen in-app log preview shared by every module.
///
/// The page keeps the loaded buffer in memory, supports search, level colouring,
/// a structured parsing mode, follow polling, local paging and export. Parsing
/// failures always fall back to the original line.
class LogPreviewPage extends StatefulWidget {
  const LogPreviewPage({
    super.key,
    required this.title,
    required this.sources,
    this.subtitle,
    this.pageSize = 500,
    this.followInterval = const Duration(seconds: 5),
  });

  final String title;
  final String? subtitle;
  final List<LogSourceOption> sources;
  final int pageSize;
  final Duration followInterval;

  @override
  State<LogPreviewPage> createState() => _LogPreviewPageState();
}

class _LogPreviewPageState extends State<LogPreviewPage>
    with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<String> _lines = const [];
  Object? _error;
  bool _loading = true;
  bool _follow = false;
  Timer? _timer;
  int _sourceIndex = 0;
  LogDisplayMode _mode = LogDisplayMode.raw;
  int _window = 500;
  bool _atBottom = true;
  String _query = '';
  bool _loadInFlight = false;
  List<String>? _filteredSource;
  String _filteredQuery = '';
  List<String>? _filteredCache;

  LogSourceOption get _source => widget.sources[_sourceIndex];

  @override
  void initState() {
    super.initState();
    _window = widget.pageSize;
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_follow) {
        _timer?.cancel();
        _timer = Timer.periodic(
          widget.followInterval,
          (_) => _load(silent: true),
        );
        _load(silent: true);
      }
    } else {
      _timer?.cancel();
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 24;
    if (atBottom != _atBottom) setState(() => _atBottom = atBottom);
  }

  Future<void> _load({bool silent = false}) async {
    if (_loadInFlight) return;
    _loadInFlight = true;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final lines = await _source.load();
      if (!mounted) return;
      final unchanged = listEquals(_lines, lines);
      if (silent && unchanged && _error == null) return;
      setState(() {
        _lines = lines;
        _loading = false;
        _error = null;
      });
      if (silent && _follow && _atBottom) _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    } finally {
      _loadInFlight = false;
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _toggleFollow() {
    setState(() => _follow = !_follow);
    _timer?.cancel();
    if (!_follow) return;
    _timer = Timer.periodic(widget.followInterval, (_) => _load(silent: true));
    _load(silent: true);
    if (_atBottom) _scrollToBottom();
  }

  void _selectSource(int index) {
    if (index == _sourceIndex) return;
    setState(() {
      _sourceIndex = index;
      _window = widget.pageSize;
      _lines = const [];
    });
    _load();
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    try {
      final path = await FilePicker.saveFile(
        fileName: '${widget.title.replaceAll(RegExp(r'[^\w\-]+'), '_')}.log',
        bytes: utf8.encode(_lines.join('\n')),
      );
      if (!mounted || path == null) return;
      AppToast.success(context, l10n.logs_exported(path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  List<String> get _filtered {
    final query = _query.trim().toLowerCase();
    if (identical(_filteredSource, _lines) && _filteredQuery == query) {
      return _filteredCache!;
    }
    final result = query.isEmpty
        ? _lines
        : _lines
              .where((line) => line.toLowerCase().contains(query))
              .toList(growable: false);
    _filteredSource = _lines;
    _filteredQuery = query;
    _filteredCache = result;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final filtered = _filtered;
    final start = filtered.length > _window ? filtered.length - _window : 0;
    final visible = filtered.sublist(start);

    return Scaffold(
      appBar: AppBarLarge(
        title: widget.title,
        subtitle: widget.subtitle,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _load,
          ),
          AppIconButton(
            icon: TablerIcons.download,
            tooltip: l10n.log_export,
            onPressed: _lines.isEmpty ? null : _export,
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.sources.length > 1)
            AppFilterChips<int>(
              options: List<int>.generate(widget.sources.length, (i) => i),
              labelOf: (index) => widget.sources[index].label,
              selected: {_sourceIndex},
              onChanged: (selection) {
                if (selection.isEmpty) return;
                _selectSource(selection.first);
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
            child: SearchField(
              controller: _searchController,
              hint: l10n.logs_searchHint,
              onChanged: (value) => setState(() {
                _query = value;
                _window = widget.pageSize;
              }),
            ),
          ),
          const SizedBox(height: AppTokens.s8),
          AppFilterChips<LogDisplayMode>(
            options: const [LogDisplayMode.raw, LogDisplayMode.structured],
            labelOf: (mode) => mode == LogDisplayMode.raw
                ? l10n.logs_raw
                : l10n.logs_structured,
            selected: {_mode},
            onChanged: (selection) {
              if (selection.isEmpty) return;
              setState(() => _mode = selection.first);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.logs_lineCount(filtered.length),
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                FilterChip(
                  selected: _follow,
                  showCheckmark: false,
                  label: Text(
                    _follow ? l10n.logs_stopFollow : l10n.logs_follow,
                  ),
                  onSelected: (_) => _toggleFollow(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
              decoration: BoxDecoration(
                color: AppTokens.consoleBackground,
                borderRadius: BorderRadius.circular(AppTokens.rMd),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: _buildBody(l10n, filtered, visible, start),
            ),
          ),
          if (start > 0)
            Padding(
              padding: const EdgeInsets.all(AppTokens.s8),
              child: TextButton.icon(
                onPressed: () => setState(() => _window += widget.pageSize),
                icon: const Icon(TablerIcons.chevron_up, size: 18),
                label: Text(l10n.logs_loadEarlier),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s16,
                vertical: AppTokens.s8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _query.trim().isEmpty
                          ? l10n.logs_lineCount(_lines.length)
                          : l10n.logs_matchCount(filtered.length),
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_follow)
                    Text(
                      l10n.logs_following,
                      style: AppTextStyles.caption.copyWith(
                        color: context.appColors.success,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    List<String> filtered,
    List<String> visible,
    int start,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                describeError(_error!, l10n),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppTokens.consoleForeground,
                ),
              ),
              const SizedBox(height: AppTokens.s12),
              TextButton(onPressed: _load, child: Text(l10n.action_retry)),
            ],
          ),
        ),
      );
    }
    if (visible.isEmpty) {
      return Center(
        child: Text(
          _query.trim().isEmpty ? l10n.log_empty : l10n.logs_noMatches,
          style: AppTextStyles.bodyS.copyWith(color: AppTokens.consoleMuted),
        ),
      );
    }
    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppTokens.s12),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final number = start + index + 1;
          final raw = visible[index];
          return _mode == LogDisplayMode.structured
              ? _StructuredLine(number: number, raw: raw)
              : _RawLine(number: number, raw: raw);
        },
      ),
    );
  }
}

class _RawLine extends StatelessWidget {
  const _RawLine({required this.number, required this.raw});

  final int number;
  final String raw;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        '$number  $raw',
        style: AppTextStyles.bodyS.copyWith(
          fontFamily: 'monospace',
          color: AppTokens.consoleForeground,
          height: 1.5,
        ),
      ),
    );
  }
}

enum _LogLevel { trace, debug, info, warn, error, fatal, plain }

class _ParsedLine {
  const _ParsedLine({required this.level, required this.message, this.time});

  final _LogLevel level;
  final String message;
  final String? time;
}

_ParsedLine _parseLine(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
    try {
      final json = jsonDecode(trimmed);
      if (json is Map) {
        final level = _levelOf(
          (json['level'] ?? json['severity'] ?? '').toString(),
        );
        final message =
            (json['message'] ?? json['msg'] ?? json['log'] ?? trimmed)
                .toString();
        final time = (json['time'] ?? json['timestamp'] ?? '').toString();
        return _ParsedLine(
          level: level,
          message: message,
          time: time.isEmpty ? null : time,
        );
      }
    } on FormatException {
      // Fall through to the plain line, never drop content.
    }
  }
  final match = RegExp(
    r'^(?:\[|\()?(\d{4}[-/]\d{2}[-/]\d{2}[ T]\d{2}:\d{2}:\d{2}(?:[.,]\d+)?(?:Z|[+-]\d{2}:?\d{2})?)(?:\]|\))?\s*(?:\[(TRACE|DEBUG|INFO|NOTICE|WARN|WARNING|ERROR|ERR|FATAL|CRITICAL)\]|(TRACE|DEBUG|INFO|NOTICE|WARN|WARNING|ERROR|ERR|FATAL|CRITICAL)\b)?\s*(.*)$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (match == null) {
    return _ParsedLine(level: _levelOf(trimmed), message: raw);
  }
  return _ParsedLine(
    level: _levelOf(match.group(2) ?? match.group(3) ?? ''),
    message: match.group(4) ?? raw,
    time: match.group(1),
  );
}

_LogLevel _levelOf(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('fatal') || normalized.contains('critical')) {
    return _LogLevel.fatal;
  }
  if (normalized.contains('error') || normalized.contains('err')) {
    return _LogLevel.error;
  }
  if (normalized.contains('warn')) return _LogLevel.warn;
  if (normalized.contains('debug')) return _LogLevel.debug;
  if (normalized.contains('trace')) return _LogLevel.trace;
  if (normalized.contains('info') || normalized.contains('notice')) {
    return _LogLevel.info;
  }
  return _LogLevel.plain;
}

class _StructuredLine extends StatelessWidget {
  const _StructuredLine({required this.number, required this.raw});

  final int number;
  final String raw;

  @override
  Widget build(BuildContext context) {
    final parsed = _parseLine(raw);
    final colors = context.appColors;
    final color = switch (parsed.level) {
      _LogLevel.fatal || _LogLevel.error => colors.danger,
      _LogLevel.warn => colors.warning,
      _LogLevel.info => colors.success,
      _LogLevel.debug || _LogLevel.trace => AppTokens.consoleMuted,
      _LogLevel.plain => AppTokens.consoleForeground,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              '$number',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption.copyWith(
                fontFamily: 'monospace',
                color: AppTokens.consoleMuted,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          if (parsed.time != null) ...[
            Text(
              parsed.time!,
              style: AppTextStyles.caption.copyWith(
                fontFamily: 'monospace',
                color: AppTokens.consoleMuted,
              ),
            ),
            const SizedBox(width: AppTokens.s8),
          ],
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppTokens.rXs),
            ),
            child: Text(
              parsed.level == _LogLevel.plain
                  ? 'LOG'
                  : parsed.level.name.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          Expanded(
            child: SelectableText(
              parsed.message,
              style: AppTextStyles.bodyS.copyWith(
                fontFamily: 'monospace',
                color: AppTokens.consoleForeground,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

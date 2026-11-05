import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/states/error_toast.dart';
import '../log_parser.dart';

const double _logNumberWidth = 44;
const double _logChevronSize = 16;

/// A page of a loadable log source. [end] is true when there are no older lines.
class LogBatch {
  const LogBatch({required this.lines, required this.end});

  final List<String> lines;
  final bool end;
}

/// A loadable log source shown as a chip above the log body.
class LogSourceOption {
  const LogSourceOption({
    required this.label,
    required this.load,
    this.loadPage,
    this.exportBytes,
    this.exportNote,
  });

  final String label;
  final Future<List<String>> Function() load;
  final Future<LogBatch> Function(int page, int pageSize)? loadPage;
  final Future<List<int>?> Function()? exportBytes;
  final String Function(int count)? exportNote;
}

enum LogDisplayMode { raw, structured }

/// Fullscreen in-app log preview shared by every module.
///
/// The page keeps the loaded buffer in memory, supports search, level colouring,
/// nginx/JSON structured parsing, follow polling, server-side paging and export.
/// Parsing failures always fall back to the original line.
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
  int _page = 1;
  bool _end = true;
  bool _loadingEarlier = false;
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
      final List<String> lines;
      final bool end;
      final loadPage = _source.loadPage;
      if (loadPage != null) {
        final batch = await loadPage(1, widget.pageSize);
        lines = batch.lines;
        end = batch.end;
      } else {
        lines = await _source.load();
        end = true;
      }
      if (!mounted) return;
      final unchanged = listEquals(_lines, lines);
      if (silent && unchanged && _error == null) return;
      setState(() {
        _lines = lines;
        _loading = false;
        _error = null;
        _page = 1;
        _end = end;
        _window = widget.pageSize;
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

  Future<void> _loadEarlier() async {
    if (_loadingEarlier) return;
    final loadPage = _source.loadPage;
    if (loadPage == null) {
      setState(() => _window += widget.pageSize);
      return;
    }
    if (_end) return;
    setState(() => _loadingEarlier = true);
    try {
      final batch = await loadPage(_page + 1, widget.pageSize);
      if (!mounted) return;
      final incoming = batch.lines;
      final existing = _lines;
      final maxOverlap = incoming.length < existing.length
          ? incoming.length
          : existing.length;
      var overlap = 0;
      for (var size = 1; size <= maxOverlap; size++) {
        if (listEquals(
          incoming.sublist(incoming.length - size),
          existing.sublist(0, size),
        )) {
          overlap = size;
        }
      }
      final prepend = overlap == incoming.length
          ? const <String>[]
          : incoming.sublist(0, incoming.length - overlap);
      final repeated = listEquals(incoming, existing) || prepend.isEmpty;
      setState(() {
        if (prepend.isNotEmpty) _lines = [...prepend, ..._lines];
        _page += 1;
        _end = batch.end || repeated;
        _window = _lines.length;
        _loadingEarlier = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingEarlier = false);
      showErrorToast(context, error);
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
      _page = 1;
      _end = true;
      _lines = const [];
    });
    _load();
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    try {
      final note = _source.exportNote;
      if (note != null) {
        AppToast.show(context, note(_lines.length), type: AppToastType.info);
      }
      final exported = await _source.exportBytes?.call();
      final bytes = exported == null
          ? Uint8List.fromList(utf8.encode(_lines.join('\n')))
          : Uint8List.fromList(exported);
      final path = await FilePicker.saveFile(
        fileName: '${widget.title.replaceAll(RegExp(r'[^\w\-]+'), '_')}.log',
        bytes: bytes,
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
                  labelStyle: AppTextStyles.label.copyWith(
                    color: scheme.onSurface,
                  ),
                  label: Text(
                    _follow ? l10n.logs_stopFollow : l10n.logs_follow,
                  ),
                  onSelected: (_) => _toggleFollow(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s8),
          if (_showEarlier(start))
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                0,
                AppTokens.s16,
                AppTokens.s8,
              ),
              child: _loadingEarlier
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _loadEarlier,
                        icon: const Icon(TablerIcons.chevron_up, size: 18),
                        label: Text(l10n.logs_loadEarlier),
                      ),
                    ),
            )
          else if (_source.loadPage != null && _end && _lines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                0,
                AppTokens.s16,
                AppTokens.s8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.logs_startOfFile,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
              decoration: BoxDecoration(
                color: AppTokens.consoleBackground,
                borderRadius: BorderRadius.circular(AppTokens.rMd),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: _buildBody(l10n, visible, start),
            ),
          ),
          SafeArea(
            top: false,
            child: _follow
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.s16,
                      vertical: AppTokens.s8,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        l10n.logs_following,
                        style: AppTextStyles.caption.copyWith(
                          color: context.appColors.success,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  bool _showEarlier(int start) {
    if (_source.loadPage != null) return !_end;
    return start > 0;
  }

  Widget _buildBody(AppLocalizations l10n, List<String> visible, int start) {
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
    final parsed = parseLogLine(raw);
    final color = switch (parsed.level) {
      LogLevel.fatal || LogLevel.error => context.appColors.danger,
      LogLevel.warn => context.appColors.warning,
      LogLevel.info => context.appColors.success,
      LogLevel.debug || LogLevel.trace => AppTokens.consoleMuted,
      LogLevel.plain => AppTokens.consoleForeground,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _logNumberWidth,
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
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      raw,
                      softWrap: false,
                      style: AppTextStyles.bodyS.copyWith(
                        fontFamily: 'monospace',
                        color: color,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: 24,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppTokens.consoleBackground.withValues(alpha: 0),
                              AppTokens.consoleBackground,
                            ],
                          ),
                        ),
                      ),
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
}

class _StructuredLine extends StatefulWidget {
  const _StructuredLine({required this.number, required this.raw});

  final int number;
  final String raw;

  @override
  State<_StructuredLine> createState() => _StructuredLineState();
}

class _StructuredLineState extends State<_StructuredLine> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parsed = parseLogLine(widget.raw);
    final colors = context.appColors;
    final color = switch (parsed.level) {
      LogLevel.fatal || LogLevel.error => colors.danger,
      LogLevel.warn => colors.warning,
      LogLevel.info => colors.success,
      LogLevel.debug || LogLevel.trace => AppTokens.consoleMuted,
      LogLevel.plain => AppTokens.consoleForeground,
    };
    final summary = parsed.isAccess
        ? _accessSummary(context, l10n, parsed, color)
        : _genericSummary(context, l10n, parsed, color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: summary,
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 52, top: AppTokens.s4),
              child: _details(context, l10n, parsed, color),
            ),
        ],
      ),
    );
  }

  Widget _accessSummary(
    BuildContext context,
    AppLocalizations l10n,
    ParsedLogLine parsed,
    Color levelColor,
  ) {
    final status = parsed.status;
    final statusColor = switch (status) {
      int s when s >= 500 => context.appColors.danger,
      int s when s >= 400 => context.appColors.warning,
      int s when s >= 300 => context.appColors.info,
      _ => levelColor,
    };
    final path = parsed.path ?? parsed.message;
    final method = parsed.method ?? '';
    final duration = parsed.duration;
    final statusStyle = AppTextStyles.caption.copyWith(
      color: statusColor,
      fontWeight: FontWeight.w600,
    );
    final statusText = status?.toString() ?? '-';
    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppTokens.rXs),
      ),
      child: Text(statusText, style: statusStyle),
    );
    final methodStyle = AppTextStyles.caption.copyWith(
      color: context.scheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    final methodText = Text(method, style: methodStyle);
    final pathText = Text(
      path,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyS.copyWith(
        fontFamily: 'monospace',
        color: AppTokens.consoleForeground,
      ),
    );
    final durationStyle = AppTextStyles.caption.copyWith(
      color: AppTokens.consoleMuted,
    );
    final durationText = duration == null
        ? null
        : Text(duration, style: durationStyle);
    final chevron = Icon(
      _expanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
      size: _logChevronSize,
      color: AppTokens.consoleMuted,
    );
    final scaler = MediaQuery.textScalerOf(context);
    double textWidth(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      );
      try {
        painter.layout();
        return painter.width;
      } finally {
        painter.dispose();
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final badgeWidth = textWidth(statusText, statusStyle) + 10;
        final methodWidth = method.isEmpty
            ? 0.0
            : textWidth(method, methodStyle) + AppTokens.s8;
        final durationWidth = duration == null
            ? 0.0
            : textWidth(duration, durationStyle) + AppTokens.s8;
        final pathWithoutMethod =
            constraints.maxWidth -
            _logNumberWidth -
            AppTokens.s8 -
            badgeWidth -
            AppTokens.s8 -
            durationWidth -
            _logChevronSize;
        final hideDuration = durationText != null && pathWithoutMethod < 150;
        final effectivePath =
            pathWithoutMethod + (hideDuration ? durationWidth : 0);
        final pathWithMethod = effectivePath - methodWidth;
        final compact = scaler.scale(1) > 1.2 || effectivePath < 150;
        if (!compact) {
          return Row(
            children: [
              _number(),
              const SizedBox(width: AppTokens.s8),
              statusBadge,
              if (method.isNotEmpty &&
                  !hideDuration &&
                  pathWithMethod >= 150) ...[
                const SizedBox(width: AppTokens.s8),
                methodText,
              ],
              const SizedBox(width: AppTokens.s4),
              Expanded(child: pathText),
              if (durationText != null && !hideDuration) ...[
                const SizedBox(width: AppTokens.s8),
                durationText,
              ],
              chevron,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _number(),
                const SizedBox(width: AppTokens.s8),
                statusBadge,
                const Spacer(),
                if (durationText != null) ...[
                  durationText,
                  const SizedBox(width: AppTokens.s8),
                ],
                chevron,
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 2),
              child: SizedBox(width: double.infinity, child: pathText),
            ),
          ],
        );
      },
    );
  }

  Widget _genericSummary(
    BuildContext context,
    AppLocalizations l10n,
    ParsedLogLine parsed,
    Color color,
  ) {
    return Row(
      children: [
        _number(),
        const SizedBox(width: AppTokens.s8),
        if (parsed.time != null) ...[
          SizedBox(
            width: 76,
            child: Text(
              _shortTime(parsed.time!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontFamily: 'monospace',
                color: AppTokens.consoleMuted,
              ),
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
            parsed.level == LogLevel.plain
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
          child: Text(
            parsed.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyS.copyWith(
              fontFamily: 'monospace',
              color: AppTokens.consoleForeground,
            ),
          ),
        ),
        Icon(
          _expanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
          size: 16,
          color: AppTokens.consoleMuted,
        ),
      ],
    );
  }

  Widget _number() {
    return SizedBox(
      width: _logNumberWidth,
      child: Text(
        '${widget.number}',
        textAlign: TextAlign.right,
        style: AppTextStyles.caption.copyWith(
          fontFamily: 'monospace',
          color: AppTokens.consoleMuted,
        ),
      ),
    );
  }

  Widget _details(
    BuildContext context,
    AppLocalizations l10n,
    ParsedLogLine parsed,
    Color color,
  ) {
    final rows = <Widget>[
      if (parsed.time != null) _field(l10n.logs_time, parsed.time!),
      if (parsed.status != null) _field(l10n.logs_status, '${parsed.status}'),
      if (parsed.method != null) _field(l10n.logs_method, parsed.method!),
      if (parsed.path != null) _field(l10n.logs_path, parsed.path!),
      if (parsed.ip != null) _field(l10n.logs_ip, parsed.ip!),
      if (parsed.bytes != null) _field(l10n.logs_bytes, '${parsed.bytes}'),
      if (parsed.upstream != null) _field(l10n.logs_upstream, parsed.upstream!),
      if (parsed.referer != null) _field(l10n.logs_referer, parsed.referer!),
      if (parsed.userAgent != null)
        _field(l10n.logs_userAgent, parsed.userAgent!),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rows.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTokens.s8),
            decoration: BoxDecoration(
              color: AppTokens.consoleForeground.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppTokens.rXs),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
        SelectableText(
          widget.raw,
          style: AppTextStyles.bodyS.copyWith(
            fontFamily: 'monospace',
            color: color,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppTokens.s4),
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: widget.raw));
            if (!context.mounted) return;
            AppToast.success(context, l10n.logs_copied);
          },
          icon: const Icon(TablerIcons.copy, size: 16),
          label: Text(l10n.logs_copyRaw),
        ),
      ],
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppTokens.consoleMuted,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: AppTextStyles.caption.copyWith(
                fontFamily: 'monospace',
                color: AppTokens.consoleForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortTime(String value) {
    final match = RegExp(r'(\d{2}:\d{2}:\d{2})').firstMatch(value);
    return match?.group(1) ?? value;
  }
}

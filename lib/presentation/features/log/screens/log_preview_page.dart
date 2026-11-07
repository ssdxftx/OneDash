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
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_toast.dart';
import '../../../../core/utils/format_utils.dart';
import '../log_parser.dart';

const double _logNumberWidth = 44;
const double _logChevronSize = AppTokens.iconList;
const double _logIndent = _logNumberWidth + AppTokens.s8;
const double _logPathMinWidth = 150;

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

enum LogDisplayMode { cards, raw, structured }

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
    this.embedded = false,
  });

  final String title;
  final String? subtitle;
  final List<LogSourceOption> sources;
  final int pageSize;
  final Duration followInterval;

  /// When true the page renders without a Scaffold, for use inside a sheet.
  final bool embedded;

  @override
  State<LogPreviewPage> createState() => _LogPreviewPageState();
}

class _LogPreviewPageState extends State<LogPreviewPage>
    with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<String> _lines = const [];
  bool _hasAccess = false;
  Object? _error;
  bool _loading = true;
  bool _follow = false;
  Timer? _timer;
  int _sourceIndex = 0;
  LogDisplayMode _mode = LogDisplayMode.raw;
  bool _modePinned = false;
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
      final hasAccess = lines.any((line) => parseLogLine(line).isAccess);
      setState(() {
        _lines = lines;
        _hasAccess = hasAccess;
        _loading = false;
        _error = null;
        _page = 1;
        _end = end;
        _window = widget.pageSize;
        if (!_modePinned) {
          _mode = hasAccess ? LogDisplayMode.cards : LogDisplayMode.raw;
        }
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
      final hasAccess = prepend.isEmpty
          ? _hasAccess
          : [
              ...prepend,
              ...existing,
            ].any((line) => parseLogLine(line).isAccess);
      setState(() {
        if (prepend.isNotEmpty) {
          _lines = [...prepend, ..._lines];
          _hasAccess = hasAccess;
        }
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
      _hasAccess = false;
      _modePinned = false;
      _mode = LogDisplayMode.raw;
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

    final content = Column(
      children: [
        if (widget.embedded)
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.pagePadding,
              AppTokens.s4,
              0,
              AppTokens.s4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: AppTextStyles.titleM),
                      if (widget.subtitle != null &&
                          widget.subtitle!.trim().isNotEmpty)
                        Text(
                          widget.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyS.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.action_refresh,
                  onPressed: _load,
                  icon: const Icon(TablerIcons.refresh),
                ),
                IconButton(
                  tooltip: l10n.log_export,
                  onPressed: _lines.isEmpty ? null : _export,
                  icon: const Icon(TablerIcons.download),
                ),
                IconButton(
                  tooltip: l10n.action_close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(TablerIcons.x),
                ),
              ],
            ),
          ),
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
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
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
          options: [
            if (_hasAccess) LogDisplayMode.cards,
            LogDisplayMode.raw,
            LogDisplayMode.structured,
          ],
          labelOf: (mode) => switch (mode) {
            LogDisplayMode.cards => l10n.logs_cards,
            LogDisplayMode.raw => l10n.logs_raw,
            LogDisplayMode.structured => l10n.logs_structured,
          },
          selected: {_mode},
          onChanged: (selection) {
            if (selection.isEmpty) return;
            setState(() {
              _modePinned = true;
              _mode = selection.first;
            });
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
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
                label: Text(_follow ? l10n.logs_stopFollow : l10n.logs_follow),
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
          child: _mode == LogDisplayMode.cards
              ? _buildBody(l10n, visible, start)
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: context.pagePadding),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: context.pagePadding,
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
    );

    if (widget.embedded) return content;
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
      body: content,
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
                  color: _mode == LogDisplayMode.cards
                      ? context.scheme.onSurfaceVariant
                      : AppTokens.consoleForeground,
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
    if (_mode == LogDisplayMode.cards) {
      return Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            AppTokens.s8,
            context.pagePadding,
            AppTokens.s16,
          ),
          itemCount: visible.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
          itemBuilder: (context, index) {
            final raw = visible[index];
            final parsed = parseLogLine(raw);
            return parsed.isAccess
                ? _AccessLogCard(parsed: parsed)
                : _PlainLogCard(raw: raw);
          },
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

DateTime? _parseAccessTime(String? raw) {
  if (raw == null) return null;
  final match = RegExp(
    r'^(\d{2})/([A-Za-z]{3})/(\d{4}):(\d{2}):(\d{2}):(\d{2})(?:\s+([+-]\d{4}))?$',
  ).firstMatch(raw.trim());
  if (match == null) return null;
  const months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };
  final month = months[(match.group(2) ?? '').toLowerCase()];
  if (month == null) return null;
  final utc = DateTime.utc(
    int.parse(match.group(3)!),
    month,
    int.parse(match.group(1)!),
    int.parse(match.group(4)!),
    int.parse(match.group(5)!),
    int.parse(match.group(6)!),
  );
  final offset = match.group(7);
  if (offset == null) return utc.toLocal();
  final sign = offset.startsWith('-') ? -1 : 1;
  final hours = int.parse(offset.substring(1, 3));
  final minutes = int.parse(offset.substring(3, 5));
  return utc
      .subtract(Duration(hours: sign * hours, minutes: sign * minutes))
      .toLocal();
}

class _AccessLogCard extends StatelessWidget {
  const _AccessLogCard({required this.parsed});

  final ParsedLogLine parsed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final colors = context.appColors;
    final status = parsed.status;
    final statusColor = status == null
        ? scheme.onSurfaceVariant
        : status >= 500
        ? colors.danger
        : status >= 400
        ? colors.warning
        : colors.success;
    final time = _parseAccessTime(parsed.time);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    final statusText = Text(
      status?.toString() ?? '-',
      style: AppTextStyles.bodyS.copyWith(
        fontFamily: 'monospace',
        fontWeight: FontWeight.w600,
        color: statusColor,
      ),
    );
    final methodText = Text(
      parsed.method ?? '-',
      style: AppTextStyles.caption.copyWith(
        fontFamily: 'monospace',
        color: scheme.onSurfaceVariant,
      ),
    );
    final ipText = Text(
      parsed.ip ?? l10n.format_relativeUnknown,
      maxLines: largeText ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyS.copyWith(
        fontFamily: 'monospace',
        fontWeight: FontWeight.w600,
      ),
    );
    final timeText = Text(
      formatRelativeTime(time, l10n),
      maxLines: largeText ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textAlign: largeText ? TextAlign.start : TextAlign.end,
      style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
    );
    return TonalCard(
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (largeText) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTokens.s8),
                statusText,
                const SizedBox(width: AppTokens.s8),
                methodText,
              ],
            ),
            const SizedBox(height: AppTokens.s4),
            Wrap(
              spacing: AppTokens.s8,
              runSpacing: AppTokens.s4,
              children: [ipText, timeText],
            ),
          ] else
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTokens.s8),
                statusText,
                const SizedBox(width: AppTokens.s8),
                methodText,
                const SizedBox(width: AppTokens.s8),
                Expanded(child: ipText),
                const SizedBox(width: AppTokens.s8),
                Flexible(child: timeText),
              ],
            ),
          const SizedBox(height: AppTokens.s8),
          Text(
            parsed.path ?? parsed.message,
            maxLines: largeText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyS.copyWith(
              fontFamily: 'monospace',
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainLogCard extends StatelessWidget {
  const _PlainLogCard({required this.raw});

  final String raw;

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Text(
        raw,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyS.copyWith(fontFamily: 'monospace'),
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
          AnimatedSize(
            duration: context.motion(AppTokens.dBase),
            curve: AppTokens.curveBase,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: _logIndent,
                      top: AppTokens.s4,
                    ),
                    child: _details(context, l10n, parsed, color),
                  )
                : const SizedBox(width: double.infinity),
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
    final chevron = AnimatedRotation(
      turns: _expanded ? 0.5 : 0,
      duration: context.motion(AppTokens.dFast),
      curve: AppTokens.curveBase,
      child: const Icon(
        TablerIcons.chevron_down,
        size: _logChevronSize,
        color: AppTokens.consoleMuted,
      ),
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
        final hideDuration =
            durationText != null &&
            method.isNotEmpty &&
            pathWithoutMethod - methodWidth < _logPathMinWidth;
        final effectivePath =
            pathWithoutMethod + (hideDuration ? durationWidth : 0);
        final pathWithMethod = effectivePath - methodWidth;
        final compact =
            scaler.scale(1) > 1.2 || effectivePath < _logPathMinWidth;
        if (!compact) {
          return Row(
            children: [
              _number(),
              const SizedBox(width: AppTokens.s8),
              statusBadge,
              if (method.isNotEmpty && pathWithMethod >= _logPathMinWidth) ...[
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
              padding: const EdgeInsets.only(left: _logIndent, top: 2),
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
        AnimatedRotation(
          turns: _expanded ? 0.5 : 0,
          duration: context.motion(AppTokens.dFast),
          curve: AppTokens.curveBase,
          child: const Icon(
            TablerIcons.chevron_down,
            size: _logChevronSize,
            color: AppTokens.consoleMuted,
          ),
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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xterm/xterm.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../common/states/error_toast.dart';
import '../../../../core/network/api_compatibility.dart';
import '../../../../core/network/one_panel_auth.dart';
import '../../../../core/network/web_socket_connector.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/repositories_impl/host_repository_impl.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/empty_state.dart';

enum _TerminalStatus { connecting, connected, disconnected, error }

class TerminalPage extends ConsumerStatefulWidget {
  const TerminalPage({super.key, required this.serverId, this.containerName});

  final int serverId;
  final String? containerName;

  @override
  ConsumerState<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends ConsumerState<TerminalPage> {
  final Terminal _terminal = Terminal(maxLines: 10000);
  final FocusNode _focusNode = FocusNode();
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  _TerminalStatus _status = _TerminalStatus.connecting;
  String? _error;
  double _fontSize = 14;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  Future<void> _connect() async {
    setState(() {
      _status = _TerminalStatus.connecting;
      _error = null;
    });
    try {
      final storage = ref.read(storageServiceProvider);
      final server = await storage.getServer(widget.serverId);
      if (server == null) {
        if (!mounted) return;
        throw StateError(AppLocalizations.of(context).process_serverMissing);
      }
      final apiKey = await storage.getApiKey(widget.serverId) ?? '';
      final headers = await OnePanelAuth.signedHeaders(apiKey);
      final uri = server.baseUrl;
      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final isContainer = widget.containerName != null;
      final query = <String, String>{
        'cols': '${_terminal.viewWidth}',
        'rows': '${_terminal.viewHeight}',
        'operateNode': 'local',
        if (isContainer) ...{
          'source': 'container',
          'containerid': widget.containerName!,
          'user': 'root',
          'command': '/bin/sh',
        } else ...{
          'source': 'host',
        },
      };
      final paths = isContainer
          ? const [
              '/api/v2/hosts/terminal/container',
              '/api/v2/containers/exec',
            ]
          : const ['/api/v2/hosts/terminal/local', '/api/v2/hosts/terminal'];

      final channel = await ApiCompatibility.tryVariants<WebSocketChannel>(
        paths
            .map(
              (path) => ApiEndpointVariant<WebSocketChannel>(
                name: path,
                call: () async {
                  final wsUrl = Uri(
                    scheme: wsScheme,
                    host: uri.host,
                    port: uri.port,
                    path: '${uri.path}$path'.replaceAll('//', '/'),
                    queryParameters: query,
                  );
                  await checkAppWebSocketAuth(
                    wsUrl,
                    headers: headers,
                    allowInsecureConnections: server.allowInsecureConnections,
                    currentNode: 'local',
                  );
                  return connectAppWebSocket(
                    wsUrl,
                    headers: headers,
                    allowInsecureConnections: server.allowInsecureConnections,
                  );
                },
              ),
            )
            .toList(growable: false),
        cacheScope: widget.serverId,
        cacheKey: isContainer ? 'terminal.container' : 'terminal.host',
      );

      _channel = channel;
      _subscription = channel.stream.listen(
        (data) {
          if (_status != _TerminalStatus.connected && mounted) {
            setState(() => _status = _TerminalStatus.connected);
          }
          try {
            final message = jsonDecode(data.toString());
            if (message is Map && message['type'] == 'cmd') {
              final payload = message['data'];
              if (payload is String) {
                _terminal.write(
                  utf8.decode(base64Decode(payload), allowMalformed: true),
                );
              }
            }
          } catch (_) {
            if (data is String) _terminal.write(data);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _status = _TerminalStatus.error;
            _error = describeError(error, AppLocalizations.of(context));
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() => _status = _TerminalStatus.disconnected);
        },
      );

      _terminal.onOutput = (data) {
        if (_status == _TerminalStatus.connected) {
          _channel?.sink.add(
            jsonEncode({
              'type': 'cmd',
              'data': base64Encode(utf8.encode(data)),
            }),
          );
        }
      };
      _terminal.onResize = (w, h, pw, ph) {
        if (_status == _TerminalStatus.connected) {
          _channel?.sink.add(
            jsonEncode({'type': 'resize', 'cols': w, 'rows': h}),
          );
        }
      };
      if (mounted) setState(() => _status = _TerminalStatus.connected);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _TerminalStatus.error;
        _error = describeError(error, AppLocalizations.of(context));
      });
    }
  }

  Future<void> _showSessions() async {
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) =>
          _TerminalSessionsSheet(serverId: widget.serverId),
    );
  }

  Future<void> _disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
  }

  @override
  void dispose() {
    unawaited(_disconnect());
    _focusNode.dispose();
    super.dispose();
  }

  void _key(TerminalKey key, {bool ctrl = false}) {
    _focusNode.requestFocus();
    _terminal.keyInput(key, ctrl: ctrl);
  }

  void _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    if (text.contains('password=') || text.contains('token=')) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(context).terminal_sensitivePasteTitle,
          ),
          content: Text(
            AppLocalizations.of(context).terminal_sensitivePasteMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).action_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context).terminal_paste),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    _terminal.paste(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (statusLabel, statusColor) = switch (_status) {
      _TerminalStatus.connecting => (
        l10n.terminal_connecting,
        context.appColors.warning,
      ),
      _TerminalStatus.connected => (
        l10n.terminal_connected,
        context.appColors.success,
      ),
      _TerminalStatus.disconnected => (
        l10n.terminal_disconnected,
        context.appColors.danger,
      ),
      _TerminalStatus.error => (
        l10n.terminal_disconnected,
        context.appColors.danger,
      ),
    };

    return PopScope(
      canPop: _status != _TerminalStatus.connected,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.terminal_title),
            content: Text(l10n.terminal_disconnect_confirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.action_cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.action_close),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await _disconnect();
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F0C),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B0F0C),
          foregroundColor: const Color(0xFFD7E4DA),
          title: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Text(statusLabel, style: AppTextStyles.bodyS),
            ],
          ),
          actions: [
            IconButton(
              tooltip: l10n.terminal_sessions,
              onPressed: _showSessions,
              icon: const Icon(TablerIcons.list),
            ),
            IconButton(
              tooltip: l10n.action_refresh,
              onPressed: () async {
                await _disconnect();
                await _connect();
              },
              icon: const Icon(TablerIcons.refresh),
            ),
            PopupMenuButton<double>(
              tooltip: l10n.terminal_fontSize,
              icon: const Icon(TablerIcons.text_size),
              onSelected: (value) => setState(() => _fontSize = value),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 12, child: Text('12')),
                PopupMenuItem(value: 14, child: Text('14')),
                PopupMenuItem(value: 16, child: Text('16')),
                PopupMenuItem(value: 18, child: Text('18')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                color: context.appColors.danger.withValues(alpha: 0.15),
                padding: const EdgeInsets.all(AppTokens.s8),
                child: Text(
                  _error!,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appColors.danger,
                  ),
                ),
              ),
            Expanded(
              child: TerminalView(
                _terminal,
                focusNode: _focusNode,
                autofocus: true,
                deleteDetection: true,
                textStyle: TerminalStyle(
                  fontSize: _fontSize,
                  fontFamily: 'monospace',
                ),
                theme: TerminalThemes.defaultTheme,
              ),
            ),
            _TerminalToolbar(
              enabled: _status == _TerminalStatus.connected,
              onKey: _key,
              onPaste: _paste,
            ),
          ],
        ),
      ),
    );
  }
}

class _TerminalToolbar extends StatelessWidget {
  const _TerminalToolbar({
    required this.enabled,
    required this.onKey,
    required this.onPaste,
  });

  final bool enabled;
  final void Function(TerminalKey key, {bool ctrl}) onKey;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Container(
        height: 48,
        color: const Color(0xFF141A16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8),
          children: [
            _KeyButton(
              label: 'Ctrl+C',
              onTap: enabled ? () => onKey(TerminalKey.keyC, ctrl: true) : null,
            ),
            _KeyButton(
              label: 'Ctrl+D',
              onTap: enabled ? () => onKey(TerminalKey.keyD, ctrl: true) : null,
            ),
            _KeyButton(
              label: 'Tab',
              onTap: enabled ? () => onKey(TerminalKey.tab) : null,
            ),
            _KeyButton(
              label: 'Esc',
              onTap: enabled ? () => onKey(TerminalKey.escape) : null,
            ),
            _KeyButton(
              label: '←',
              onTap: enabled ? () => onKey(TerminalKey.arrowLeft) : null,
            ),
            _KeyButton(
              label: '↑',
              onTap: enabled ? () => onKey(TerminalKey.arrowUp) : null,
            ),
            _KeyButton(
              label: '↓',
              onTap: enabled ? () => onKey(TerminalKey.arrowDown) : null,
            ),
            _KeyButton(
              label: '→',
              onTap: enabled ? () => onKey(TerminalKey.arrowRight) : null,
            ),
            _KeyButton(
              label: l10n.terminal_paste,
              onTap: enabled ? onPaste : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFD7E4DA),
            minimumSize: const Size(44, 36),
          ),
          child: Text(label, style: AppTextStyles.caption),
        ),
      ),
    );
  }
}

class _TerminalSessionsSheet extends ConsumerStatefulWidget {
  const _TerminalSessionsSheet({required this.serverId});

  final int serverId;

  @override
  ConsumerState<_TerminalSessionsSheet> createState() =>
      _TerminalSessionsSheetState();
}

class _TerminalSessionsSheetState
    extends ConsumerState<_TerminalSessionsSheet> {
  List<Map<String, dynamic>> _sessions = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      final sessions = await repository.searchTerminalSessions();
      if (!mounted) return;
      setState(() => _sessions = sessions);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _close(String id) async {
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.closeTerminalSession(id);
      if (!mounted) return;
      AppToast.success(context, AppLocalizations.of(context).action_done);
      await _load();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _closeAll() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.terminal_closeAllSessions,
      message: l10n.terminal_closeAllConfirm,
      confirmLabel: l10n.terminal_closeAllSessions,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(
        hostRepositoryProvider(widget.serverId).future,
      );
      await repository.closeAllTerminalSessions();
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      await _load();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  String _kindLabel(AppLocalizations l10n, String kind) {
    return switch (kind) {
      'local' => l10n.terminal_kindLocal,
      'ssh' => l10n.terminal_kindSsh,
      'container' => l10n.terminal_kindContainer,
      _ => kind,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.terminal_sessions, style: AppTextStyles.titleL),
            ),
            if (_sessions.isNotEmpty)
              TextButton(
                onPressed: _closeAll,
                child: Text(l10n.terminal_closeAllSessions),
              ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AppTokens.s24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_sessions.isEmpty)
          EmptyState(
            icon: TablerIcons.terminal_2,
            title: l10n.terminal_sessions,
            message: l10n.terminal_sessionsEmpty,
            compact: true,
          )
        else
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: ListView(
              children: [
                SplitListGroup(
                  children: [
                    for (final session in _sessions)
                      SplitListTile(
                        leading: const Icon(TablerIcons.terminal_2),
                        title: '${session['title'] ?? ''}'.isEmpty
                            ? _kindLabel(l10n, '${session['kind'] ?? ''}')
                            : '${session['title']}',
                        subtitle: [
                          _kindLabel(l10n, '${session['kind'] ?? ''}'),
                          session['attached'] == true
                              ? l10n.terminal_sessionAttached
                              : l10n.terminal_sessionDetached,
                          formatLocalDateTime(
                            '${session['createdAt'] ?? ''}',
                            fallback: '',
                          ),
                        ].where((value) => value.isNotEmpty).join(' · '),
                        trailing: TextButton(
                          onPressed: () => _close('${session['id'] ?? ''}'),
                          child: Text(l10n.terminal_closeSession),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

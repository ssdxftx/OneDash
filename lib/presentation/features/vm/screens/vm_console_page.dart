import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/one_panel_auth.dart';
import '../../../../core/network/vnc_client.dart';
import '../../../../core/network/web_socket_connector.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/console_app_bar.dart';
import '../../../common/states/error_toast.dart';

class VmConsolePage extends ConsumerStatefulWidget {
  const VmConsolePage({super.key, required this.serverId, required this.name});

  final int serverId;
  final String name;

  @override
  ConsumerState<VmConsolePage> createState() => _VmConsolePageState();
}

class _VmConsolePageState extends ConsumerState<VmConsolePage> {
  VncClient? _client;
  VncFrame? _frame;
  Object? _error;
  bool _connecting = false;
  bool _buttonDown = false;
  StreamSubscription<VncFrame>? _frameSub;
  StreamSubscription<Object>? _errorSub;
  Offset? _lastRemote;

  @override
  void initState() {
    super.initState();
    unawaited(_connect());
  }

  Future<void> _connect() async {
    if (_connecting) return;
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      final storage = ref.read(storageServiceProvider);
      final server = await storage.getServer(widget.serverId);
      if (!mounted) return;
      if (server == null) {
        throw VncException(AppLocalizations.of(context).process_serverMissing);
      }
      final apiKey = await storage.getApiKey(widget.serverId) ?? '';
      final headers = await OnePanelAuth.signedHeaders(apiKey);
      final session = await storage.getPanelSession(widget.serverId);
      if (session != null) {
        headers['Cookie'] = session.cookieHeader;
        if (session.csrfToken.isNotEmpty) {
          headers['X-CSRF-Token'] = session.csrfToken;
        }
      }
      final uri = server.baseUrl;
      final wsUrl = Uri(
        scheme: uri.scheme == 'https' ? 'wss' : 'ws',
        host: uri.host,
        port: uri.port,
        path: '${uri.path}/api/v2/vms/console/ws'.replaceAll('//', '/'),
        queryParameters: {'name': widget.name},
      );
      await checkAppWebSocketAuth(
        wsUrl,
        headers: headers,
        allowInsecureConnections: server.allowInsecureConnections,
      );
      final channel = connectAppWebSocket(
        wsUrl,
        headers: headers,
        allowInsecureConnections: server.allowInsecureConnections,
      );
      final client = VncClient(channel);
      if (!mounted) {
        await client.close();
        return;
      }
      await _teardownClient();
      _frameSub = client.frames.listen(_onFrame);
      _errorSub = client.errors.listen(_onError);
      _client = client;
      await client.connect();
      if (!mounted) return;
      setState(() => _connecting = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _connecting = false;
      });
    }
  }

  void _onFrame(VncFrame frame) {
    if (!mounted) return;
    final previous = _frame;
    setState(() => _frame = frame);
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => previous.image.dispose(),
      );
    }
  }

  void _onError(Object error) {
    if (!mounted) return;
    setState(() => _error = error);
  }

  Future<void> _teardownClient() async {
    await _frameSub?.cancel();
    await _errorSub?.cancel();
    _frameSub = null;
    _errorSub = null;
    final client = _client;
    _client = null;
    if (client != null) await client.close();
  }

  @override
  void dispose() {
    _frame?.image.dispose();
    unawaited(_teardownClient());
    super.dispose();
  }

  void _releasePointer() {
    if (!_buttonDown) return;
    _buttonDown = false;
    final point = _lastRemote;
    _client?.sendPointer(point?.dx.toInt() ?? 0, point?.dy.toInt() ?? 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTokens.consoleBackground,
      appBar: ConsoleAppBar(
        title: l10n.vm_console,
        subtitle: widget.name,
        leading: IconButton(
          tooltip: l10n.action_close,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(TablerIcons.x),
        ),
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: _connecting ? null : _connect,
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(l10n)),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_connecting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTokens.consoleForeground),
            const SizedBox(height: AppTokens.s16),
            Text(
              l10n.vm_consoleConnecting,
              style: AppTextStyles.bodyM.copyWith(
                color: AppTokens.consoleMuted,
              ),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.vm_consoleFailed,
                style: AppTextStyles.titleM.copyWith(
                  color: AppTokens.consoleForeground,
                ),
              ),
              const SizedBox(height: AppTokens.s8),
              Text(
                describeError(_error!, l10n),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppTokens.consoleMuted,
                ),
              ),
              const SizedBox(height: AppTokens.s16),
              SecondaryButton(label: l10n.action_retry, onPressed: _connect),
            ],
          ),
        ),
      );
    }
    final frame = _frame;
    if (frame == null) {
      return const SizedBox.shrink();
    }
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        final keysym = VncClient.keySym(event.logicalKey);
        if (keysym == null) return KeyEventResult.ignored;
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          _client?.sendKey(keysym, true);
        } else if (event is KeyUpEvent) {
          _client?.sendKey(keysym, false);
        }
        return KeyEventResult.handled;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            constraints.maxWidth / frame.width,
            constraints.maxHeight / frame.height,
          );
          final width = frame.width * scale;
          final height = frame.height * scale;
          final left = (constraints.maxWidth - width) / 2;
          final top = (constraints.maxHeight - height) / 2;

          Offset remote(Offset local) => Offset(
            ((local.dx - left) / scale).clamp(0, frame.width - 1),
            ((local.dy - top) / scale).clamp(0, frame.height - 1),
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) {
              _buttonDown = true;
              final point = remote(details.localPosition);
              _lastRemote = point;
              _client?.sendPointer(point.dx.toInt(), point.dy.toInt(), 1);
            },
            onPanUpdate: (details) {
              final point = remote(details.localPosition);
              _lastRemote = point;
              _client?.sendPointer(
                point.dx.toInt(),
                point.dy.toInt(),
                _buttonDown ? 1 : 0,
              );
            },
            onPanEnd: (_) => _releasePointer(),
            onPanCancel: _releasePointer,
            child: Stack(
              children: [
                Positioned(
                  left: left,
                  top: top,
                  width: width,
                  height: height,
                  child: CustomPaint(painter: _VncPainter(frame.image)),
                ),
                Positioned(
                  left: AppTokens.s12,
                  right: AppTokens.s12,
                  bottom: AppTokens.s12,
                  child: Text(
                    l10n.vm_consoleHint,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTokens.consoleMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VncPainter extends CustomPainter {
  _VncPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  @override
  bool shouldRepaint(covariant _VncPainter oldDelegate) =>
      oldDelegate.image != image;
}

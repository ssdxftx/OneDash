import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

/// Resolves an app icon from a raw base64 payload, a data URI or a remote URL,
/// falling back to the first character of [name].
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.name,
    this.icon,
    this.size = AppTokens.iconBadge,
    this.cacheKey,
    this.iconLoader,
  });

  final String name;
  final String? icon;
  final double size;

  /// Stable key used to deduplicate remote icon requests.
  final String? cacheKey;

  /// Loads binary icon data when [icon] is empty or a relative path.
  final Future<Uint8List> Function()? iconLoader;

  static final Map<String, Uint8List?> _decoded = <String, Uint8List?>{};
  static final Map<String, Future<Uint8List?>> _remote =
      <String, Future<Uint8List?>>{};
  static const int _decodeCacheLimit = 64;

  String get _initial =>
      name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();

  @override
  Widget build(BuildContext context) {
    final pixelSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final resolved = _resolve(context, pixelSize);
    final Widget content;
    if (resolved != null) {
      content = resolved;
    } else if (iconLoader != null) {
      content = FutureBuilder<Uint8List?>(
        future: _remoteIcon(),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null || bytes.isEmpty) return _fallback(context);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            cacheWidth: pixelSize,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => _fallback(context),
          );
        },
      );
    } else {
      content = _fallback(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.rSm),
      child: SizedBox.square(dimension: size, child: content),
    );
  }

  Future<Uint8List?> _remoteIcon() {
    final key = cacheKey ?? name;
    final existing = _remote[key];
    if (existing != null) return existing;
    final future = iconLoader!()
        .then<Uint8List?>((bytes) => bytes.isEmpty ? null : bytes)
        .catchError((Object _) => null);
    if (_remote.length >= _decodeCacheLimit) _remote.clear();
    _remote[key] = future;
    return future;
  }

  Widget? _resolve(BuildContext context, int pixelSize) {
    final raw = icon?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return Image.network(
        raw,
        fit: BoxFit.cover,
        cacheWidth: pixelSize,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => _fallback(context),
      );
    }
    final bytes = _decode(raw);
    if (bytes == null || bytes.isEmpty) return null;
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      cacheWidth: pixelSize,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => _fallback(context),
    );
  }

  Uint8List? _decode(String raw) {
    if (_decoded.containsKey(raw)) return _decoded[raw];
    var payload = raw;
    final marker = payload.indexOf('base64,');
    if (marker >= 0) payload = payload.substring(marker + 7);
    Uint8List? bytes;
    try {
      bytes = base64Decode(payload.replaceAll(RegExp(r'\s'), ''));
    } on FormatException {
      bytes = null;
    }
    if (_decoded.length >= _decodeCacheLimit) _decoded.clear();
    _decoded[raw] = bytes;
    return bytes;
  }

  Widget _fallback(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: AppTextStyles.titleS.copyWith(color: scheme.onPrimaryContainer),
      ),
    );
  }
}

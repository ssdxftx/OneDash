import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasskeyException implements Exception {
  const PasskeyException(this.message, {this.code = ''});

  final String message;
  final String code;

  @override
  String toString() => message;
}

abstract interface class PasskeyAuthenticator {
  Future<Map<String, dynamic>> create(Map<String, dynamic> options);

  Future<Map<String, dynamic>> get(Map<String, dynamic> options);
}

class PasskeyService implements PasskeyAuthenticator {
  const PasskeyService();

  static const _channel = MethodChannel('dev.onedash.app/passkey');

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> options) =>
      _invoke('create', options);

  @override
  Future<Map<String, dynamic>> get(Map<String, dynamic> options) =>
      _invoke('get', options);

  Future<Map<String, dynamic>> _invoke(
    String method,
    Map<String, dynamic> options,
  ) async {
    try {
      final raw = await _channel.invokeMethod<String>(method, {
        'requestJson': jsonEncode(options),
      });
      if (raw == null || raw.isEmpty) {
        throw const PasskeyException('Passkey returned an empty response');
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const PasskeyException('Passkey returned an invalid response');
      }
      return Map<String, dynamic>.from(decoded);
    } on PlatformException catch (error) {
      throw PasskeyException(
        error.message ?? error.code,
        code: error.code,
      );
    } on MissingPluginException {
      throw const PasskeyException(
        'Passkey is only available in the Android app',
        code: 'unavailable',
      );
    }
  }
}

final passkeyServiceProvider = Provider<PasskeyAuthenticator>(
  (ref) => const PasskeyService(),
  name: 'passkeyServiceProvider',
);

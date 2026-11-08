import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations_en.dart';
import 'package:onedash/core/network/network_exceptions.dart';
import 'package:onedash/presentation/common/states/error_mapper.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('WebSocket 预检失败按错误码翻译', () {
    final data = mapError(
      const NetworkConnectionException(
        'WebSocket preflight failed',
        code: NetworkErrorCode.wsPreflightFailed,
      ),
      l10n,
    );
    expect(data.message, 'Failed to establish realtime connection');
  });

  test('WebSocket 预检超时按错误码翻译', () {
    final data = mapError(
      const NetworkConnectionException(
        'WebSocket preflight timed out',
        code: NetworkErrorCode.wsPreflightTimeout,
      ),
      l10n,
    );
    expect(data.message, 'Realtime connection timed out');
  });

  test('普通网络异常仍走通用网络文案', () {
    final data = mapError(
      const NetworkConnectionException('socket closed'),
      l10n,
    );
    expect(data.message, isNot('Failed to establish realtime connection'));
  });
}

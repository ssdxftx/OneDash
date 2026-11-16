import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/utils/log_sanitizer.dart';

void main() {
  test('sanitizes old and new password fields', () {
    final text = LogSanitizer.sanitize(
      '{"oldPassword":"old-secret","newPassword":"new-secret"}',
    );
    expect(text.contains('old-secret'), isFalse);
    expect(text.contains('new-secret'), isFalse);
    expect(text.contains('"oldPassword":"***"'), isTrue);
    expect(text.contains('"newPassword":"***"'), isTrue);
  });

  test('sanitizes map-style request bodies', () {
    final text = LogSanitizer.sanitize(
      '{name: admin, password: secret, oldPassword: old, apiKey: key}',
    );
    expect(text.contains('secret'), isFalse);
    expect(text.contains(': old,'), isFalse);
    expect(text.contains('password: ***'), isTrue);
    expect(text.contains('oldPassword: ***'), isTrue);
    expect(text.contains('apiKey: ***'), isTrue);
  });

  test('sanitizes backup credentials', () {
    final text = LogSanitizer.sanitize(
      '{"accessKey":"ak","credential":"sk","secret":"s"}',
    );
    expect(text.contains('ak'), isFalse);
    expect(text.contains('sk'), isFalse);
    expect(text.contains('"secret":"***"'), isTrue);
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> arb) {
  return arb.keys.where((key) => !key.startsWith('@')).toSet();
}

void main() {
  test('English and Chinese resources expose the same message keys', () {
    final en = _load('lib/core/localization/l10n/app_en.arb');
    final zh = _load('lib/core/localization/l10n/app_zh.arb');

    expect(_messageKeys(zh), _messageKeys(en));
  });

  test('every template message has resource metadata', () {
    const path = 'lib/core/localization/l10n/app_en.arb';
    final arb = _load(path);
    final missing = _messageKeys(
      arb,
    ).where((key) => !arb.containsKey('@$key')).toList()..sort();

    expect(missing, isEmpty, reason: '$path is missing metadata');
  });
}

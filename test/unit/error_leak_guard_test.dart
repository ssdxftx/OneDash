import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no raw exception interpolation reaches the UI', () {
    final violations = <String>[];
    final toastBlock = RegExp(r'AppToast\.error\([\s\S]{0,200}?\$error');
    final fieldAssignment = RegExp(r'''_error\s*=\s*['"]\$error['"]''');
    final textLiteral = RegExp(r'''Text\(\s*['"]\$error['"]''');

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      if (toastBlock.hasMatch(source) ||
          fieldAssignment.hasMatch(source) ||
          textLiteral.hasMatch(source)) {
        violations.add(entity.path);
      }
    }

    expect(violations, isEmpty, reason: 'Raw \$error found in $violations');
  });
}

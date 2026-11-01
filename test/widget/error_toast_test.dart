import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations_en.dart';
import 'package:onedash/core/network/network_exceptions.dart';
import 'package:onedash/presentation/common/states/error_toast.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('business exception keeps the server message only', () {
    final text = describeError(const ApiBusinessException(400, '分组不存在'), l10n);

    expect(text, contains('分组不存在'));
    expect(text, isNot(contains('DioException')));
    expect(text, isNot(contains('validateStatus')));
    expect(text, isNot(contains('Exception')));
  });

  test('unknown errors never leak object details', () {
    final text = describeError(StateError('internal stack trace marker'), l10n);

    expect(text.trim(), isNotEmpty);
    expect(text, isNot(contains('internal stack trace marker')));
  });

  test('task failure shows the panel log line', () {
    final text = describeError(
      const TaskFailedException(subject: '容器任务', detail: 'image not found'),
      l10n,
    );

    expect(text, contains('image not found'));
    expect(text, contains('Task failed'));
  });

  test('task timeout uses the timeout message', () {
    final text = describeError(
      const TaskFailedException(subject: '容器任务', timedOut: true),
      l10n,
    );

    expect(text, contains('Task timed out'));
    expect(text, contains('still running'));
  });
}

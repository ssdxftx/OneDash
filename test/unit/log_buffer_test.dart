import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/presentation/common/components/log_view.dart';

void main() {
  test('LogBuffer keeps insertion order', () {
    final buffer = LogBuffer(capacity: 3);
    buffer.addAll(['a', 'b', 'c']);
    expect(buffer.lines, ['a', 'b', 'c']);
  });

  test('LogBuffer drops the oldest lines when capacity is exceeded', () {
    final buffer = LogBuffer(capacity: 3);
    buffer.addAll(['a', 'b', 'c', 'd', 'e']);
    expect(buffer.lines, ['c', 'd', 'e']);
  });

  test('LogBuffer clear empties the buffer', () {
    final buffer = LogBuffer(capacity: 3);
    buffer.add('a');
    buffer.clear();
    expect(buffer.isEmpty, isTrue);
  });
}

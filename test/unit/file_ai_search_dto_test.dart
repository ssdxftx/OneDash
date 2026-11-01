import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/file/file_ai_search_dto.dart';

void main() {
  test('AI search DTO parses grep mode and hits', () {
    final dto = FileAiSearchResultDto.fromJson({
      'mode': 'grep',
      'summary': '',
      'hits': [
        {'path': '/tmp/a.txt', 'line': 3, 'text': 'needle'},
      ],
      'contentScannedFiles': 4,
      'truncated': true,
      'itemCount': 10,
      'duration': '2ms',
    });

    expect(dto.isAi, isFalse);
    expect(dto.hits.single.path, '/tmp/a.txt');
    expect(dto.hits.single.line, 3);
    expect(dto.contentScannedFiles, 4);
    expect(dto.truncated, isTrue);
  });

  test('AI search DTO parses AI mode and tolerates null hits', () {
    final ai = FileAiSearchResultDto.fromJson({
      'mode': 'ai',
      'summary': 'Found one match',
      'totalTokens': 120,
    });
    final empty = FileAiSearchResultDto.fromJson({'hits': null});

    expect(ai.isAi, isTrue);
    expect(ai.summary, 'Found one match');
    expect(ai.totalTokens, 120);
    expect(empty.hits, isEmpty);
  });
}

/// `/files/ai-search` 响应。
class FileAiSearchResultDto {
  const FileAiSearchResultDto({
    this.mode = '',
    this.summary = '',
    this.hits = const [],
    this.contentScannedFiles = 0,
    this.contentHitsTruncated = false,
    this.truncated = false,
    this.preFiltered = false,
    this.itemCount = 0,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
    this.duration = '',
  });

  final String mode;
  final String summary;
  final List<FileAiSearchHitDto> hits;
  final int contentScannedFiles;
  final bool contentHitsTruncated;
  final bool truncated;
  final bool preFiltered;
  final int itemCount;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final String duration;

  bool get isAi => mode == 'ai';

  factory FileAiSearchResultDto.fromJson(Map<String, dynamic> json) {
    return FileAiSearchResultDto(
      mode: json['mode'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      hits: switch (json['hits']) {
        final List rows =>
          rows
              .whereType<Map>()
              .map(
                (row) =>
                    FileAiSearchHitDto.fromJson(row.cast<String, dynamic>()),
              )
              .toList(growable: false),
        _ => const [],
      },
      contentScannedFiles: (json['contentScannedFiles'] as num?)?.toInt() ?? 0,
      contentHitsTruncated: json['contentHitsTruncated'] as bool? ?? false,
      truncated: json['truncated'] as bool? ?? false,
      preFiltered: json['preFiltered'] as bool? ?? false,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      promptTokens: (json['promptTokens'] as num?)?.toInt() ?? 0,
      completionTokens: (json['completionTokens'] as num?)?.toInt() ?? 0,
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
      duration: json['duration'] as String? ?? '',
    );
  }
}

class FileAiSearchHitDto {
  const FileAiSearchHitDto({this.path = '', this.line = 0, this.text = ''});

  final String path;
  final int line;
  final String text;

  factory FileAiSearchHitDto.fromJson(Map<String, dynamic> json) {
    return FileAiSearchHitDto(
      path: json['path'] as String? ?? '',
      line: (json['line'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
    );
  }
}

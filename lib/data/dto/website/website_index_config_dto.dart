/// 网站「默认文档」配置（nginx index scope）。
class WebsiteIndexConfigDto {
  const WebsiteIndexConfigDto({required this.enable, required this.indexFiles});

  final bool enable;
  final List<String> indexFiles;

  factory WebsiteIndexConfigDto.fromJson(Map<String, dynamic> json) {
    final enable = json['enable'] as bool? ?? true;
    final rawParams = json['params'];
    var files = <String>[];
    if (rawParams is List) {
      for (final p in rawParams) {
        if (p is! Map<String, dynamic>) continue;
        if (p['name']?.toString() != 'index') continue;
        final inner = p['params'];
        if (inner is List) {
          files = inner.map((e) => e.toString()).toList(growable: false);
        }
        break;
      }
    }
    return WebsiteIndexConfigDto(enable: enable, indexFiles: files);
  }
}

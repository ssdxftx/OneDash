class AppCatalogDto {
  const AppCatalogDto({
    required this.id,
    required this.name,
    required this.key,
    required this.description,
    required this.icon,
    required this.status,
    required this.installed,
    required this.limit,
    required this.tags,
    required this.gpuSupport,
    required this.recommend,
    required this.type,
    required this.batchInstallSupport,
    required this.versions,
  });

  final int id;
  final String name;
  final String key;
  final String description;
  final String? icon;
  final String status;
  final bool installed;
  final int limit;
  final List<String> tags;
  final bool gpuSupport;
  final int recommend;
  final String type;
  final bool batchInstallSupport;
  final List<String> versions;

  factory AppCatalogDto.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'] as List?;
    final rawVersions = json['versions'] as List?;
    return AppCatalogDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      key: json['key'] as String? ?? '',
      description: json['description'] as String? ?? '',
      // Compatibility: 1Panel v2.0.0 returns a base64 icon directly from
      // /api/v2/apps/search. Newer versions may require /apps/icon/{key}.
      icon: json['icon']?.toString(),
      status: json['status'] as String? ?? '',
      installed: json['installed'] as bool? ?? false,
      limit: json['limit'] as int? ?? 0,
      tags: rawTags?.map(_tagText).toList(growable: false) ?? const [],
      gpuSupport: json['gpuSupport'] as bool? ?? false,
      recommend: json['recommend'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      batchInstallSupport: json['batchInstallSupport'] as bool? ?? false,
      versions:
          rawVersions?.map((item) => item.toString()).toList(growable: false) ??
          const [],
    );
  }
}

String _tagText(Object? item) {
  // Compatibility: 1Panel v2.0.0 returns tags as objects:
  // {id, key, name}. Older/newer responses may return plain strings.
  if (item is Map) {
    final name = item['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    final key = item['key']?.toString().trim();
    if (key != null && key.isNotEmpty) return key;
  }
  return item?.toString() ?? '';
}

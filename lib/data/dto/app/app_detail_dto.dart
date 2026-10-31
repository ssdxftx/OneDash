import 'app_tag_dto.dart';

class AppDetailDto {
  const AppDetailDto({
    required this.id,
    required this.name,
    required this.key,
    required this.shortDescZh,
    required this.shortDescEn,
    required this.description,
    required this.icon,
    required this.type,
    required this.status,
    required this.crossVersionUpdate,
    required this.limit,
    required this.website,
    required this.github,
    required this.document,
    required this.recommend,
    required this.resource,
    required this.readMe,
    required this.architectures,
    required this.memoryRequired,
    required this.gpuSupport,
    required this.batchInstallSupport,
    required this.installed,
    required this.versions,
    required this.tags,
  });

  final int id;
  final String name;
  final String key;
  final String shortDescZh;
  final String shortDescEn;
  final String description;
  final String icon;
  final String type;
  final String status;
  final bool crossVersionUpdate;
  final int limit;
  final String website;
  final String github;
  final String document;
  final int recommend;
  final String resource;
  final String readMe;
  final String architectures;
  final int memoryRequired;
  final bool gpuSupport;
  final bool batchInstallSupport;
  final bool installed;
  final List<String> versions;
  final List<AppTagDto> tags;

  factory AppDetailDto.fromJson(Map<String, dynamic> json) {
    final rawVersions = json['versions'] as List?;
    final rawTags = json['tags'] as List?;

    return AppDetailDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      key: json['key'] as String? ?? '',
      shortDescZh: json['shortDescZh'] as String? ?? '',
      shortDescEn: json['shortDescEn'] as String? ?? '',
      description: json['description'] as String? ?? '',
      // Compatibility: 1Panel v2.0.0 returns a base64 icon directly from
      // /api/v2/apps/{key}. Newer versions may require /apps/icon/{key}.
      icon: json['icon']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      crossVersionUpdate: json['crossVersionUpdate'] as bool? ?? false,
      limit: json['limit'] as int? ?? 0,
      website: json['website'] as String? ?? '',
      github: json['github'] as String? ?? '',
      document: json['document'] as String? ?? '',
      recommend: json['recommend'] as int? ?? 0,
      resource: json['resource'] as String? ?? '',
      readMe: json['readMe'] as String? ?? '',
      architectures: json['architectures'] as String? ?? '',
      memoryRequired: json['memoryRequired'] as int? ?? 0,
      gpuSupport: json['gpuSupport'] as bool? ?? false,
      batchInstallSupport: json['batchInstallSupport'] as bool? ?? false,
      installed: json['installed'] as bool? ?? false,
      versions: rawVersions?.map((e) => e.toString()).toList() ?? const [],
      tags:
          rawTags
              ?.map((e) => AppTagDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

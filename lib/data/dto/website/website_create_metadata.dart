import 'website_group_dto.dart';

class WebsiteCreateMetadata {
  const WebsiteCreateMetadata({
    required this.websiteRootDir,
    required this.groups,
  });

  final String websiteRootDir;
  final List<WebsiteGroupDto> groups;

  String get sitesRootDir {
    if (websiteRootDir.isEmpty) return '/sites';
    return '$websiteRootDir/sites';
  }

  WebsiteGroupDto? get defaultGroup {
    for (final group in groups) {
      if (group.isDefault) return group;
    }
    return groups.isEmpty ? null : groups.first;
  }
}

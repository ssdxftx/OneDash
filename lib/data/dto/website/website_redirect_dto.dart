class WebsiteRedirectDto {
  const WebsiteRedirectDto({
    required this.websiteID,
    required this.name,
    this.domains = const [],
    this.keepPath = true,
    this.enable = false,
    this.type = 'domain',
    this.redirect = '301',
    this.path = '',
    this.target = '',
    this.filePath = '',
    this.content = '',
    this.redirectRoot = false,
  });

  final int websiteID;
  final String name;
  final List<String> domains;
  final bool keepPath;
  final bool enable;
  final String type;
  final String redirect;
  final String path;
  final String target;
  final String filePath;
  final String content;
  final bool redirectRoot;

  factory WebsiteRedirectDto.fromJson(Map<String, dynamic> json) {
    return WebsiteRedirectDto(
      websiteID: json['websiteID'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      domains:
          (json['domains'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      keepPath: json['keepPath'] as bool? ?? true,
      enable: json['enable'] as bool? ?? false,
      type: json['type'] as String? ?? 'domain',
      redirect: json['redirect'] as String? ?? '301',
      path: json['path'] as String? ?? '',
      target: json['target'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      content: json['content'] as String? ?? '',
      redirectRoot: json['redirectRoot'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteID': websiteID,
      'name': name,
      'domains': domains,
      'keepPath': keepPath,
      'enable': enable,
      'type': type,
      'redirect': redirect,
      'path': path,
      'target': target,
      'filePath': filePath,
      'content': content,
      'redirectRoot': redirectRoot,
    };
  }
}

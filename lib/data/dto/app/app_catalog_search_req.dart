class AppCatalogSearchReq {
  const AppCatalogSearchReq({
    required this.page,
    required this.pageSize,
    this.type,
    this.tags = const [],
    this.name = '',
    this.resource = 'all',
    this.showCurrentArch = false,
  });

  final int page;
  final int pageSize;
  final String? type;
  final List<String> tags;
  final String name;
  final String resource;
  final bool showCurrentArch;

  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
    if (type != null) 'type': type,
    'tags': tags,
    'name': name,
    'resource': resource,
    'showCurrentArch': showCurrentArch,
  };
}

class AppInstalledSearchReq {
  const AppInstalledSearchReq({
    required this.page,
    required this.pageSize,
    this.name = '',
    this.tags = const [],
    this.update = false,
    this.sync = true,
  });

  final int page;
  final int pageSize;
  final String name;
  final List<String> tags;
  final bool update;
  final bool sync;

  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
    'name': name,
    'tags': tags,
    'update': update,
    'sync': sync,
  };
}

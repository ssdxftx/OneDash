class WebsiteDirDto {
  const WebsiteDirDto({
    required this.dirs,
    required this.user,
    required this.userGroup,
    required this.msg,
  });

  final List<String> dirs;
  final String user;
  final String userGroup;
  final String msg;

  factory WebsiteDirDto.fromJson(Map<String, dynamic> json) {
    final dirsJson = json['dirs'] as List?;
    return WebsiteDirDto(
      dirs: dirsJson?.whereType<String>().toList(growable: false) ?? const [],
      user: json['user']?.toString() ?? '',
      userGroup: json['userGroup']?.toString() ?? '',
      msg: json['msg'] as String? ?? '',
    );
  }
}

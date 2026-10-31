/// 文件搜索结果中的单个文件/目录项。
class FileItemDto {
  const FileItemDto({
    required this.path,
    required this.name,
    required this.user,
    required this.group,
    required this.uid,
    required this.gid,
    required this.extension,
    required this.content,
    required this.size,
    required this.isDir,
    required this.isSymlink,
    required this.isHidden,
    required this.linkPath,
    required this.type,
    required this.mode,
    required this.mimeType,
    required this.modTime,
    required this.items,
    required this.itemTotal,
    required this.favoriteID,
    required this.isDetail,
    this.shareCode = '',
  });

  final String path;
  final String name;
  final String user;
  final String group;
  final String uid;
  final String gid;
  final String extension;
  final String content;
  final int size;
  final bool isDir;
  final bool isSymlink;
  final bool isHidden;
  final String linkPath;
  final String type;
  final String mode;
  final String mimeType;
  final String modTime;
  final List<FileItemDto>? items;
  final int itemTotal;
  final int favoriteID;
  final bool isDetail;
  final String shareCode;

  FileItemDto copyWith({
    String? path,
    String? name,
    String? user,
    String? group,
    String? uid,
    String? gid,
    String? extension,
    String? content,
    int? size,
    bool? isDir,
    bool? isSymlink,
    bool? isHidden,
    String? linkPath,
    String? type,
    String? mode,
    String? mimeType,
    String? modTime,
    List<FileItemDto>? items,
    int? itemTotal,
    int? favoriteID,
    bool? isDetail,
    String? shareCode,
  }) {
    return FileItemDto(
      path: path ?? this.path,
      name: name ?? this.name,
      user: user ?? this.user,
      group: group ?? this.group,
      uid: uid ?? this.uid,
      gid: gid ?? this.gid,
      extension: extension ?? this.extension,
      content: content ?? this.content,
      size: size ?? this.size,
      isDir: isDir ?? this.isDir,
      isSymlink: isSymlink ?? this.isSymlink,
      isHidden: isHidden ?? this.isHidden,
      linkPath: linkPath ?? this.linkPath,
      type: type ?? this.type,
      mode: mode ?? this.mode,
      mimeType: mimeType ?? this.mimeType,
      modTime: modTime ?? this.modTime,
      items: items ?? this.items,
      itemTotal: itemTotal ?? this.itemTotal,
      favoriteID: favoriteID ?? this.favoriteID,
      isDetail: isDetail ?? this.isDetail,
      shareCode: shareCode ?? this.shareCode,
    );
  }

  factory FileItemDto.fromJson(Map<String, dynamic> json) {
    return FileItemDto(
      path: json['path'] as String? ?? '',
      name: json['name'] as String? ?? '',
      user: json['user'] as String? ?? '',
      group: json['group'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      gid: json['gid'] as String? ?? '',
      extension: json['extension'] as String? ?? '',
      content: json['content'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      isDir: json['isDir'] as bool? ?? false,
      isSymlink: json['isSymlink'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
      linkPath: json['linkPath'] as String? ?? '',
      type: json['type'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      modTime: json['modTime'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => FileItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemTotal: json['itemTotal'] as int? ?? 0,
      favoriteID: json['favoriteID'] as int? ?? 0,
      isDetail: json['isDetail'] as bool? ?? false,
      shareCode: json['shareCode'] as String? ?? '',
    );
  }
}

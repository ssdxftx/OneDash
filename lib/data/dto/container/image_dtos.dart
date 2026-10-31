class DockerImageInfo {
  const DockerImageInfo({
    required this.id,
    required this.createdAt,
    required this.isUsed,
    required this.tags,
    required this.size,
    this.description,
    this.isPinned,
  });

  final String id;
  final String createdAt;
  final bool isUsed;
  final List<String> tags;
  final dynamic size;
  final String? description;
  final bool? isPinned;

  factory DockerImageInfo.fromJson(Map<String, dynamic> json) {
    return DockerImageInfo(
      id: json['id'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      isUsed: json['isUsed'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      size: json['size'],
      description: json['description'] as String?,
      isPinned: json['isPinned'] as bool?,
    );
  }
}

class ImageRepoDto {
  const ImageRepoDto({
    required this.id,
    required this.name,
    required this.downloadUrl,
    this.protocol = 'https',
    this.auth = false,
    this.username = '',
    this.password = '',
    this.status = '',
    this.message = '',
    this.createdAt = '',
  });

  final int id;
  final String name;
  final String downloadUrl;
  final String protocol;
  final bool auth;
  final String username;
  final String password;
  final String status;
  final String message;
  final String createdAt;

  bool get isBuiltIn => id == 1;

  factory ImageRepoDto.fromJson(Map<String, dynamic> json) {
    return ImageRepoDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      protocol: json['protocol'] as String? ?? 'https',
      auth: json['auth'] as bool? ?? false,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'downloadUrl': downloadUrl,
    'protocol': protocol,
    'auth': auth,
    'username': username,
    'password': password,
  };
}

class ImageRepoSearchDto {
  const ImageRepoSearchDto({required this.total, required this.items});

  final int total;
  final List<ImageRepoDto> items;

  factory ImageRepoSearchDto.fromJson(Map<String, dynamic> json) {
    return ImageRepoSearchDto(
      total: json['total'] is num
          ? (json['total'] as num).toInt()
          : int.tryParse(json['total']?.toString() ?? '') ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ImageRepoDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class PageImageReq {
  const PageImageReq({
    this.page = 1,
    this.pageSize = 20,
    this.name = '',
    this.orderBy = 'createdAt',
    this.order = 'descending',
  });

  final int page;
  final int pageSize;
  final String name;
  final String orderBy;
  final String order;

  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
    'name': name,
    'orderBy': orderBy,
    'order': order,
  };
}

class ImageBuildReq {
  const ImageBuildReq({
    this.taskID,
    required this.from,
    required this.name,
    required this.dockerfile,
    this.tags = const [],
    this.args = const [],
  });

  final String? taskID;
  final String from;
  final String name;
  final String dockerfile;
  final List<String> tags;
  final List<String> args;

  Map<String, dynamic> toJson() => {
    if (taskID != null) 'taskID': taskID,
    'from': from,
    'name': name,
    'dockerfile': dockerfile,
    if (tags.isNotEmpty) 'tags': tags,
    if (args.isNotEmpty) 'args': args,
  };
}

class ImagePullReq {
  const ImagePullReq({this.taskID, this.repoID = 0, required this.imageName});

  final String? taskID;
  final int repoID;
  final List<String> imageName;

  Map<String, dynamic> toJson() => {
    if (taskID != null) 'taskID': taskID,
    'repoID': repoID,
    'imageName': imageName,
  };
}

class ImagePushReq {
  const ImagePushReq({
    this.taskID,
    required this.repoID,
    required this.tagName,
    required this.name,
  });

  final String? taskID;
  final int repoID;
  final String tagName;
  final String name;

  Map<String, dynamic> toJson() => {
    if (taskID != null) 'taskID': taskID,
    'repoID': repoID,
    'tagName': tagName,
    'name': name,
  };
}

class BatchDeleteReq {
  const BatchDeleteReq({this.taskID, this.force = false, required this.names});

  final String? taskID;
  final bool force;
  final List<String> names;

  Map<String, dynamic> toJson() => {
    if (taskID != null) 'taskID': taskID,
    'force': force,
    'names': names,
  };
}

class ImageSaveReq {
  const ImageSaveReq({
    this.taskID,
    required this.tagName,
    required this.path,
    required this.name,
  });

  final String? taskID;
  final String tagName;
  final String path;
  final String name;

  Map<String, dynamic> toJson() => {
    if (taskID != null) 'taskID': taskID,
    'tagName': tagName,
    'path': path,
    'name': name,
  };
}

class ImageTagReq {
  const ImageTagReq({required this.sourceID, required this.tags});

  final String sourceID;
  final List<String> tags;

  Map<String, dynamic> toJson() => {'sourceID': sourceID, 'tags': tags};
}

class ImageLoadReq {
  const ImageLoadReq({this.taskID, required this.paths});

  final String? taskID;
  final List<String> paths;

  Map<String, dynamic> toJson() => {
    if (taskID != null) 'taskID': taskID,
    'paths': paths,
  };
}

class WebsiteAuthItemDto {
  const WebsiteAuthItemDto({
    required this.username,
    required this.password,
    required this.remark,
  });

  final String username;
  final String password;
  final String remark;

  factory WebsiteAuthItemDto.fromJson(Map<String, dynamic> json) {
    return WebsiteAuthItemDto(
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'remark': remark,
  };
}

class WebsiteAuthDto {
  const WebsiteAuthDto({required this.enable, required this.items});

  final bool enable;
  final List<WebsiteAuthItemDto>? items;

  factory WebsiteAuthDto.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List?;
    return WebsiteAuthDto(
      enable: json['enable'] as bool? ?? false,
      items: itemsJson
          ?.whereType<Map<String, dynamic>>()
          .map(WebsiteAuthItemDto.fromJson)
          .toList(),
    );
  }
}

class WebsitePathAuthItemDto {
  const WebsitePathAuthItemDto({
    required this.id,
    required this.websiteId,
    required this.path,
    required this.name,
    required this.username,
    required this.password,
    required this.remark,
  });

  final int id;
  final int websiteId;
  final String path;
  final String name;
  final String username;
  final String password;
  final String remark;

  factory WebsitePathAuthItemDto.fromJson(Map<String, dynamic> json) {
    return WebsitePathAuthItemDto(
      id: json['id'] as int? ?? 0,
      websiteId: json['websiteID'] as int? ?? 0,
      path: json['path'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
    );
  }
}

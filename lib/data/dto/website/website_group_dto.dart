class WebsiteGroupDto {
  const WebsiteGroupDto({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
  });

  final int id;
  final String name;
  final String type;
  final bool isDefault;

  factory WebsiteGroupDto.fromJson(Map<String, dynamic> json) {
    return WebsiteGroupDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'isDefault': isDefault,
  };

  WebsiteGroupDto copyWith({
    int? id,
    String? name,
    String? type,
    bool? isDefault,
  }) {
    return WebsiteGroupDto(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

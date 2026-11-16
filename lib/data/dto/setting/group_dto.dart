class CoreGroupDto {
  const CoreGroupDto({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
  });

  final int id;
  final String name;
  final String type;
  final bool isDefault;

  factory CoreGroupDto.fromJson(Map<String, dynamic> json) {
    return CoreGroupDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

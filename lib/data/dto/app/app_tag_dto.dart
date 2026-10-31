class AppTagDto {
  const AppTagDto({required this.id, required this.key, required this.name});

  final int id;
  final String key;
  final String name;

  factory AppTagDto.fromJson(Map<String, dynamic> json) {
    return AppTagDto(
      id: json['id'] as int? ?? 0,
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class OllamaModelDto {
  const OllamaModelDto({
    required this.id,
    required this.name,
    required this.size,
    required this.from,
    required this.logFileExist,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String size;
  final String from;
  final bool logFileExist;
  final String status;
  final String message;
  final String createdAt;

  factory OllamaModelDto.fromJson(Map<String, dynamic> json) {
    return OllamaModelDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      size: '${json['size'] ?? ''}',
      from: json['from'] as String? ?? '',
      logFileExist: json['logFileExist'] == true,
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

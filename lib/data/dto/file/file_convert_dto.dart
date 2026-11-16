class FileUploadDto {
  const FileUploadDto({
    required this.name,
    required this.size,
    required this.createdAt,
  });

  final String name;
  final int size;
  final String createdAt;

  factory FileUploadDto.fromJson(Map<String, dynamic> json) {
    return FileUploadDto(
      name: json['name']?.toString() ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class FileConvertLogDto {
  const FileConvertLogDto({
    required this.date,
    required this.type,
    required this.log,
    required this.status,
    required this.message,
  });

  final String date;
  final String type;
  final String log;
  final String status;
  final String message;

  factory FileConvertLogDto.fromJson(Map<String, dynamic> json) {
    return FileConvertLogDto(
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      log: json['log']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

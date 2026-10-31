class FileShareDto {
  final String code;
  final String path;
  final String fileName;
  final int expiresAt;
  final bool permanent;
  final bool hasPassword;
  final String? password;

  FileShareDto({
    required this.code,
    required this.path,
    required this.fileName,
    required this.expiresAt,
    required this.permanent,
    required this.hasPassword,
    this.password,
  });

  factory FileShareDto.fromJson(Map<String, dynamic> json) {
    return FileShareDto(
      code: json['code'] as String? ?? '',
      path: json['path'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      expiresAt: json['expiresAt'] as int? ?? 0,
      permanent: json['permanent'] as bool? ?? false,
      hasPassword: json['hasPassword'] as bool? ?? false,
      password: json['password'] as String?,
    );
  }
}

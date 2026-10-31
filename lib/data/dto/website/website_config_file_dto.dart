class WebsiteConfigFileDto {
  const WebsiteConfigFileDto({required this.path, required this.content});

  final String path;
  final String content;

  factory WebsiteConfigFileDto.fromJson(Map<String, dynamic> json) {
    return WebsiteConfigFileDto(
      path: json['path']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}

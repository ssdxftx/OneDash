class OpenRestyPerformanceItemDto {
  const OpenRestyPerformanceItemDto({required this.name, required this.params});

  final String name;
  final List<String> params;

  factory OpenRestyPerformanceItemDto.fromJson(Map<String, dynamic> json) {
    return OpenRestyPerformanceItemDto(
      name: json['name'] as String? ?? '',
      params: (json['params'] as List?)?.cast<String>() ?? [],
    );
  }
}

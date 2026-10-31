class ComposeTemplateSearchDto {
  const ComposeTemplateSearchDto({required this.total, required this.items});

  factory ComposeTemplateSearchDto.fromJson(Map<String, dynamic> json) {
    return ComposeTemplateSearchDto(
      total: _intValue(json['total']),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => ComposeTemplateDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  final int total;
  final List<ComposeTemplateDto> items;

  Map<String, dynamic> toJson() => {
    'total': total,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class ComposeTemplateDto {
  const ComposeTemplateDto({
    required this.id,
    required this.name,
    required this.description,
    required this.content,
    required this.createdAt,
  });

  factory ComposeTemplateDto.fromJson(Map<String, dynamic> json) {
    return ComposeTemplateDto(
      id: _intValue(json['id']),
      name: _stringValue(json['name']),
      description: _stringValue(json['description']),
      content: _stringValue(json['content']),
      createdAt: _stringValue(json['createdAt']),
    );
  }

  final int id;
  final String name;
  final String description;
  final String content;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'content': content,
    'createdAt': createdAt,
  };
}

int _intValue(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _stringValue(Object? value) => value?.toString() ?? '';

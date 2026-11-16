class ScriptLibraryDto {
  const ScriptLibraryDto({
    required this.id,
    required this.name,
    required this.isInteractive,
    required this.lable,
    required this.script,
    required this.groupList,
    required this.groupBelong,
    required this.isSystem,
    required this.description,
    required this.createdAt,
  });

  final int id;
  final String name;
  final bool isInteractive;
  final String lable;
  final String script;
  final List<int> groupList;
  final List<String> groupBelong;
  final bool isSystem;
  final String description;
  final String createdAt;

  factory ScriptLibraryDto.fromJson(Map<String, dynamic> json) {
    return ScriptLibraryDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      isInteractive: json['isInteractive'] as bool? ?? false,
      lable: json['lable'] as String? ?? '',
      script: json['script'] as String? ?? '',
      groupList: (json['groupList'] as List? ?? const [])
          .whereType<num>()
          .map((item) => item.toInt())
          .toList(growable: false),
      groupBelong: (json['groupBelong'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      isSystem: json['isSystem'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

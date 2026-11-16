class CommandLibraryDto {
  const CommandLibraryDto({
    required this.id,
    required this.groupId,
    required this.name,
    required this.type,
    required this.command,
    required this.groupBelong,
  });

  final int id;
  final int groupId;
  final String name;
  final String type;
  final String command;
  final String groupBelong;

  factory CommandLibraryDto.fromJson(Map<String, dynamic> json) {
    return CommandLibraryDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      groupId: (json['groupID'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      command: json['command'] as String? ?? '',
      groupBelong: json['groupBelong'] as String? ?? '',
    );
  }
}

class CommandTreeDto {
  const CommandTreeDto({
    required this.label,
    required this.value,
    required this.children,
  });

  final String label;
  final String value;
  final List<CommandTreeDto> children;

  factory CommandTreeDto.fromJson(Map<String, dynamic> json) {
    return CommandTreeDto(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      children: (json['children'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => CommandTreeDto.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}

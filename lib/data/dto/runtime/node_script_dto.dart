class NodeScriptDto {
  const NodeScriptDto({required this.name, required this.script});

  final String name;
  final String script;

  factory NodeScriptDto.fromJson(Map<String, dynamic> json) {
    return NodeScriptDto(
      name: json['name'] as String? ?? '',
      script: json['script'] as String? ?? '',
    );
  }
}

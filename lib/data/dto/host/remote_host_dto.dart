class RemoteHostDto {
  const RemoteHostDto(this.json);

  final Map<String, dynamic> json;

  int get id => (json['id'] as num?)?.toInt() ?? 0;
  int get groupId => (json['groupID'] as num?)?.toInt() ?? 0;
  String get groupBelong => '${json['groupBelong'] ?? ''}';
  String get name => '${json['name'] ?? ''}';
  String get addr => '${json['addr'] ?? ''}';
  int get port => (json['port'] as num?)?.toInt() ?? 22;
  String get user => '${json['user'] ?? ''}';
  String get authMode => '${json['authMode'] ?? 'password'}';
  String get description => '${json['description'] ?? ''}';
  bool get rememberPassword => json['rememberPassword'] == true;

  factory RemoteHostDto.fromJson(Map<String, dynamic> json) =>
      RemoteHostDto(json);
}

class RemoteHostTreeDto {
  const RemoteHostTreeDto(this.json);

  final Map<String, dynamic> json;

  int get id => (json['id'] as num?)?.toInt() ?? 0;
  String get label => '${json['label'] ?? ''}';
  List<RemoteHostTreeDto> get children =>
      (json['children'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => RemoteHostTreeDto(Map<String, dynamic>.from(item)))
          .toList(growable: false);

  factory RemoteHostTreeDto.fromJson(Map<String, dynamic> json) =>
      RemoteHostTreeDto(json);
}

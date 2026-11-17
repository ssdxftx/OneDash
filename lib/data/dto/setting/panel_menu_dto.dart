import 'dart:convert';

class PanelMenuNode {
  const PanelMenuNode({
    required this.id,
    required this.label,
    required this.disabled,
    required this.isShow,
    required this.title,
    required this.path,
    required this.sort,
    required this.children,
  });

  final String id;
  final String label;
  final bool disabled;
  final bool isShow;
  final String title;
  final String path;
  final int sort;
  final List<PanelMenuNode> children;

  factory PanelMenuNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return PanelMenuNode(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      disabled: json['disabled'] == true,
      isShow: json['isShow'] != false,
      title: json['title']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      children: rawChildren is List
          ? rawChildren
                .whereType<Map<String, dynamic>>()
                .map(PanelMenuNode.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  PanelMenuNode copyWith({
    bool? isShow,
    List<PanelMenuNode>? children,
    int? sort,
  }) {
    return PanelMenuNode(
      id: id,
      label: label,
      disabled: disabled,
      isShow: isShow ?? this.isShow,
      title: title,
      path: path,
      sort: sort ?? this.sort,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'disabled': disabled,
    'isShow': isShow,
    'title': title,
    if (path.isNotEmpty) 'path': path,
    'sort': sort,
    if (children.isNotEmpty)
      'children': children.map((child) => child.toJson()).toList(),
  };

  static List<PanelMenuNode> listFromJsonString(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];
    final decoded = jsonDecode(trimmed);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PanelMenuNode.fromJson)
        .toList(growable: false);
  }

  static String encodeList(List<PanelMenuNode> nodes) =>
      jsonEncode(nodes.map((node) => node.toJson()).toList());
}

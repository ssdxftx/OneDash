const _cleanTreeGroups = [
  'systemClean',
  'backupClean',
  'uploadClean',
  'downloadClean',
  'systemLogClean',
  'containerClean',
];

List<Map<String, dynamic>> collectCleanItems(Map<String, dynamic> scan) {
  final items = <Map<String, dynamic>>[];

  void collect(Object? node) {
    if (node is! Map) return;
    if (node['canDelete'] == true && node['isCheck'] == true) {
      final type = '${node['type'] ?? ''}';
      final name = '${node['name'] ?? ''}';
      if (type.isNotEmpty && name.isNotEmpty) {
        items.add({'treeType': type, 'name': name, 'size': node['size'] ?? 0});
      }
    }
    final children = node['children'];
    if (children is List) {
      for (final child in children) {
        collect(child);
      }
    }
  }

  for (final group in _cleanTreeGroups) {
    final children = scan[group];
    if (children is! List) continue;
    for (final item in children) {
      collect(item);
    }
  }
  return items;
}

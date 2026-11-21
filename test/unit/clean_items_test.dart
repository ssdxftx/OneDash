import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/presentation/features/toolbox/clean_items.dart';

void main() {
  test('clean items require both canDelete and isCheck', () {
    final items = collectCleanItems({
      'systemClean': [
        {
          'type': 'task_log',
          'name': 'task.log',
          'size': 10,
          'canDelete': true,
          'isCheck': false,
        },
        {
          'type': 'upgrade',
          'name': 'backup.tar.gz',
          'size': 20,
          'canDelete': true,
          'isCheck': true,
        },
        {
          'type': 'locked',
          'name': 'locked.log',
          'size': 30,
          'canDelete': false,
          'isCheck': true,
        },
        {
          'type': 'group',
          'name': 'group',
          'canDelete': true,
          'isCheck': true,
          'children': [
            {
              'type': 'cache',
              'name': 'cache.bin',
              'size': 40,
              'canDelete': true,
              'isCheck': true,
            },
          ],
        },
      ],
    });

    expect(items, [
      {'treeType': 'upgrade', 'name': 'backup.tar.gz', 'size': 20},
      {'treeType': 'group', 'name': 'group', 'size': 0},
      {'treeType': 'cache', 'name': 'cache.bin', 'size': 40},
    ]);
  });

  test('clean items ignore unknown groups and malformed nodes', () {
    final items = collectCleanItems({
      'unknown': [
        {
          'type': 'cache',
          'name': 'cache.bin',
          'canDelete': true,
          'isCheck': true,
        },
      ],
      'backupClean': [
        null,
        {'type': '', 'name': 'empty', 'canDelete': true, 'isCheck': true},
        {'type': 'cache', 'name': '', 'canDelete': true, 'isCheck': true},
      ],
    });

    expect(items, isEmpty);
  });
}

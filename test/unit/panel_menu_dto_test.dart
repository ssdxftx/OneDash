import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/setting/panel_menu_dto.dart';

void main() {
  test('panel menu nodes preserve hierarchy and visibility', () {
    final nodes = PanelMenuNode.listFromJsonString('''
    [
      {
        "id": "App-Menu",
        "label": "App-Menu",
        "disabled": false,
        "isShow": true,
        "title": "Apps",
        "sort": 100,
        "children": [
          {
            "id": "app-installed",
            "label": "app-installed",
            "disabled": false,
            "isShow": false,
            "title": "Installed",
            "sort": 100
          }
        ]
      }
    ]
    ''');

    expect(nodes, hasLength(1));
    expect(nodes.single.children, hasLength(1));
    expect(nodes.single.children.single.isShow, isFalse);

    final roundTrip = PanelMenuNode.listFromJsonString(
      PanelMenuNode.encodeList(nodes),
    );
    expect(roundTrip.single.id, 'App-Menu');
    expect(roundTrip.single.children.single.title, 'Installed');
    expect(roundTrip.single.children.single.isShow, isFalse);
  });

  test('empty panel menu input returns an empty list', () {
    expect(PanelMenuNode.listFromJsonString(''), isEmpty);
    expect(PanelMenuNode.listFromJsonString('{}'), isEmpty);
  });
}

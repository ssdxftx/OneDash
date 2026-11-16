import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/vnc_client.dart';

void main() {
  test('maps common keys to VNC keysyms', () {
    expect(VncClient.keySym(LogicalKeyboardKey.keyA), 0x61);
    expect(VncClient.keySym(LogicalKeyboardKey.digit1), 0x31);
    expect(VncClient.keySym(LogicalKeyboardKey.enter), 0xff0d);
    expect(VncClient.keySym(LogicalKeyboardKey.backspace), 0xff08);
    expect(VncClient.keySym(LogicalKeyboardKey.arrowUp), 0xff52);
    expect(VncClient.keySym(LogicalKeyboardKey.f12), isNull);
  });
}

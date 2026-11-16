import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VncException implements Exception {
  VncException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VncFrame {
  VncFrame(this.image, this.width, this.height);

  final ui.Image image;
  final int width;
  final int height;
}

class VncClient {
  VncClient(this._channel)
    : _iterator = StreamIterator<dynamic>(_channel.stream);

  final WebSocketChannel _channel;
  final StreamIterator<dynamic> _iterator;
  final List<int> _buffer = [];
  final _frames = StreamController<VncFrame>.broadcast();
  final _errors = StreamController<Object>.broadcast();

  Stream<VncFrame> get frames => _frames.stream;
  Stream<Object> get errors => _errors.stream;

  int _width = 0;
  int _height = 0;
  int _bpp = 32;
  bool _bigEndian = false;
  int _redMax = 255;
  int _greenMax = 255;
  int _blueMax = 255;
  int _redShift = 16;
  int _greenShift = 8;
  int _blueShift = 0;
  Uint8List _pixels = Uint8List(0);
  bool _closed = false;

  Future<void> connect() async {
    try {
      await _handshake().timeout(const Duration(seconds: 15));
    } catch (_) {
      await close();
      rethrow;
    }
    unawaited(_readLoop());
  }

  Future<void> _handshake() async {
    if (!await _iterator.moveNext()) {
      throw VncException('VNC 连接已关闭');
    }
    _buffer.addAll((_iterator.current as List).cast<int>());
    final version = String.fromCharCodes(await _read(12));
    _write(_negotiateVersion(version).codeUnits);

    final count = (await _read(1))[0];
    if (count == 0) {
      final reason = await _readReason();
      throw VncException(reason);
    }
    final types = await _read(count);
    if (!types.contains(1)) {
      throw VncException('VNC 服务端要求不支持的认证方式');
    }
    _writeByte(1);
    final result = _uint32(await _read(4), 0);
    if (result != 0) {
      throw VncException(await _readReason());
    }

    _writeByte(1);
    final init = await _read(24);
    final nameLength = _uint32(init, 20);
    if (nameLength > 0) {
      await _read(nameLength);
    }
    _width = _uint16(init, 0);
    _height = _uint16(init, 2);
    _bpp = init[4];
    _bigEndian = init[6] != 0;
    _redMax = _uint16(init, 8);
    _greenMax = _uint16(init, 10);
    _blueMax = _uint16(init, 12);
    _redShift = init[14];
    _greenShift = init[15];
    _blueShift = init[16];
    _pixels = Uint8List(_width * _height * 4);

    final encodings = <int>[0];
    final data = ByteData(4 + 4 * encodings.length);
    data.setUint8(0, 2);
    data.setUint16(2, encodings.length, Endian.big);
    for (var i = 0; i < encodings.length; i++) {
      data.setInt32(4 + i * 4, encodings[i], Endian.big);
    }
    _write(data.buffer.asUint8List());
    await _requestUpdate(full: true);
  }

  Future<void> _readLoop() async {
    try {
      while (!_closed) {
        final type = (await _read(1))[0];
        switch (type) {
          case 0:
            await _handleFramebufferUpdate();
          case 1:
            final header = await _read(5);
            final colors = _uint16(header, 3);
            await _read(colors * 6);
          case 2:
            break;
          case 3:
            final header = await _read(7);
            final length = _uint32(header, 3);
            if (length > 0) await _read(length);
          default:
            throw VncException('未知的 VNC 消息类型：$type');
        }
      }
    } catch (error) {
      if (!_closed) _errors.add(error);
    }
  }

  Future<void> _handleFramebufferUpdate() async {
    await _read(1);
    final countBytes = await _read(2);
    final count = _uint16(countBytes, 0);
    for (var i = 0; i < count; i++) {
      final rect = await _read(12);
      final x = _uint16(rect, 0);
      final y = _uint16(rect, 2);
      final w = _uint16(rect, 4);
      final h = _uint16(rect, 6);
      final encoding = _int32(rect, 8);
      if (encoding == 0) {
        final bytes = await _read(w * h * (_bpp ~/ 8));
        _blitRaw(x, y, w, h, bytes);
      } else if (encoding == -223) {
        _width = w;
        _height = h;
        _pixels = Uint8List(_width * _height * 4);
        await _requestUpdate(full: true);
      } else if (encoding == -224) {
        break;
      } else {
        throw VncException('不支持的 VNC 编码：$encoding');
      }
    }
    await _emitFrame();
    if (!_closed) {
      await _requestUpdate();
    }
  }

  void _blitRaw(int x, int y, int w, int h, Uint8List bytes) {
    if (_bpp != 16 && _bpp != 32) {
      throw VncException('不支持的像素位宽：$_bpp');
    }
    final data = ByteData.sublistView(bytes);
    final bytesPerPixel = _bpp ~/ 8;
    final endian = _bigEndian ? Endian.big : Endian.little;
    for (var row = 0; row < h; row++) {
      final dy = y + row;
      if (dy >= _height) continue;
      for (var col = 0; col < w; col++) {
        final dx = x + col;
        if (dx >= _width) continue;
        final offset = (row * w + col) * bytesPerPixel;
        final value = bytesPerPixel == 4
            ? data.getUint32(offset, endian)
            : data.getUint16(offset, endian);
        final r = ((value >> _redShift) & _redMax) * 255 ~/ _redMax;
        final g = ((value >> _greenShift) & _greenMax) * 255 ~/ _greenMax;
        final b = ((value >> _blueShift) & _blueMax) * 255 ~/ _blueMax;
        final index = (dy * _width + dx) * 4;
        _pixels[index] = r;
        _pixels[index + 1] = g;
        _pixels[index + 2] = b;
        _pixels[index + 3] = 255;
      }
    }
  }

  Future<void> _emitFrame() async {
    if (_closed || _width <= 0 || _height <= 0) return;
    final buffer = await ui.ImmutableBuffer.fromUint8List(_pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: _width,
      height: _height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    if (_closed) {
      frame.image.dispose();
    } else {
      _frames.add(VncFrame(frame.image, _width, _height));
    }
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
  }

  Future<void> _requestUpdate({bool full = false}) async {
    if (_width <= 0 || _height <= 0) return;
    final data = ByteData(10);
    data.setUint8(0, 3);
    data.setUint8(1, full ? 0 : 1);
    data.setUint16(2, 0, Endian.big);
    data.setUint16(4, 0, Endian.big);
    data.setUint16(6, _width, Endian.big);
    data.setUint16(8, _height, Endian.big);
    _write(data.buffer.asUint8List());
  }

  void sendPointer(int x, int y, int mask) {
    final data = ByteData(6);
    data.setUint8(0, 5);
    data.setUint8(1, mask);
    data.setUint16(2, x, Endian.big);
    data.setUint16(4, y, Endian.big);
    _write(data.buffer.asUint8List());
  }

  void sendKey(int keysym, bool down) {
    final data = ByteData(8);
    data.setUint8(0, 4);
    data.setUint8(1, down ? 1 : 0);
    data.setUint32(4, keysym, Endian.big);
    _write(data.buffer.asUint8List());
  }

  static int? keySym(LogicalKeyboardKey key) {
    final label = key.keyLabel.toLowerCase();
    if (label.length == 1) {
      final code = label.codeUnitAt(0);
      if (code >= 0x20 && code <= 0x7e) return code;
    }
    if (key == LogicalKeyboardKey.enter) return 0xff0d;
    if (key == LogicalKeyboardKey.backspace) return 0xff08;
    if (key == LogicalKeyboardKey.tab) return 0xff09;
    if (key == LogicalKeyboardKey.escape) return 0xff1b;
    if (key == LogicalKeyboardKey.space) return 0x20;
    if (key == LogicalKeyboardKey.arrowLeft) return 0xff51;
    if (key == LogicalKeyboardKey.arrowUp) return 0xff52;
    if (key == LogicalKeyboardKey.arrowRight) return 0xff53;
    if (key == LogicalKeyboardKey.arrowDown) return 0xff54;
    if (key == LogicalKeyboardKey.shiftLeft) return 0xffe1;
    if (key == LogicalKeyboardKey.controlLeft) return 0xffe3;
    if (key == LogicalKeyboardKey.altLeft) return 0xffe9;
    if (key == LogicalKeyboardKey.delete) return 0xffff;
    return null;
  }

  Future<String> _readReason() async {
    final header = await _read(4);
    final length = _uint32(header, 0);
    if (length <= 0) return '';
    return String.fromCharCodes(await _read(length));
  }

  Future<Uint8List> _read(int count) async {
    while (_buffer.length < count) {
      if (!await _iterator.moveNext()) {
        throw VncException('VNC 连接已断开');
      }
      _buffer.addAll((_iterator.current as List).cast<int>());
    }
    final result = Uint8List.fromList(_buffer.sublist(0, count));
    _buffer.removeRange(0, count);
    return result;
  }

  void _writeByte(int value) => _write([value]);

  void _write(List<int> data) {
    if (_closed || _channel.closeCode != null) return;
    _channel.sink.add(data);
  }

  static String _negotiateVersion(String peer) {
    final match = RegExp(r'RFB (\d{3})\.(\d{3})').firstMatch(peer);
    if (match == null) throw VncException('无效的 VNC 协议版本');
    final major = int.tryParse(match.group(1) ?? '') ?? 0;
    final minor = int.tryParse(match.group(2) ?? '') ?? 0;
    if (major < 3 || (major == 3 && minor < 8)) {
      throw VncException('VNC 服务端版本过低，需要 RFB 3.8');
    }
    return 'RFB 003.008\n';
  }

  static int _uint16(List<int> data, int offset) =>
      (data[offset] << 8) | data[offset + 1];

  static int _uint32(List<int> data, int offset) =>
      (data[offset] << 24) |
      (data[offset + 1] << 16) |
      (data[offset + 2] << 8) |
      data[offset + 3];

  static int _int32(List<int> data, int offset) {
    final value = _uint32(data, offset);
    return value >= 0x80000000 ? value - 0x100000000 : value;
  }

  Future<void> close() async {
    _closed = true;
    await _iterator.cancel();
    await _channel.sink.close();
    await _frames.close();
    await _errors.close();
  }
}

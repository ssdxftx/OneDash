import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/theme/tokens.dart';

abstract final class StatusPulse {
  static final ValueNotifier<double> _value = ValueNotifier<double>(1);
  static Ticker? _ticker;
  static int _references = 0;

  static ValueListenable<double> get value => _value;

  @visibleForTesting
  static int get debugReferences => _references;

  static void attach() {
    _references++;
    _ticker ??= Ticker(_tick);
    if (!_ticker!.isActive) _ticker!.start();
  }

  static void detach() {
    if (_references > 0) _references--;
    if (_references > 0) return;
    _ticker?.stop();
    _value.value = 1;
  }

  static void _tick(Duration elapsed) {
    final cycle = AppTokens.dLoop.inMilliseconds;
    final phase = (elapsed.inMilliseconds % cycle) / cycle;
    _value.value = phase <= 0.5 ? phase * 2 : (1 - phase) * 2;
  }
}

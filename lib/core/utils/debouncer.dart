import 'dart:async';

/// 通用防抖工具，封装 [Timer] 生命周期管理。
///
/// 用法：
/// ```dart
/// final _debouncer = Debouncer();
///
/// void search(String query) {
///   _debouncer(() {
///     // 500ms 后执行
///   });
/// }
///
/// @override
/// void dispose() {
///   _debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  Timer? _timer;

  /// 延迟 [delay]（默认 500ms）后执行 [action]。
  /// 重复调用会取消前一次尚未触发的 [action]。
  void call(
    void Function() action, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// 取消尚未触发的回调并释放资源。
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

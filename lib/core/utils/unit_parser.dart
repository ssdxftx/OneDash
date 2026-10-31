/// 1Panel 返回的带单位字符串解析工具。
///
/// 1Panel 的 GPU/XPU 指标是字符串（如 `"80%"` / `"2048 MiB"` / `"62C"` /
/// `"250W"`），需要解析为数值以便进行格式化展示与比较。
class UnitParser {
  const UnitParser._();

  static final _numberPattern = RegExp(r'[-+]?\d*\.?\d+');
  static final _sizePattern = RegExp(
    r'([-+]?\d*\.?\d+)\s*([KMGTPE]?i?B)?',
    caseSensitive: false,
  );

  /// 提取首个数字，忽略 `%` / `C` / `W` 等尾部单位。
  static double number(String? text, {double fallback = 0}) {
    if (text == null || text.isEmpty) return fallback;
    final match = _numberPattern.firstMatch(text);
    if (match == null) return fallback;
    return double.tryParse(match.group(0)!) ?? fallback;
  }

  /// 解析带单位的存储大小字符串转为字节数。
  ///
  /// 兼容 `"2048 MiB"` / `"8GB"` / `"1024KB"` / `"2048"` 等格式。
  /// `IB` 结尾按 1024 进制，其余按 1000 进制。
  static int bytes(String? text) {
    if (text == null || text.isEmpty) return 0;
    final match = _sizePattern.firstMatch(text);
    if (match == null) return 0;
    final value = double.tryParse(match.group(1) ?? '') ?? 0;
    final unit = (match.group(2) ?? 'B').toUpperCase();
    final exp = switch (unit) {
      'B' => 0,
      'KB' || 'KIB' => 1,
      'MB' || 'MIB' => 2,
      'GB' || 'GIB' => 3,
      'TB' || 'TIB' => 4,
      'PB' || 'PIB' => 5,
      'EB' || 'EIB' => 6,
      _ => 0,
    };
    final base = unit.endsWith('IB') ? 1024 : 1000;
    var multiplier = 1.0;
    for (var i = 0; i < exp; i++) {
      multiplier *= base;
    }
    return (value * multiplier).round();
  }
}

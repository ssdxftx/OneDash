import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 选择模式等场景需要临时隐藏悬浮底部导航。
final bottomNavSuppressedProvider = StateProvider<bool>((ref) => false);

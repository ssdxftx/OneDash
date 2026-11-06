import 'package:flutter/widgets.dart';

/// 列表首次加载时播放一次入场动画，之后的重建不再播放。
mixin EntryAnimation<T extends StatefulWidget> on State<T> {
  bool entryAnimationEnabled = true;

  void stopEntryAnimation(bool hasItems) {
    if (!entryAnimationEnabled || !hasItems) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && entryAnimationEnabled) {
        setState(() => entryAnimationEnabled = false);
      }
    });
  }
}

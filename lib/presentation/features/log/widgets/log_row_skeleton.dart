import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';

/// 日志列表骨架样式，按四个 tab 的真实行结构分别占位。
enum LogSkeletonStyle { operation, login, ssh, task }

/// 与真实日志卡同构的骨架：TonalCard + 34dp 图标位 + 标题/胶囊 + 元信息行。
class LogRowSkeletonList extends StatelessWidget {
  const LogRowSkeletonList({super.key, this.style = LogSkeletonStyle.login});

  final LogSkeletonStyle style;

  @override
  Widget build(BuildContext context) {
    final extent = switch (style) {
      LogSkeletonStyle.operation => 112.0,
      LogSkeletonStyle.login => 106.0,
      LogSkeletonStyle.ssh => 114.0,
      LogSkeletonStyle.task => 86.0,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxHeight / extent).ceil().clamp(1, 12);
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.pagePadding),
          itemCount: count,
          itemBuilder: (context, _) => Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s8),
            child: LogRowSkeletonCard(style: style),
          ),
        );
      },
    );
  }
}

class LogRowSkeletonCard extends StatelessWidget {
  const LogRowSkeletonCard({super.key, this.style = LogSkeletonStyle.login});

  final LogSkeletonStyle style;

  @override
  Widget build(BuildContext context) {
    final gap = style == LogSkeletonStyle.operation ? AppTokens.s8 : 6.0;
    final metaRuns = switch (style) {
      LogSkeletonStyle.operation => const [20.0, 16.0],
      LogSkeletonStyle.login => const [16.0, 16.0],
      LogSkeletonStyle.ssh => const [20.0, 20.0],
      LogSkeletonStyle.task => const [16.0],
    };
    return TonalCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 34, height: 34, borderRadius: AppTokens.rXs),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SkeletonBox(width: 160, height: 20),
                        ),
                      ),
                      SizedBox(width: AppTokens.s8),
                      Align(
                        alignment: Alignment.topRight,
                        child: SkeletonBox(
                          width: 46,
                          height: 24,
                          borderRadius: AppTokens.rXs,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: gap),
                for (var i = 0; i < metaRuns.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
                    child: SizedBox(
                      height: metaRuns[i],
                      child: const Row(
                        children: [
                          SkeletonBox(width: 84, height: 16),
                          SizedBox(width: AppTokens.s12),
                          SkeletonBox(width: 64, height: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

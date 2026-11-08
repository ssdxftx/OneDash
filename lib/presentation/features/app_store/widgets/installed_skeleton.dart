import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/tonal_card.dart';

/// 已安装列表骨架：与真卡使用同一 TonalCard 容器与行列结构。
class InstalledAppSkeletonList extends StatelessWidget {
  const InstalledAppSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonListLayout(
      rowExtent: _kInstalledRowExtent,
      itemBuilder: (context) => const _InstalledAppSkeletonCard(),
    );
  }
}

/// 全部应用列表骨架：行结构对齐 _AppRow 真卡。
class CatalogAppSkeletonList extends StatelessWidget {
  const CatalogAppSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonListLayout(
      rowExtent: _kCatalogRowExtent,
      itemBuilder: (context) => const _CatalogAppSkeletonCard(),
    );
  }
}

/// 骨架单项占位高度，由 test/widget/app_store_skeleton_test.dart 实测锁定。
const double _kInstalledRowExtent = 85;
const double _kCatalogRowExtent = 133;

class _SkeletonListLayout extends StatelessWidget {
  const _SkeletonListLayout({
    required this.rowExtent,
    required this.itemBuilder,
  });

  final double rowExtent;
  final WidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxHeight / rowExtent).ceil().clamp(1, 12);
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.pagePadding),
          itemCount: count,
          itemBuilder: (context, _) => Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s12),
            child: itemBuilder(context),
          ),
        );
      },
    );
  }
}

class _InstalledAppSkeletonCard extends StatelessWidget {
  const _InstalledAppSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const TonalCard(
      child: Row(
        children: [
          SkeletonBox(width: 36, height: 36, borderRadius: AppTokens.rSm),
          SizedBox(width: AppTokens.s12),
          SkeletonBox(width: 8, height: 8, borderRadius: AppTokens.rFull),
          SizedBox(width: AppTokens.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 20),
                SizedBox(height: 2),
                SkeletonBox(width: 80, height: 19),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogAppSkeletonCard extends StatelessWidget {
  const _CatalogAppSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const TonalCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 44, height: 44, borderRadius: AppTokens.rSm),
          SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 120, height: 21),
                    Spacer(),
                    SkeletonBox(width: 16, height: 16),
                  ],
                ),
                SizedBox(height: 2),
                SkeletonBox(width: double.infinity, height: 18),
                SizedBox(height: 2),
                SkeletonBox(width: 180, height: 18),
                SizedBox(height: AppTokens.s8),
                Row(
                  children: [
                    SkeletonBox(width: 48, height: 20),
                    SizedBox(width: AppTokens.s8),
                    SkeletonBox(width: 56, height: 20),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppTokens.s8),
          SkeletonBox(width: AppTokens.iconList, height: AppTokens.iconList),
        ],
      ),
    );
  }
}

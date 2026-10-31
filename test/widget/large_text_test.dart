import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/metric_card.dart';
import 'package:onedash/presentation/common/components/section_header.dart';
import 'package:onedash/presentation/common/components/segmented_tabs.dart';
import 'package:onedash/presentation/common/components/skeleton.dart';
import 'package:onedash/presentation/common/components/split_list_group.dart';

Future<void> _loadFont() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = await File('assets/fonts/MiSans-Regular.ttf').readAsBytes();
  await ui.loadFontFromList(Uint8List.fromList(bytes), fontFamily: 'MiSans');
}

void main() {
  testWidgets('representative layout survives 1.5x text in OLED dark', (
    tester,
  ) async {
    await tester.runAsync(_loadFont);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.dark, oled: true),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader(
                title: '运行环境与数据库连接信息',
                subtitle: 'PHP 8.3 · MySQL 8.0 · PostgreSQL 16',
              ),
              SplitListGroup(
                children: [
                  const SplitListTile(
                    leading: Icon(Icons.folder),
                    title: '一个很长的站点目录名称用来验证省略号',
                    subtitle:
                        '/opt/1panel/apps/openresty/openresty/www/sites/example.com',
                    trailing: Icon(Icons.chevron_right),
                  ),
                  SplitListTile(
                    leading: const Icon(Icons.copy),
                    title: '复制连接信息',
                    subtitle: 'mysql://root:password@127.0.0.1:3306/example',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SegmentedTabs(
                labels: const ['基本配置', '域名', 'SSL 证书', '反向代理设置', '日志'],
                selectedIndex: 1,
                scrollable: false,
                onChanged: (_) {},
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 176,
                children: const [
                  MetricCard(
                    title: '内存使用率',
                    value: '68.2',
                    unit: '%',
                    caption: '2.4 GB / 8 GB',
                    status: 'running',
                    sparkline: SizedBox(height: 28),
                  ),
                  MetricCard(
                    title: 'CPU 使用率',
                    value: '42.5',
                    unit: '%',
                    caption: '8 核心',
                    status: 'running',
                    sparkline: SizedBox(height: 28),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SkeletonShimmer(child: SkeletonCard(height: 120)),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}

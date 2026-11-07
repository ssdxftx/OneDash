import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/segmented_tabs.dart';

void main() {
  testWidgets('选中的靠后页签会自动滚入视口', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: SegmentedTabs(
            labels: const ['概览', '网站', '文件', '容器', '计划任务', '负载均衡'],
            selectedIndex: 5,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('横向溢出时右侧显示还有更多标签的提示', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: SegmentedTabs(
            labels: [
              'Basic Configuration',
              'Security',
              'Rewrite',
              'Redirect',
              'OpenResty',
            ],
            selectedIndex: 0,
            onChanged: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('segmentedTabsMoreHint')), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('segmentedTabsMoreHint')), findsOneWidget);
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.byKey(const Key('segmentedTabsMoreHintFade')),
          )
          .opacity,
      0,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('滚到最右后滚动范围不会回退', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: SegmentedTabs(
            labels: [
              'Basic Configuration',
              'Security',
              'Rewrite',
              'Redirect',
              'OpenResty',
            ],
            selectedIndex: 0,
            onChanged: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    final max = position.maxScrollExtent;
    position.jumpTo(max);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(position.maxScrollExtent, closeTo(max, 0.01));
    expect(position.pixels, closeTo(max, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('宽度变化后重新计算是否溢出', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: SegmentedTabs(
            labels: [
              'Basic Configuration',
              'Security',
              'Rewrite',
              'Redirect',
              'OpenResty',
            ],
            selectedIndex: 0,
            onChanged: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('segmentedTabsMoreHint')), findsOneWidget);

    tester.view.physicalSize = const Size(844, 400);
    await tester.pumpAndSettle();

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    expect(position.maxScrollExtent, 0);
    expect(find.byKey(const Key('segmentedTabsMoreHint')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('点击右侧提示会滚动标签行且不误选标签', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: SegmentedTabs(
            labels: const [
              'Basic Configuration',
              'Security',
              'Rewrite',
              'Redirect',
              'OpenResty',
            ],
            selectedIndex: 0,
            onChanged: taps.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('segmentedTabsMoreHint')));
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(taps, isEmpty);
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('从箭头区域横向拖动也能滚动标签行', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: SegmentedTabs(
            labels: const [
              'Basic Configuration',
              'Security',
              'Rewrite',
              'Redirect',
              'OpenResty',
            ],
            selectedIndex: 0,
            onChanged: taps.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hint = tester.getRect(find.byKey(const Key('segmentedTabsMoreHint')));
    await tester.dragFrom(hint.center, const Offset(-120, 0));
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(taps, isEmpty);
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('非滚动页签共享指示器跟随选中项移动', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SegmentedTabs(
              labels: const ['概览', '网站', '文件'],
              selectedIndex: selected,
              scrollable: false,
              onChanged: (index) => setState(() => selected = index),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final before = tester.widget<AnimatedPositioned>(
      find.byType(AnimatedPositioned),
    );
    await tester.tap(find.text('文件'));
    await tester.pumpAndSettle();
    final after = tester.widget<AnimatedPositioned>(
      find.byType(AnimatedPositioned),
    );

    expect(before.left, isNotNull);
    expect(after.left, greaterThan(before.left!));
    expect(tester.takeException(), isNull);
  });

  testWidgets('宽度变化后非滚动指示器重新定位', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 400);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: SegmentedTabs(
            labels: ['概览', '网站', '计划任务'],
            selectedIndex: 2,
            scrollable: false,
            onChanged: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final wide = tester
        .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
        .left!;

    tester.view.physicalSize = const Size(320, 400);
    await tester.pumpAndSettle();
    final narrow = tester
        .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
        .left!;

    expect(narrow, lessThan(wide));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keepAlive 切换标签不重建页内 State', (tester) async {
    _ProbeState.builds.clear();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: SegmentedTabsView(
            labels: ['A', 'B', 'C'],
            children: [_Probe('A'), _Probe('B'), _Probe('C')],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(_ProbeState.builds['A'], 1);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(_ProbeState.builds['A'], 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keepAlive 切换标签保留滚动位置', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: SegmentedTabsView(
            labels: const ['A', 'B'],
            children: [
              ListView.builder(
                controller: controller,
                itemCount: 30,
                itemBuilder: (context, index) =>
                    SizedBox(height: 60, child: Text('A-$index')),
              ),
              ListView(
                children: const [SizedBox(height: 60, child: Text('B-0'))],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    controller.jumpTo(600);
    await tester.pump();

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(controller.offset, 600);
    expect(tester.takeException(), isNull);
  });
}

void _noop(int _) {}

class _Probe extends StatefulWidget {
  const _Probe(this.name);

  final String name;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  static final Map<String, int> builds = {};

  @override
  void initState() {
    super.initState();
    builds[widget.name] = (builds[widget.name] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) => Text('page-${widget.name}');
}

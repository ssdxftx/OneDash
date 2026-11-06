import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/removable_list_item.dart';

void main() {
  testWidgets('removing collapses and fades the row', (tester) async {
    var removing = false;
    late StateSetter setHost;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              setHost = setState;
              return Center(
                child: SizedBox(
                  width: 300,
                  child: RemovableListItem(
                    removing: removing,
                    child: const SizedBox(height: 100, child: Text('row')),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(RemovableListItem)).height, 100);

    setHost(() => removing = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final middle = tester.getSize(find.byType(RemovableListItem)).height;
    expect(middle, greaterThan(0));
    expect(middle, lessThan(100));

    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(RemovableListItem)).height, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new rows grow and fade in', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: RemovableListItem(
                removing: false,
                animateIn: true,
                child: SizedBox(height: 100, child: Text('new row')),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(RemovableListItem)).height, 0);
    await tester.pump(const Duration(milliseconds: 100));
    final middle = tester.getSize(find.byType(RemovableListItem)).height;
    expect(middle, greaterThan(0));
    expect(middle, lessThan(100));

    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(RemovableListItem)).height, 100);
    expect(tester.takeException(), isNull);
  });

  testWidgets('入场动画只播一次，回收重建后保持完整高度', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(body: _RecycleHarness()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 3000));
    await tester.pumpAndSettle();

    final row = find.byType(RemovableListItem).first;
    expect(tester.getSize(row).height, 80);
    expect(tester.takeException(), isNull);
  });
}

class _RecycleHarness extends StatefulWidget {
  const _RecycleHarness();

  @override
  State<_RecycleHarness> createState() => _RecycleHarnessState();
}

class _RecycleHarnessState extends State<_RecycleHarness> {
  bool _animateEntry = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animateEntry = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) => RemovableListItem(
        key: ValueKey(index),
        removing: false,
        animateIn: _animateEntry,
        child: const SizedBox(height: 80, child: Text('row')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_table/table_sticky_headers.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget table) => MaterialApp(
      home: Scaffold(body: SizedBox(width: 400, height: 400, child: table)),
    );

StickyHeadersTable table({
  int rows = 100,
  int cols = 10,
  StickyTableController? controller,
  void Function(int, int)? onTap,
  void Function(int, bool)? onSort,
  int? sortColumn,
  bool resizable = false,
  VoidCallback? onEndReached,
  Set<int> selected = const {},
  WidgetBuilder? empty,
  void Function(int, double)? onResized,
}) =>
    StickyHeadersTable(
      columnsLength: cols,
      rowsLength: rows,
      columnsTitleBuilder: (j) => Text('C$j'),
      rowsTitleBuilder: (i) => Text('R$i'),
      contentCellBuilder: (j, i) => Text('$i:$j'),
      controller: controller,
      onContentCellPressed: onTap,
      onSort: onSort,
      sortColumnIndex: sortColumn,
      resizableColumns: resizable,
      onEndReached: onEndReached,
      selectedRows: selected,
      emptyBuilder: empty,
      onColumnResized: onResized,
      style: const StickyTableStyle(
          gridLineColor: Colors.grey, showScrollShadows: true),
    );

void main() {
  testWidgets('builds rows lazily', (tester) async {
    await tester.pumpWidget(host(table(rows: 10000)));
    expect(find.text('0:0'), findsOneWidget);
    expect(find.text('9999:0'), findsNothing);
    expect(find.byType(Text).evaluate().length, lessThan(300));
  });

  testWidgets('text constructor renders data', (tester) async {
    await tester.pumpWidget(host(StickyHeadersTable.text(
      columnTitles: ['A', 'B'],
      rowTitles: ['1', '2'],
      data: [
        ['a1', 'b1'],
        ['a2', 'b2']
      ],
    )));
    for (final t in ['A', 'B', '1', '2', 'a1', 'b2']) {
      expect(find.text(t), findsOneWidget);
    }
  });

  testWidgets('taps report column then row', (tester) async {
    int? c, r;
    await tester.pumpWidget(host(table(onTap: (j, i) {
      c = j;
      r = i;
    })));
    await tester.tap(find.text('3:1'));
    expect([c, r], [1, 3]);
  });

  testWidgets('headers stay while body scrolls and stay in sync',
      (tester) async {
    final ctrl = StickyTableController();
    await tester.pumpWidget(host(table(controller: ctrl)));
    await tester.drag(find.text('1:1'), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.drag(find.text('7:1'), const Offset(-150, 0));
    await tester.pumpAndSettle();
    expect(ctrl.offsetX, greaterThan(0));
    expect(ctrl.offsetY, greaterThan(0));
    expect(find.text('C0'), findsOneWidget);
    expect(find.text('R0'), findsNothing);
    final h = tester.getTopLeft(find.text('C2')).dx;
    final b = tester
        .getTopLeft(find.text('0:2').evaluate().isNotEmpty
            ? find.text('0:2')
            : find.text('6:2'))
        .dx;
    expect((h - b).abs(), lessThan(30));
  });

  testWidgets('controller scrolls to row and column', (tester) async {
    final ctrl = StickyTableController();
    await tester.pumpWidget(host(table(controller: ctrl)));
    await ctrl.scrollToRow(40);
    await ctrl.scrollToColumn(5);
    await tester.pumpAndSettle();
    expect(ctrl.offsetY, 40 * 50.0);
    expect(find.text('R40'), findsOneWidget);
    expect(ctrl.offsetX, greaterThan(0));
  });

  testWidgets('sort toggles direction and draws arrow', (tester) async {
    int? col;
    bool? asc;
    await tester.pumpWidget(host(table(
        sortColumn: 0,
        onSort: (c, a) {
          col = c;
          asc = a;
        })));
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    await tester.tap(find.text('C0'));
    expect([col, asc], [0, false]);
    await tester.tap(find.text('C1'));
    expect([col, asc], [1, true]);
  });

  testWidgets('columns can be resized', (tester) async {
    final ctrl = StickyTableController();
    final resized = <int, double>{};
    await tester.pumpWidget(host(table(
      controller: ctrl,
      resizable: true,
      onResized: (j, w) => resized[j] = w,
    )));
    expect(ctrl.columnWidth(0), 70);
    // right edge of column 0 header: legend is 120 wide, column 70 wide
    final edge = tester.getTopLeft(find.byType(StickyHeadersTable)) +
        const Offset(120 + 70 - 3, 25);
    await tester.dragFrom(edge, const Offset(30, 0));
    await tester.pump();
    expect(ctrl.columnWidth(0), greaterThan(70));
    expect(resized[0], ctrl.columnWidth(0));
  });

  testWidgets('empty state', (tester) async {
    await tester.pumpWidget(
        host(table(rows: 0, empty: (_) => const Text('nothing here'))));
    expect(find.text('nothing here'), findsOneWidget);
    expect(find.text('C0'), findsOneWidget);
  });

  testWidgets('onEndReached fires once near the bottom', (tester) async {
    var calls = 0;
    final ctrl = StickyTableController();
    await tester.pumpWidget(
        host(table(rows: 30, controller: ctrl, onEndReached: () => calls++)));
    await tester.pump();
    expect(calls, 0);
    await ctrl.scrollTo(y: 1e6);
    await tester.pump();
    expect(calls, 1);
    await ctrl.scrollTo(y: 1e6);
    await tester.pump();
    expect(calls, 1);
  });

  testWidgets('end reached fires when rows do not fill viewport',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(host(table(rows: 2, onEndReached: () => calls++)));
    await tester.pump();
    expect(calls, 1);
  });

  testWidgets('parent rebuild keeps scroll position', (tester) async {
    final ctrl = StickyTableController();
    late StateSetter set;
    await tester.pumpWidget(host(StatefulBuilder(builder: (_, s) {
      set = s;
      return table(controller: ctrl);
    })));
    await ctrl.scrollTo(y: 500);
    await tester.pump();
    set(() {});
    await tester.pump();
    expect(ctrl.offsetY, 500);
  });
}

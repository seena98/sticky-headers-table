import 'package:flutter/material.dart';
import 'package:flutter_table/table_sticky_headers.dart';
import 'package:flutter_test/flutter_test.dart';

class P {
  P(this.name, this.age);
  final String name;
  final int age;
}

Widget host(Widget w) => MaterialApp(
    home: Scaffold(body: SizedBox(width: 500, height: 400, child: w)));

final people = [P('Cleo', 40), P('Abe', 25), P('Bo', 31)];
final cols = [
  StickyColumn<P>(title: 'Name', value: (p) => p.name),
  StickyColumn<P>(title: 'Age', value: (p) => p.age),
];

double y(WidgetTester t, String s) => t.getTopLeft(find.text(s)).dy;

void main() {
  testWidgets('sorts by tapping a header, toggles direction', (tester) async {
    await tester
        .pumpWidget(host(StickyDataTable<P>(rows: people, columns: cols)));
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(y(tester, 'Abe') < y(tester, 'Bo'), isTrue);
    expect(y(tester, 'Bo') < y(tester, 'Cleo'), isTrue);
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(y(tester, 'Cleo') < y(tester, 'Abe'), isTrue);
  });

  testWidgets('numeric columns sort numerically', (tester) async {
    await tester.pumpWidget(host(
        StickyDataTable<P>(rows: people, columns: cols, initialSortColumn: 1)));
    expect(y(tester, '25') < y(tester, '31'), isTrue);
    expect(y(tester, '31') < y(tester, '40'), isTrue);
  });

  testWidgets('search filters rows', (tester) async {
    await tester.pumpWidget(host(
        StickyDataTable<P>(rows: people, columns: cols, searchQuery: 'b')));
    expect(find.text('Abe'), findsOneWidget);
    expect(find.text('Bo'), findsOneWidget);
    expect(find.text('Cleo'), findsNothing);
  });

  testWidgets('selection reports rows', (tester) async {
    Set<P> sel = {};
    await tester.pumpWidget(host(StickyDataTable<P>(
        rows: people,
        columns: cols,
        selectable: true,
        onSelectionChanged: (s) => sel = s)));
    await tester.tap(find.text('Bo'));
    await tester.pump();
    expect(sel.map((p) => p.name), ['Bo']);
    await tester.tap(find.text('Bo'));
    await tester.pump();
    expect(sel, isEmpty);
  });

  testWidgets('empty result shows message', (tester) async {
    await tester.pumpWidget(host(
        StickyDataTable<P>(rows: people, columns: cols, searchQuery: 'zzz')));
    expect(find.text('No results'), findsOneWidget);
  });

  testWidgets('every preset renders', (tester) async {
    for (final s in StickyTableStyle.presets.values) {
      await tester.pumpWidget(host(StickyDataTable<P>(
          rows: people, columns: cols, style: s, selectable: true)));
      expect(find.text('Abe'), findsOneWidget);
    }
  });

  testWidgets('hidden columns are not shown', (tester) async {
    await tester.pumpWidget(host(StickyDataTable<P>(
        rows: people, columns: cols, hiddenColumns: const {1})));
    expect(find.text('Age'), findsNothing);
    expect(find.text('Name'), findsOneWidget);
  });

  test('csv export escapes fields', () {
    final csv = stickyTableToCsv<P>(cols, [P('Smith, J', 3), P('Q"x', 4)]);
    expect(csv, 'Name,Age\n"Smith, J",3\n"Q""x",4');
  });
}

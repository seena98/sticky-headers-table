import 'package:flutter/material.dart';
import 'package:flutter_table/table_sticky_headers.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'flutter_table',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const Showcase(),
      );
}

class Employee {
  Employee(this.id, this.name, this.role, this.salary, this.age, this.joined);
  final int id;
  final String name, role;
  final int salary, age;
  final DateTime joined;
}

const _roles = ['Engineer', 'Designer', 'Manager', 'Analyst', 'Support'];
const _names = ['Ava', 'Liam', 'Noah', 'Mia', 'Zoe', 'Ethan', 'Ivy', 'Leo'];
const _last = ['Parker', 'Nguyen', 'Silva', 'Khan', 'Rossi', 'Berg', 'Okafor'];

List<Employee> generate(int count, [int start = 0]) => List.generate(
      count,
      (i) => Employee(
        start + i + 1,
        '${_names[(start + i) % _names.length]} ${_last[(start + i * 3) % _last.length]}',
        _roles[(start + i * 7) % _roles.length],
        40000 + ((start + i) * 7919) % 90000,
        21 + ((start + i) * 13) % 40,
        DateTime(2015 + (start + i) % 10, 1 + (start + i) % 12,
            1 + (start + i) % 27),
      ),
    );

String two(int n) => n.toString().padLeft(2, '0');

class Showcase extends StatefulWidget {
  const Showcase({super.key});

  @override
  State<Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  final controller = StickyTableController();
  var data = generate(80);
  bool loading = false;
  bool smart = true;
  String search = '';
  Set<Employee> selected = {};
  late String theme =
      Uri.base.queryParameters['theme'] ?? StickyTableStyle.presets.keys.first;

  Future<void> loadMore() async {
    setState(() => loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      data = [...data, ...generate(40, data.length)];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = StickyTableStyle.presets[theme]!;
    final columns = <StickyColumn<Employee>>[
      StickyColumn(title: 'Name', value: (e) => e.name, width: 150),
      StickyColumn(
        title: 'Role',
        value: (e) => e.role,
        cell: (context, e) {
          final color = DefaultTextStyle.of(context).style.color;
          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: color ?? Colors.grey),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Text(e.role, style: TextStyle(fontSize: 12, color: color)),
            ),
          );
        },
      ),
      StickyColumn(
          title: 'Salary', value: (e) => e.salary, format: (v) => '\$$v'),
      StickyColumn(title: 'Age', value: (e) => e.age),
      StickyColumn(
        title: 'Joined',
        value: (e) => e.joined,
        format: (v) {
          final d = v as DateTime;
          return '${d.year}-${two(d.month)}-${two(d.day)}';
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('flutter_table · ${data.length} rows'),
        actions: [
          IconButton(
            tooltip: 'Jump to row 30',
            icon: const Icon(Icons.vertical_align_center),
            onPressed: () => controller.scrollToRow(30,
                duration: const Duration(milliseconds: 500)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search…',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => search = v),
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Smart')),
                  ButtonSegment(value: false, label: Text('Builder')),
                ],
                selected: {smart},
                onSelectionChanged: (s) => setState(() => smart = s.first),
              ),
            ]),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final name in StickyTableStyle.presets.keys)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(name),
                      selected: theme == name,
                      onSelected: (_) => setState(() => theme = name),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: smart
                    ? StickyDataTable<Employee>(
                        controller: controller,
                        rows: data,
                        columns: columns,
                        style: style,
                        searchQuery: search,
                        initialSortColumn: 0,
                        selectable: true,
                        onSelectionChanged: (s) => setState(() => selected = s),
                        isLoading: loading,
                        onEndReached: loading ? null : loadMore,
                      )
                    : StickyHeadersTable.text(
                        columnTitles: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
                        rowTitles: [for (var i = 1; i <= 50; i++) 'Row $i'],
                        data: [
                          for (var i = 0; i < 50; i++)
                            [for (var j = 0; j < 8; j++) '${i * 8 + j}'],
                        ],
                        legend: 'Legend',
                        style: style,
                        resizableColumns: true,
                        showScrollbars: true,
                        controller: controller,
                      ),
              ),
            ),
          ),
          if (smart)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${selected.length} selected · tap a row to select'),
            ),
        ],
      ),
    );
  }
}

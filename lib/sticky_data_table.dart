import 'package:flutter/material.dart';

import 'table_sticky_headers.dart';

/// Describes one column of a [StickyDataTable].
class StickyColumn<T> {
  const StickyColumn({
    required this.title,
    required this.value,
    this.cell,
    this.format,
    this.width,
    this.alignment,
    this.sortable = true,
    this.compare,
  });

  final String title;

  /// Extracts the raw value; used for sorting, searching and default display.
  final Object? Function(T row) value;

  /// Custom widget for the cell (badges, avatars, buttons...).
  final Widget Function(BuildContext context, T row)? cell;

  /// Text shown for a value. Defaults to `toString()`.
  final String Function(Object? value)? format;

  /// Fixed width. `null` sizes the column from its content.
  final double? width;

  /// `null`: numbers right-aligned, everything else left-aligned.
  final Alignment? alignment;
  final bool sortable;

  /// Custom ordering, otherwise numbers, strings and DateTimes sort naturally.
  final int Function(T a, T b)? compare;
}

/// A table that only needs typed rows and column definitions. It sorts,
/// searches, selects and sizes columns by itself on top of
/// [StickyHeadersTable].
///
/// ```dart
/// StickyDataTable<Person>(
///   rows: people,
///   columns: [
///     StickyColumn(title: 'Name', value: (p) => p.name),
///     StickyColumn(title: 'Age', value: (p) => p.age),
///   ],
/// )
/// ```
class StickyDataTable<T> extends StatefulWidget {
  const StickyDataTable({
    super.key,
    required this.rows,
    required this.columns,
    this.style = const StickyTableStyle(),
    this.searchQuery = '',
    this.initialSortColumn,
    this.initialSortAscending = true,
    this.rowNumbers = true,
    this.rowTitle,
    this.legend = '#',
    this.selectable = false,
    this.onSelectionChanged,
    this.onRowTap,
    this.rowHeight = 48,
    this.headerHeight = 52,
    this.rowTitleWidth = 64,
    this.resizableColumns = true,
    this.showScrollbars = true,
    this.isLoading = false,
    this.onEndReached,
    this.emptyBuilder,
    this.controller,
    this.hiddenColumns = const <int>{},
    this.stretchToFit = true,
  });

  final List<T> rows;
  final List<StickyColumn<T>> columns;
  final StickyTableStyle style;

  /// Case-insensitive filter over every column's formatted value.
  final String searchQuery;
  final int? initialSortColumn;
  final bool initialSortAscending;

  /// Show 1, 2, 3... in the sticky column. Ignored if [rowTitle] is set.
  final bool rowNumbers;
  final String Function(T row, int index)? rowTitle;
  final String legend;

  /// Tapping a row toggles its selection.
  final bool selectable;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final ValueChanged<T>? onRowTap;
  final double rowHeight;
  final double headerHeight;
  final double rowTitleWidth;
  final bool resizableColumns;
  final bool showScrollbars;
  final bool isLoading;
  final VoidCallback? onEndReached;
  final WidgetBuilder? emptyBuilder;
  final StickyTableController? controller;

  /// Indexes into [columns] that are not displayed (column picker).
  final Set<int> hiddenColumns;

  /// Grow columns without a fixed [StickyColumn.width] so the table fills
  /// the available width when its content is narrower.
  final bool stretchToFit;

  @override
  State<StickyDataTable<T>> createState() => _StickyDataTableState<T>();
}

class _StickyDataTableState<T> extends State<StickyDataTable<T>> {
  /// Columns after applying [StickyDataTable.hiddenColumns].
  List<StickyColumn<T>> get _cols => [
        for (var j = 0; j < widget.columns.length; j++)
          if (!widget.hiddenColumns.contains(j)) widget.columns[j],
      ];

  int? _sortColumn;
  bool _ascending = true;
  final Set<T> _selected = {};
  List<T> _view = const [];
  List<double> _widths = const [];

  @override
  void initState() {
    super.initState();
    _sortColumn = widget.initialSortColumn;
    _ascending = widget.initialSortAscending;
    _recompute();
  }

  @override
  void didUpdateWidget(StickyDataTable<T> old) {
    super.didUpdateWidget(old);
    _recompute();
  }

  String _text(StickyColumn<T> c, T row) {
    final v = c.value(row);
    return c.format != null ? c.format!(v) : (v?.toString() ?? '');
  }

  void _recompute() {
    final q = widget.searchQuery.trim().toLowerCase();
    var view = q.isEmpty
        ? List<T>.of(widget.rows)
        : widget.rows
            .where(
                (r) => _cols.any((c) => _text(c, r).toLowerCase().contains(q)))
            .toList();
    final sc = _sortColumn;
    if (sc != null && sc < _cols.length) {
      final col = _cols[sc];
      final cmp =
          col.compare ?? (a, b) => _naturalCompare(col.value(a), col.value(b));
      view.sort((a, b) => _ascending ? cmp(a, b) : cmp(b, a));
    }
    _view = view;
    _selected.retainAll(widget.rows);
    _widths = [for (var j = 0; j < _cols.length; j++) _autoWidth(j)];
  }

  static int _naturalCompare(Object? a, Object? b) {
    if (a == null || b == null) {
      return a == null && b == null ? 0 : (a == null ? -1 : 1);
    }
    if (a is num && b is num) return a.compareTo(b);
    if (a is DateTime && b is DateTime) return a.compareTo(b);
    if (a is bool && b is bool) return a == b ? 0 : (a ? 1 : -1);
    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  double _autoWidth(int j) {
    final c = _cols[j];
    if (c.width != null) return c.width!;
    var chars = c.title.length + 3; // room for the sort arrow
    final sample = widget.rows.length > 200 ? 200 : widget.rows.length;
    for (var i = 0; i < sample; i++) {
      final len = _text(c, widget.rows[i]).length;
      if (len > chars) chars = len;
    }
    return (chars * 8.5 + 32).clamp(80.0, 360.0);
  }

  Alignment _alignment(int j) {
    final c = _cols[j];
    if (c.alignment != null) return c.alignment!;
    final first = widget.rows.isEmpty ? null : c.value(widget.rows.first);
    return first is num ? Alignment.centerRight : Alignment.centerLeft;
  }

  void _toggle(int viewIndex) {
    final row = _view[viewIndex];
    setState(() =>
        _selected.contains(row) ? _selected.remove(row) : _selected.add(row));
    widget.onSelectionChanged?.call(Set<T>.of(_selected));
  }

  void _tap(int viewIndex) {
    widget.onRowTap?.call(_view[viewIndex]);
    if (widget.selectable) _toggle(viewIndex);
  }

  List<double> _fitted(double available) {
    if (!widget.stretchToFit || !available.isFinite) return _widths;
    final cols = _cols;
    final total = _widths.fold(0.0, (a, b) => a + b);
    final space = available - widget.rowTitleWidth - total;
    if (space <= 0) return _widths;
    var flexible = 0.0;
    for (var j = 0; j < cols.length; j++) {
      if (cols[j].width == null) flexible += _widths[j];
    }
    if (flexible == 0) return _widths;
    return [
      for (var j = 0; j < cols.length; j++)
        cols[j].width == null
            ? _widths[j] + space * _widths[j] / flexible
            : _widths[j],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          _table(context, _fitted(constraints.maxWidth)),
    );
  }

  Widget _table(BuildContext context, List<double> widths) {
    final cols = _cols;
    final selectedIdx = <int>{
      for (var i = 0; i < _view.length; i++)
        if (_selected.contains(_view[i])) i,
    };
    final hStyle = widget.style.headerTextStyle;
    return StickyHeadersTable(
      controller: widget.controller,
      columnsLength: cols.length,
      rowsLength: _view.length,
      legendCell: Text(widget.legend,
          style: hStyle ?? const TextStyle(fontWeight: FontWeight.bold)),
      columnsTitleBuilder: (j) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(cols[j].title,
            overflow: TextOverflow.ellipsis,
            style: hStyle ?? const TextStyle(fontWeight: FontWeight.bold)),
      ),
      rowsTitleBuilder: (i) => Text(widget.rowTitle != null
          ? widget.rowTitle!(_view[i], i)
          : (widget.rowNumbers ? '${i + 1}' : '')),
      contentCellBuilder: (j, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: cols[j].cell?.call(context, _view[i]) ??
            Text(_text(cols[j], _view[i]), overflow: TextOverflow.ellipsis),
      ),
      cellDimensions: CellDimensions.variableColumnWidth(
        columnWidths: widths,
        contentCellHeight: widget.rowHeight,
        stickyLegendWidth: widget.rowTitleWidth,
        stickyLegendHeight: widget.headerHeight,
      ),
      cellAlignments: CellAlignments.variableColumnAlignment(
        columnAlignments: [for (var j = 0; j < cols.length; j++) _alignment(j)],
        stickyRowAlignments: [
          for (var j = 0; j < cols.length; j++) _alignment(j)
        ],
        stickyColumnAlignment: Alignment.center,
        stickyLegendAlignment: Alignment.center,
      ),
      style: widget.style,
      selectedRows: selectedIdx,
      onContentCellPressed: (widget.selectable || widget.onRowTap != null)
          ? (_, i) => _tap(i)
          : null,
      onRowTitlePressed:
          (widget.selectable || widget.onRowTap != null) ? _tap : null,
      sortColumnIndex: _sortColumn,
      sortAscending: _ascending,
      onSort: (j, asc) => setState(() {
        _sortColumn = j;
        _ascending = asc;
        _recompute();
      }),
      isColumnSortable: (j) => cols[j].sortable,
      resizableColumns: widget.resizableColumns,
      showScrollbars: widget.showScrollbars,
      isLoading: widget.isLoading,
      onEndReached: widget.onEndReached,
      emptyBuilder: widget.emptyBuilder ??
          (_) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No results'),
              ),
    );
  }
}

/// Renders [rows] as CSV text using each column's title and formatted value.
/// Quotes fields that contain commas, quotes or line breaks.
String stickyTableToCsv<T>(List<StickyColumn<T>> columns, Iterable<T> rows) {
  String esc(String v) =>
      v.contains(RegExp(r'[",\n\r]')) ? '"${v.replaceAll('"', '""')}"' : v;
  final out = StringBuffer(columns.map((c) => esc(c.title)).join(','));
  for (final r in rows) {
    out.write('\n');
    out.write(columns.map((c) {
      final v = c.value(r);
      return esc(c.format != null ? c.format!(v) : (v?.toString() ?? ''));
    }).join(','));
  }
  return out.toString();
}

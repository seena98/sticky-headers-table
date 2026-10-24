export 'cell_alignments.dart';
export 'cell_dimensions.dart';
export 'sticky_data_table.dart';
export 'table_style.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'cell_alignments.dart';
import 'cell_dimensions.dart';
import 'table_style.dart';

/// Table with sticky headers. Whenever you scroll content horizontally
/// or vertically - top and left headers always stay.
///
/// Rows are built lazily, so tables with many thousands of rows stay fast.
class StickyHeadersTable extends StatefulWidget {
  StickyHeadersTable({
    super.key,

    /// Number of Columns (for content only)
    required this.columnsLength,

    /// Number of Rows (for content only)
    required this.rowsLength,

    /// Title for Top Left cell (always visible)
    this.legendCell = const Text(''),

    /// Builder for column titles. Takes index of content column as parameter.
    required this.columnsTitleBuilder,

    /// Builder for row titles. Takes index of content row as parameter.
    required this.rowsTitleBuilder,

    /// Builder for content cell. Takes index for content column first,
    /// index for content row second.
    required this.contentCellBuilder,

    /// Table cell dimensions
    this.cellDimensions = CellDimensions.base,

    /// Alignments for cell contents
    this.cellAlignments = CellAlignments.base,

    /// Colors, grid lines, zebra stripes, scroll shadows...
    this.style = const StickyTableStyle(),

    /// Tap callbacks
    this.onStickyLegendPressed,
    this.onColumnTitlePressed,
    this.onRowTitlePressed,
    this.onContentCellPressed,

    /// Extra gestures for content cells. [onContentCellSecondaryTap] is the
    /// right mouse button / two finger tap and receives the global position,
    /// handy for context menus.
    this.onContentCellDoubleTap,
    this.onContentCellLongPress,
    this.onContentCellSecondaryTap,

    /// Rows drawn with [StickyTableStyle.selectedRowColor].
    this.selectedRows = const <int>{},

    /// Sorting. When [onSort] is set, tapping a column title calls it with the
    /// new direction and an arrow is drawn on [sortColumnIndex]. Sorting the
    /// data is up to you.
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.isColumnSortable,

    /// Let users drag the right edge of a column title to resize the column.
    this.resizableColumns = false,
    this.minColumnWidth = 40.0,
    this.onColumnResized,

    /// Shown in the body when [rowsLength] is 0.
    this.emptyBuilder,

    /// Shows a thin progress bar under the sticky row.
    this.isLoading = false,

    /// Called once when the user scrolls within [endReachedThreshold] pixels
    /// of the last row (also when the rows don't fill the viewport). Use it
    /// for infinite scrolling; it fires again after [rowsLength] changes.
    this.onEndReached,
    this.endReachedThreshold = 200.0,

    /// Initial scroll offsets in X and Y directions
    this.initialScrollOffsetX = 0.0,
    this.initialScrollOffsetY = 0.0,

    /// Called when scrolling has ended, passing the current offset position
    this.onEndScrolling,

    /// Scroll controllers for the table
    this.scrollControllers,

    /// Programmatic scrolling (jumpTo, animateTo, scrollToRow, ...)
    this.controller,

    /// Draw scrollbars (horizontal and vertical) around the content.
    this.showScrollbars = false,

    /// Allow dragging with mouse / trackpad / stylus, not just touch.
    this.enableMouseDrag = true,
    this.physics,
  }) {
    cellDimensions.runAssertions(rowsLength, columnsLength);
    cellAlignments.runAssertions(rowsLength, columnsLength);
  }

  /// Shortest way to a table: plain strings. `data[row][column]`.
  ///
  /// ```dart
  /// StickyHeadersTable.text(
  ///   columnTitles: ['Name', 'Age'],
  ///   rowTitles: ['#1', '#2'],
  ///   data: [['Ann', '31'], ['Bob', '27']],
  /// )
  /// ```
  StickyHeadersTable.text({
    Key? key,
    required List<String> columnTitles,
    required List<String> rowTitles,
    required List<List<String>> data,
    String legend = '',
    TextStyle? headerTextStyle = const TextStyle(fontWeight: FontWeight.bold),
    TextStyle? textStyle,
    CellDimensions cellDimensions = CellDimensions.base,
    CellAlignments cellAlignments = CellAlignments.base,
    StickyTableStyle style = const StickyTableStyle(),
    Set<int> selectedRows = const <int>{},
    void Function(int columnIndex, int rowIndex)? onContentCellPressed,
    ValueChanged<int>? onRowTitlePressed,
    int? sortColumnIndex,
    bool sortAscending = true,
    void Function(int columnIndex, bool ascending)? onSort,
    bool resizableColumns = false,
    bool showScrollbars = false,
    StickyTableController? controller,
  }) : this(
          key: key,
          columnsLength: columnTitles.length,
          rowsLength: rowTitles.length,
          legendCell: Text(legend, style: headerTextStyle),
          columnsTitleBuilder: (j) =>
              Text(columnTitles[j], style: headerTextStyle),
          rowsTitleBuilder: (i) => Text(rowTitles[i], style: headerTextStyle),
          contentCellBuilder: (j, i) => Text(data[i][j], style: textStyle),
          cellDimensions: cellDimensions,
          cellAlignments: cellAlignments,
          style: style,
          selectedRows: selectedRows,
          onContentCellPressed: onContentCellPressed,
          onRowTitlePressed: onRowTitlePressed,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          onSort: onSort,
          resizableColumns: resizableColumns,
          showScrollbars: showScrollbars,
          controller: controller,
        );

  final int rowsLength;
  final int columnsLength;
  final Widget legendCell;
  final Widget Function(int columnIndex) columnsTitleBuilder;
  final Widget Function(int rowIndex) rowsTitleBuilder;
  final Widget Function(int columnIndex, int rowIndex) contentCellBuilder;
  final CellDimensions cellDimensions;
  final CellAlignments cellAlignments;
  final StickyTableStyle style;
  final VoidCallback? onStickyLegendPressed;
  final ValueChanged<int>? onColumnTitlePressed;
  final ValueChanged<int>? onRowTitlePressed;
  final void Function(int columnIndex, int rowIndex)? onContentCellPressed;
  final void Function(int columnIndex, int rowIndex)? onContentCellDoubleTap;
  final void Function(int columnIndex, int rowIndex)? onContentCellLongPress;
  final void Function(int columnIndex, int rowIndex, Offset globalPosition)?
      onContentCellSecondaryTap;
  final Set<int> selectedRows;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;
  final bool Function(int columnIndex)? isColumnSortable;
  final bool resizableColumns;
  final double minColumnWidth;
  final void Function(int columnIndex, double width)? onColumnResized;
  final WidgetBuilder? emptyBuilder;
  final bool isLoading;
  final VoidCallback? onEndReached;
  final double endReachedThreshold;
  final double initialScrollOffsetX;
  final double initialScrollOffsetY;
  final void Function(double x, double y)? onEndScrolling;
  final ScrollControllers? scrollControllers;
  final StickyTableController? controller;
  final bool showScrollbars;
  final bool enableMouseDrag;
  final ScrollPhysics? physics;

  @override
  State<StickyHeadersTable> createState() => _StickyHeadersTableState();
}

class _StickyHeadersTableState extends State<StickyHeadersTable> {
  ScrollControllers? _ownedControllers;
  late ScrollControllers _controllers;
  late _SyncScrollController _horizontalSync;
  late _SyncScrollController _verticalSync;

  List<double> _baseWidths = const [];
  List<double> _colWidths = const [];
  List<double> _rowHeights = const [];

  late double _scrollOffsetX;
  late double _scrollOffsetY;
  bool _scrolledX = false;
  bool _scrolledY = false;
  bool _endReachedFired = false;
  int _hoveredRow = -1;

  @override
  void initState() {
    super.initState();
    _scrollOffsetX = widget.initialScrollOffsetX;
    _scrollOffsetY = widget.initialScrollOffsetY;
    _bindControllers();
    _syncDimensions();
    widget.controller?._state = this;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _jumpAll(_controllers.horizontalControllers, widget.initialScrollOffsetX);
      _jumpAll(_controllers.verticalControllers, widget.initialScrollOffsetY);
      _checkEndReached();
    });
  }

  @override
  void didUpdateWidget(StickyHeadersTable old) {
    super.didUpdateWidget(old);
    if (old.scrollControllers != widget.scrollControllers) {
      _bindControllers();
    }
    if (old.controller != widget.controller) {
      if (old.controller?._state == this) old.controller!._state = null;
      widget.controller?._state = this;
    }
    _syncDimensions();
    if (old.rowsLength != widget.rowsLength) {
      _endReachedFired = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkEndReached();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller!._state = null;
    _ownedControllers?.dispose();
    super.dispose();
  }

  void _bindControllers() {
    _ownedControllers?.dispose();
    _ownedControllers = null;
    if (widget.scrollControllers == null) {
      _ownedControllers = ScrollControllers();
    }
    _controllers = widget.scrollControllers ?? _ownedControllers!;
    _verticalSync = _SyncScrollController(_controllers.verticalControllers);
    _horizontalSync = _SyncScrollController(_controllers.horizontalControllers);
  }

  void _syncDimensions() {
    final dims = widget.cellDimensions;
    final base = List<double>.generate(widget.columnsLength, dims.stickyWidth);
    if (!_sameList(base, _baseWidths)) {
      _baseWidths = base;
      _colWidths = List<double>.of(base);
    }
    _rowHeights = List<double>.generate(widget.rowsLength, dims.stickyHeight);
  }

  static bool _sameList(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static void _jumpAll(List<ScrollController> controllers, double offset) {
    for (final c in controllers) {
      if (!c.hasClients) continue;
      c.jumpTo(offset.clamp(0.0, c.position.maxScrollExtent));
    }
  }

  double get _totalWidth => _colWidths.fold(0.0, (a, b) => a + b);

  // ---- scrolling ---------------------------------------------------------

  /// Returns true when the notification was consumed.
  bool _onNotification(
    ScrollNotification n,
    Axis axis,
    _SyncScrollController sync,
    ScrollController controller,
  ) {
    if (n.metrics.axis != axis) return false;
    final ended = sync.processNotification(n, controller);
    if (ended) {
      if (axis == Axis.horizontal) {
        _scrollOffsetX = controller.offset;
      } else {
        _scrollOffsetY = controller.offset;
      }
      widget.onEndScrolling?.call(_scrollOffsetX, _scrollOffsetY);
    }
    if (n is ScrollUpdateNotification) {
      _updateShadows();
      if (axis == Axis.vertical) _checkEndReached();
    }
    return true;
  }

  bool _onBodyNotification(ScrollNotification n) {
    if (n.metrics.axis == Axis.horizontal) {
      return _onNotification(n, Axis.horizontal, _horizontalSync,
          _controllers.horizontalBodyController);
    }
    return _onNotification(
        n, Axis.vertical, _verticalSync, _controllers.verticalBodyController);
  }

  void _updateShadows() {
    if (!widget.style.showScrollShadows) return;
    final h = _controllers.horizontalBodyController;
    final v = _controllers.verticalBodyController;
    final sx = h.hasClients && h.offset > 0.5;
    final sy = v.hasClients && v.offset > 0.5;
    if (sx != _scrolledX || sy != _scrolledY) {
      setState(() {
        _scrolledX = sx;
        _scrolledY = sy;
      });
    }
  }

  void _checkEndReached() {
    final cb = widget.onEndReached;
    final c = _controllers.verticalBodyController;
    if (cb == null || !c.hasClients) return;
    final p = c.position;
    final near = p.pixels >= p.maxScrollExtent - widget.endReachedThreshold;
    if (near && !_endReachedFired) {
      _endReachedFired = true;
      cb();
    } else if (!near) {
      _endReachedFired = false;
    }
  }

  double _columnOffset(int j) {
    var o = 0.0;
    for (var i = 0; i < j && i < _colWidths.length; i++) {
      o += _colWidths[i];
    }
    return o;
  }

  double _rowOffset(int i) {
    var o = 0.0;
    for (var k = 0; k < i && k < _rowHeights.length; k++) {
      o += _rowHeights[k];
    }
    return o;
  }

  Future<void> _scrollTo(
    ScrollController c,
    double offset,
    Duration? duration,
    Curve curve,
  ) async {
    if (!c.hasClients) return;
    final target = offset.clamp(0.0, c.position.maxScrollExtent);
    if (duration == null || duration == Duration.zero) {
      c.jumpTo(target);
    } else {
      await c.animateTo(target, duration: duration, curve: curve);
    }
  }

  // ---- cell building -----------------------------------------------------

  Color? _rowColor(int row) {
    final s = widget.style;
    if (widget.selectedRows.contains(row)) return s.selectedRowColor;
    if (row == _hoveredRow && s.hoverRowColor != null) return s.hoverRowColor;
    if (row.isOdd && s.stripeColor != null) return s.stripeColor;
    return s.contentColor;
  }

  Widget _hoverable(int row, Widget child) {
    if (widget.style.hoverRowColor == null) return child;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRow = row),
      onExit: (_) {
        if (_hoveredRow == row) setState(() => _hoveredRow = -1);
      },
      child: child,
    );
  }

  Widget _legend() {
    final s = widget.style;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onStickyLegendPressed,
      child: Container(
        width: widget.cellDimensions.stickyLegendWidth,
        height: widget.cellDimensions.stickyLegendHeight,
        alignment: widget.cellAlignments.stickyLegendAlignment,
        decoration: s.decoration(s.legendColor ?? s.headerColor),
        child: widget.legendCell,
      ),
    );
  }

  Widget _columnHeader(int j) {
    final s = widget.style;
    final height = widget.cellDimensions.stickyLegendHeight;
    final sorted = widget.sortColumnIndex == j;
    final sortable =
        widget.onSort != null && (widget.isColumnSortable?.call(j) ?? true);

    Widget content = widget.columnsTitleBuilder(j);
    if (sorted && widget.onSort != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: content),
          Icon(
            widget.sortAscending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: s.sortIconSize,
            color: s.headerTextStyle?.color,
          ),
        ],
      );
    }

    Widget cell = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (widget.onColumnTitlePressed == null && !sortable)
          ? null
          : () {
              widget.onColumnTitlePressed?.call(j);
              if (sortable) {
                widget.onSort!(j, sorted ? !widget.sortAscending : true);
              }
            },
      child: Container(
        width: _colWidths[j],
        height: height,
        alignment: widget.cellAlignments.rowAlignment(j),
        decoration: s.decoration(s.headerColor),
        child: content,
      ),
    );
    if (sortable) {
      cell = MouseRegion(cursor: SystemMouseCursors.click, child: cell);
    }
    if (!widget.resizableColumns) return cell;

    return SizedBox(
      width: _colWidths[j],
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: cell),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 10,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (d) => _resizeColumn(j, d.delta.dx),
                onHorizontalDragEnd: (_) =>
                    widget.onColumnResized?.call(j, _colWidths[j]),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resizeColumn(int j, double delta) {
    final w = (_colWidths[j] + delta).clamp(widget.minColumnWidth, 4000.0);
    if (w == _colWidths[j]) return;
    setState(() => _colWidths = List<double>.of(_colWidths)..[j] = w);
  }

  Widget _rowTitle(int i) {
    final s = widget.style;
    final color = _rowColor(i);
    return _hoverable(
      i,
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onRowTitlePressed == null
            ? null
            : () => widget.onRowTitlePressed!(i),
        child: Container(
          width: widget.cellDimensions.stickyLegendWidth,
          height: _rowHeights[i],
          alignment: widget.cellAlignments.columnAlignment(i),
          decoration: s.decoration(
            widget.selectedRows.contains(i) || i == _hoveredRow
                ? color
                : s.headerColor ?? color,
          ),
          child: widget.rowsTitleBuilder(i),
        ),
      ),
    );
  }

  Widget _contentRow(int i) {
    final s = widget.style;
    final color = _rowColor(i);
    final h = _rowHeights[i];
    return _hoverable(
      i,
      SizedBox(
        height: h,
        width: _totalWidth,
        child: Row(
          children: [
            for (var j = 0; j < widget.columnsLength; j++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onContentCellPressed == null
                    ? null
                    : () => widget.onContentCellPressed!(j, i),
                onDoubleTap: widget.onContentCellDoubleTap == null
                    ? null
                    : () => widget.onContentCellDoubleTap!(j, i),
                onLongPress: widget.onContentCellLongPress == null
                    ? null
                    : () => widget.onContentCellLongPress!(j, i),
                onSecondaryTapUp: widget.onContentCellSecondaryTap == null
                    ? null
                    : (d) => widget.onContentCellSecondaryTap!(
                        j, i, d.globalPosition),
                child: Container(
                  width: _colWidths[j],
                  height: h,
                  alignment: widget.cellAlignments.contentAlignment(i, j),
                  decoration: s.decoration(color),
                  child: widget.contentCellBuilder(j, i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _shadow({required bool vertical}) {
    final s = widget.style;
    final gradient = LinearGradient(
      begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
      end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
      colors: [s.shadowColor, s.shadowColor.withValues(alpha: 0)],
    );
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: (vertical ? _scrolledY : _scrolledX) ? 1 : 0,
        child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dims = widget.cellDimensions;
    final c = _controllers;
    final physics = widget.physics;

    Widget body = NotificationListener<ScrollNotification>(
      onNotification: _onBodyNotification,
      child: _maybeScrollbars(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: c.horizontalBodyController,
          physics: physics,
          child: SizedBox(
            width: _totalWidth,
            child: ListView.builder(
              controller: c.verticalBodyController,
              physics: physics,
              padding: EdgeInsets.zero,
              itemCount: widget.rowsLength,
              itemExtentBuilder: (i, _) => _rowHeights[i],
              itemBuilder: (_, i) => _contentRow(i),
            ),
          ),
        ),
      ),
    );

    final stickyColumn = NotificationListener<ScrollNotification>(
      onNotification: (n) => _onNotification(
          n, Axis.vertical, _verticalSync, c.verticalTitleController),
      child: SizedBox(
        width: dims.stickyLegendWidth,
        child: ListView.builder(
          controller: c.verticalTitleController,
          physics: physics,
          padding: EdgeInsets.zero,
          itemCount: widget.rowsLength,
          itemExtentBuilder: (i, _) => _rowHeights[i],
          itemBuilder: (_, i) => _rowTitle(i),
        ),
      ),
    );

    final stickyRow = NotificationListener<ScrollNotification>(
      onNotification: (n) => _onNotification(
          n, Axis.horizontal, _horizontalSync, c.horizontalTitleController),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: c.horizontalTitleController,
        physics: physics,
        child: Row(
          children: [
            for (var j = 0; j < widget.columnsLength; j++) _columnHeader(j),
          ],
        ),
      ),
    );

    final empty = widget.rowsLength == 0 && widget.emptyBuilder != null;
    final s = widget.style;

    Widget styled(TextStyle? t, Widget child) =>
        t == null ? child : DefaultTextStyle.merge(style: t, child: child);

    Widget table = Stack(
      children: [
        Column(
          children: [
            styled(
              s.headerTextStyle,
              Row(children: [_legend(), Expanded(child: stickyRow)]),
            ),
            Expanded(
              child: empty
                  ? Center(child: widget.emptyBuilder!(context))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        styled(s.headerTextStyle, stickyColumn),
                        Expanded(child: styled(s.textStyle, body)),
                      ],
                    ),
            ),
          ],
        ),
        if (s.showScrollShadows) ...[
          Positioned(
            top: dims.stickyLegendHeight,
            left: 0,
            right: 0,
            height: s.shadowExtent,
            child: _shadow(vertical: true),
          ),
          Positioned(
            top: dims.stickyLegendHeight,
            bottom: 0,
            left: dims.stickyLegendWidth,
            width: s.shadowExtent,
            child: _shadow(vertical: false),
          ),
        ],
        if (widget.isLoading)
          Positioned(
            top: dims.stickyLegendHeight,
            left: 0,
            right: 0,
            child: const LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );

    final base = ScrollConfiguration.of(context);
    return ScrollConfiguration(
      behavior: base.copyWith(
        scrollbars: false,
        dragDevices: widget.enableMouseDrag
            ? {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.invertedStylus,
                PointerDeviceKind.trackpad,
              }
            : base.dragDevices,
      ),
      child: table,
    );
  }

  Widget _maybeScrollbars({required Widget child}) {
    if (!widget.showScrollbars) return child;
    return Scrollbar(
      controller: _controllers.verticalBodyController,
      notificationPredicate: (n) => n.depth == 1,
      child: Scrollbar(
        controller: _controllers.horizontalBodyController,
        child: child,
      ),
    );
  }
}

/// Programmatic access to a [StickyHeadersTable]'s scroll position.
///
/// Pass the same instance to [StickyHeadersTable.controller]. Methods do
/// nothing while no table is attached. A `null` or zero duration jumps.
class StickyTableController {
  _StickyHeadersTableState? _state;

  bool get isAttached => _state != null;

  double get offsetX {
    final c = _state?._controllers.horizontalBodyController;
    return c != null && c.hasClients ? c.offset : 0.0;
  }

  double get offsetY {
    final c = _state?._controllers.verticalBodyController;
    return c != null && c.hasClients ? c.offset : 0.0;
  }

  /// Current width of a content column (reflects user resizing).
  double? columnWidth(int column) {
    final w = _state?._colWidths;
    return w != null && column >= 0 && column < w.length ? w[column] : null;
  }

  Future<void> scrollTo({
    double? x,
    double? y,
    Duration? duration,
    Curve curve = Curves.easeInOut,
  }) async {
    final s = _state;
    if (s == null) return;
    await Future.wait([
      if (x != null)
        s._scrollTo(
            s._controllers.horizontalBodyController, x, duration, curve),
      if (y != null)
        s._scrollTo(s._controllers.verticalBodyController, y, duration, curve),
    ]);
  }

  Future<void> scrollToRow(int row,
          {Duration? duration, Curve curve = Curves.easeInOut}) =>
      scrollTo(y: _state?._rowOffset(row), duration: duration, curve: curve);

  Future<void> scrollToColumn(int column,
          {Duration? duration, Curve curve = Curves.easeInOut}) =>
      scrollTo(
          x: _state?._columnOffset(column), duration: duration, curve: curve);

  Future<void> scrollToTop({Duration? duration}) =>
      scrollTo(y: 0, duration: duration);
}

class ScrollControllers {
  ScrollControllers({
    ScrollController? verticalTitleController,
    ScrollController? verticalBodyController,
    ScrollController? horizontalBodyController,
    ScrollController? horizontalTitleController,
  })  : _ownsAll = verticalTitleController == null &&
            verticalBodyController == null &&
            horizontalBodyController == null &&
            horizontalTitleController == null,
        verticalTitleController = verticalTitleController ?? ScrollController(),
        verticalBodyController = verticalBodyController ?? ScrollController(),
        horizontalBodyController =
            horizontalBodyController ?? ScrollController(),
        horizontalTitleController =
            horizontalTitleController ?? ScrollController();

  final bool _ownsAll;
  final ScrollController verticalTitleController;
  final ScrollController verticalBodyController;
  final ScrollController horizontalBodyController;
  final ScrollController horizontalTitleController;

  List<ScrollController> get verticalControllers =>
      [verticalTitleController, verticalBodyController];
  List<ScrollController> get horizontalControllers =>
      [horizontalTitleController, horizontalBodyController];

  /// Disposes the controllers only when this object created all of them.
  void dispose() {
    if (!_ownsAll) return;
    verticalTitleController.dispose();
    verticalBodyController.dispose();
    horizontalBodyController.dispose();
    horizontalTitleController.dispose();
  }
}

/// SyncScrollController keeps scroll controllers in sync.
class _SyncScrollController {
  _SyncScrollController(this._controllers);

  final List<ScrollController> _controllers;

  ScrollController? _scrollingController;
  bool _scrollingActive = false;

  /// Returns true if reached scroll end
  bool processNotification(
    ScrollNotification notification,
    ScrollController controller,
  ) {
    if (notification is ScrollStartNotification && !_scrollingActive) {
      _scrollingController = controller;
      _scrollingActive = true;
      return false;
    }

    final scrolling = _scrollingController;
    if (scrolling != null && identical(controller, scrolling)) {
      if (notification is ScrollEndNotification) {
        _scrollingController = null;
        _scrollingActive = false;
        return true;
      }

      if (notification is ScrollUpdateNotification) {
        for (final other in _controllers) {
          if (identical(scrolling, other) || !other.hasClients) continue;
          other.jumpTo(scrolling.offset);
        }
      }
    }
    return false;
  }
}

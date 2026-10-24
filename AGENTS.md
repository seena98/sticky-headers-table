# AGENTS.md

Guidance for AI coding agents working on `flutter_table` (a Flutter package).

## Layout

| Path | Purpose |
| --- | --- |
| `lib/table_sticky_headers.dart` | Public entry point (re-exports everything). Holds `StickyHeadersTable`, its State, `StickyTableController`, `ScrollControllers`, `_SyncScrollController`. |
| `lib/sticky_data_table.dart` | `StickyDataTable<T>`, `StickyColumn<T>`, `stickyTableToCsv`. Thin layer over `StickyHeadersTable` (sort/search/selection/auto-width live here). |
| `lib/table_style.dart` | `StickyTableStyle` + theme presets. |
| `lib/cell_dimensions.dart`, `lib/cell_alignments.dart` | Legacy sizing/alignment value classes (still public API). |
| `test/` | Widget tests. |
| `example/` | Theme-gallery app; all six platform runners. Accepts `?theme=Ocean` on web. |
| `doc/screenshots/` | README images, generated from the example (see below). |

## Commands

```sh
flutter pub get
flutter analyze          # must be clean (flutter_lints)
dart format lib test example/lib
flutter test             # must pass
cd example && flutter analyze && flutter build web
```

## Architecture notes

* Four `ScrollController`s (title/body × horizontal/vertical) are kept in sync
  by `_SyncScrollController`, driven by `ScrollNotification`s. Notifications are
  filtered by axis; body notifications are handled by one outer listener so that
  optional `Scrollbar`s (depth 1 predicate for vertical) still see them.
* Rows are `ListView.builder` with `itemExtentBuilder` (row heights come from
  `CellDimensions`). Column widths live in state (`_colWidths`) so resizing works;
  they reset only when the widths computed from `CellDimensions` change.
* Default `ScrollControllers` are owned by the State and disposed there;
  user-supplied ones are never disposed by the table.
* Builder index order is `(column, row)` for content cells and callbacks, but
  `CellAlignments.contentAlignment(row, column)` / `CellDimensions.contentSize(row, column)`.
  Don't mix them up.
* `StickyDataTable` sort index refers to **visible** columns (after `hiddenColumns`).

## Conventions

* Keep the 1.x builder API source-compatible; add features as optional named params.
* Features default to *off* so the default look is the plain table.
* New visual options go in `StickyTableStyle` (and `copyWith`); new themes are
  `static const` and must be added to `StickyTableStyle.presets`.
* Add a widget test for every new behaviour; keep README feature table, CHANGELOG
  and this file in sync.
* Don't add dependencies; the package depends only on Flutter.

## Regenerating screenshots

```sh
cd example && flutter build web --release
(cd build/web && python3 -m http.server 8765 &)
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new \
  --window-size=900,560 --virtual-time-budget=15000 \
  --screenshot=../doc/screenshots/ocean.png "http://localhost:8765/?theme=Ocean"
```

## Known gaps

Multiple frozen columns/rows, pinned footer, merged cells, keyboard navigation,
RTL verification.

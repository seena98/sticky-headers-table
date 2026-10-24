## 2.0.0

Complete rewrite on top of the 1.x builder API.

* **Platforms:** Android, iOS, web, macOS, Windows, Linux (example runs on all).
* **SDK:** Dart 3.5+, Flutter 3.27+ (1.x was capped at Dart <3 and would not resolve).
* **New:** `StickyDataTable<T>` – typed rows + `StickyColumn`s with built-in
  sorting, search, selection, auto column widths, stretch-to-fit, hidden
  columns; `stickyTableToCsv` export.
* **New:** `StickyHeadersTable.text` for plain string data.
* **New:** `StickyTableStyle` with 13 presets (minimal, ocean, midnight,
  sunset, forest, rose, ledger, slate, mint, lavender, coffee, neon,
  contrast) plus `StickyTableStyle.material(context)`; zebra rows, grid lines,
  hover / selected rows, scroll shadows, header text styles.
* **New:** lazy row building (virtualized).
* **New:** sort indicators, resizable columns, empty / loading states,
  `onEndReached`, double tap / long press / secondary tap, scrollbars,
  mouse & trackpad drag scrolling.
* **New:** `StickyTableController` (`scrollTo`, `scrollToRow`,
  `scrollToColumn`, offsets, column widths).
* **Fixed:** initial offset was re-applied on every rebuild; default scroll
  controllers were recreated on parent rebuilds and never disposed; sync
  controllers were rebuilt on every `build`.
* **Changed:** tap callbacks are nullable; `ScrollControllers` fields are public.

## 1.1.0
* Fixed some minor issues.

## 1.0.0
* Added null-safety. Forked from table_sticky_headers.

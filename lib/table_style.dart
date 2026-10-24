import 'package:flutter/material.dart';

/// Visual styling for [StickyHeadersTable]. Every field is optional; a `null`
/// color means "draw nothing", so the default style looks like the plain table.
@immutable
class StickyTableStyle {
  const StickyTableStyle({
    this.headerColor,
    this.legendColor,
    this.contentColor,
    this.stripeColor,
    this.selectedRowColor,
    this.hoverRowColor,
    this.gridLineColor,
    this.gridLineWidth = 1.0,
    this.showScrollShadows = false,
    this.shadowColor = const Color(0x33000000),
    this.shadowExtent = 6.0,
    this.sortIconSize = 16.0,
    this.headerTextStyle,
    this.textStyle,
  });

  /// A ready-made, Material-flavoured style derived from the [ThemeData].
  factory StickyTableStyle.material(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StickyTableStyle(
      headerColor: scheme.surfaceContainerHighest,
      legendColor: scheme.surfaceContainerHighest,
      stripeColor: scheme.onSurface.withValues(alpha: 0.04),
      selectedRowColor: scheme.primary.withValues(alpha: 0.16),
      hoverRowColor: scheme.onSurface.withValues(alpha: 0.08),
      gridLineColor: scheme.outlineVariant,
      showScrollShadows: true,
    );
  }

  // ---- ready-made themes ------------------------------------------------

  /// Every preset by name, handy for a theme picker.
  static const Map<String, StickyTableStyle> presets = {
    'Minimal': minimal,
    'Ocean': ocean,
    'Midnight': midnight,
    'Sunset': sunset,
    'Forest': forest,
    'Rose': rose,
    'Ledger': ledger,
    'Slate': slate,
    'Mint': mint,
    'Lavender': lavender,
    'Coffee': coffee,
    'Neon': neon,
    'Contrast': contrast,
  };

  /// Clean white, hairlines only.
  static const StickyTableStyle minimal = StickyTableStyle(
    headerColor: Color(0xFFFAFAFA),
    contentColor: Colors.white,
    gridLineColor: Color(0xFFEAEAEA),
    selectedRowColor: Color(0xFFE8F0FE),
    hoverRowColor: Color(0xFFF5F5F5),
    showScrollShadows: true,
    headerTextStyle: TextStyle(
        color: Color(0xFF555555), fontWeight: FontWeight.w600, fontSize: 13),
    textStyle: TextStyle(color: Color(0xFF222222), fontSize: 14),
  );

  /// Cool blues with soft zebra rows.
  static const StickyTableStyle ocean = StickyTableStyle(
    headerColor: Color(0xFF0B5FA5),
    legendColor: Color(0xFF084A82),
    contentColor: Color(0xFFF4F9FD),
    stripeColor: Color(0xFFE3F0FA),
    selectedRowColor: Color(0xFFB9DBF5),
    hoverRowColor: Color(0xFFD3E8F8),
    gridLineColor: Color(0xFFCFE3F3),
    showScrollShadows: true,
    shadowColor: Color(0x330B5FA5),
    headerTextStyle: TextStyle(
        color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.3),
    textStyle: TextStyle(color: Color(0xFF0D2B45)),
  );

  /// Dark mode with an indigo accent.
  static const StickyTableStyle midnight = StickyTableStyle(
    headerColor: Color(0xFF1E2233),
    legendColor: Color(0xFF171A28),
    contentColor: Color(0xFF12141F),
    stripeColor: Color(0xFF181B2A),
    selectedRowColor: Color(0xFF2E3566),
    hoverRowColor: Color(0xFF222640),
    gridLineColor: Color(0xFF262A40),
    showScrollShadows: true,
    shadowColor: Color(0x99000000),
    headerTextStyle: TextStyle(
        color: Color(0xFFB4BCFF), fontWeight: FontWeight.w700, fontSize: 13),
    textStyle: TextStyle(color: Color(0xFFE4E6F5)),
  );

  /// Warm oranges.
  static const StickyTableStyle sunset = StickyTableStyle(
    headerColor: Color(0xFFFF7A45),
    legendColor: Color(0xFFE85D26),
    contentColor: Color(0xFFFFFAF5),
    stripeColor: Color(0xFFFFEFE2),
    selectedRowColor: Color(0xFFFFCDB0),
    hoverRowColor: Color(0xFFFFE0CC),
    gridLineColor: Color(0xFFFFDCC7),
    showScrollShadows: true,
    shadowColor: Color(0x33E85D26),
    headerTextStyle:
        TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
    textStyle: TextStyle(color: Color(0xFF4A2511)),
  );

  /// Calm greens.
  static const StickyTableStyle forest = StickyTableStyle(
    headerColor: Color(0xFF2E7D4F),
    legendColor: Color(0xFF225C3A),
    contentColor: Color(0xFFF6FBF7),
    stripeColor: Color(0xFFE8F4EB),
    selectedRowColor: Color(0xFFBFE3C9),
    hoverRowColor: Color(0xFFD6ECDB),
    gridLineColor: Color(0xFFD3E8D9),
    showScrollShadows: true,
    shadowColor: Color(0x332E7D4F),
    headerTextStyle:
        TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    textStyle: TextStyle(color: Color(0xFF14301F)),
  );

  /// Soft pinks, no grid, rounded-feeling zebra.
  static const StickyTableStyle rose = StickyTableStyle(
    headerColor: Color(0xFFFCE4EC),
    legendColor: Color(0xFFF8BBD0),
    contentColor: Colors.white,
    stripeColor: Color(0xFFFFF5F8),
    selectedRowColor: Color(0xFFF8BBD0),
    hoverRowColor: Color(0xFFFDE9F0),
    showScrollShadows: true,
    shadowColor: Color(0x22AD1457),
    headerTextStyle: TextStyle(
        color: Color(0xFF880E4F), fontWeight: FontWeight.w700, fontSize: 13),
    textStyle: TextStyle(color: Color(0xFF3B1022)),
  );

  /// Accounting-paper look: green bars and ruled lines.
  static const StickyTableStyle ledger = StickyTableStyle(
    headerColor: Color(0xFFDDEBD5),
    legendColor: Color(0xFFC9DFBE),
    contentColor: Color(0xFFFFFFF4),
    stripeColor: Color(0xFFF1F8E9),
    selectedRowColor: Color(0xFFFFF59D),
    hoverRowColor: Color(0xFFF9FBE7),
    gridLineColor: Color(0xFFB7CFA8),
    headerTextStyle: TextStyle(
        color: Color(0xFF1B3A12),
        fontWeight: FontWeight.w800,
        fontFamily: 'monospace'),
    textStyle: TextStyle(color: Color(0xFF1B3A12), fontFamily: 'monospace'),
  );

  /// Neutral blue-grey, a good default for dashboards.
  static const StickyTableStyle slate = StickyTableStyle(
    headerColor: Color(0xFF334155),
    legendColor: Color(0xFF1E293B),
    contentColor: Color(0xFFF8FAFC),
    stripeColor: Color(0xFFF1F5F9),
    selectedRowColor: Color(0xFFCBD5E1),
    hoverRowColor: Color(0xFFE2E8F0),
    gridLineColor: Color(0xFFE2E8F0),
    showScrollShadows: true,
    headerTextStyle: TextStyle(
        color: Color(0xFFF1F5F9), fontWeight: FontWeight.w600, fontSize: 13),
    textStyle: TextStyle(color: Color(0xFF0F172A)),
  );

  /// Fresh teal-mint.
  static const StickyTableStyle mint = StickyTableStyle(
    headerColor: Color(0xFFD5F5EC),
    legendColor: Color(0xFFB5ECDC),
    contentColor: Colors.white,
    stripeColor: Color(0xFFF1FBF8),
    selectedRowColor: Color(0xFFA8E6D2),
    hoverRowColor: Color(0xFFE2F7F0),
    gridLineColor: Color(0xFFD5F5EC),
    showScrollShadows: true,
    shadowColor: Color(0x221B8F72),
    headerTextStyle: TextStyle(
        color: Color(0xFF0B5A46), fontWeight: FontWeight.w700, fontSize: 13),
    textStyle: TextStyle(color: Color(0xFF0E3B2F)),
  );

  /// Gentle purples.
  static const StickyTableStyle lavender = StickyTableStyle(
    headerColor: Color(0xFF7E57C2),
    legendColor: Color(0xFF5E35B1),
    contentColor: Color(0xFFFAF7FF),
    stripeColor: Color(0xFFF0EAFB),
    selectedRowColor: Color(0xFFD1C0F0),
    hoverRowColor: Color(0xFFE4D9F7),
    gridLineColor: Color(0xFFE4D9F7),
    showScrollShadows: true,
    shadowColor: Color(0x335E35B1),
    headerTextStyle:
        TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    textStyle: TextStyle(color: Color(0xFF2A1B4D)),
  );

  /// Cream paper and espresso browns.
  static const StickyTableStyle coffee = StickyTableStyle(
    headerColor: Color(0xFF5D4037),
    legendColor: Color(0xFF3E2723),
    contentColor: Color(0xFFFBF6F0),
    stripeColor: Color(0xFFF3E9DD),
    selectedRowColor: Color(0xFFE0C9AE),
    hoverRowColor: Color(0xFFEBDCCB),
    gridLineColor: Color(0xFFE6D5C3),
    showScrollShadows: true,
    shadowColor: Color(0x333E2723),
    headerTextStyle: TextStyle(
        color: Color(0xFFFFE8CC),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4),
    textStyle: TextStyle(color: Color(0xFF3E2723)),
  );

  /// Dark with cyan / magenta accents.
  static const StickyTableStyle neon = StickyTableStyle(
    headerColor: Color(0xFF0A0A14),
    legendColor: Color(0xFF000000),
    contentColor: Color(0xFF05050D),
    stripeColor: Color(0xFF0C0C1A),
    selectedRowColor: Color(0xFF4A0E4E),
    hoverRowColor: Color(0xFF14142B),
    gridLineColor: Color(0xFF1F2A44),
    showScrollShadows: true,
    shadowColor: Color(0xCC00E5FF),
    headerTextStyle: TextStyle(
        color: Color(0xFF00E5FF),
        fontWeight: FontWeight.w800,
        letterSpacing: 1),
    textStyle: TextStyle(color: Color(0xFFFF4DFF)),
  );

  /// Black and white, thick lines. Accessible and printable.
  static const StickyTableStyle contrast = StickyTableStyle(
    headerColor: Colors.black,
    contentColor: Colors.white,
    stripeColor: Color(0xFFEFEFEF),
    selectedRowColor: Color(0xFFFFEB3B),
    hoverRowColor: Color(0xFFDDDDDD),
    gridLineColor: Colors.black,
    gridLineWidth: 1.5,
    headerTextStyle:
        TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
    textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
  );

  /// Background of the sticky column and row cells.
  final Color? headerColor;

  /// Background of the top-left legend cell. Falls back to [headerColor].
  final Color? legendColor;

  /// Background of content cells.
  final Color? contentColor;

  /// Background of every odd content row (zebra striping).
  final Color? stripeColor;

  /// Background of rows listed in [StickyHeadersTable.selectedRows].
  final Color? selectedRowColor;

  /// Background of the row under the mouse pointer.
  final Color? hoverRowColor;

  /// Color of the lines between cells. `null` hides the grid.
  final Color? gridLineColor;
  final double gridLineWidth;

  /// Fade a shadow under the sticky row / next to the sticky column while the
  /// content is scrolled underneath them.
  final bool showScrollShadows;
  final Color shadowColor;
  final double shadowExtent;

  final double sortIconSize;

  /// Default text style for headers / content cells (merged over the theme's).
  final TextStyle? headerTextStyle;
  final TextStyle? textStyle;

  StickyTableStyle copyWith({
    Color? headerColor,
    Color? legendColor,
    Color? contentColor,
    Color? stripeColor,
    Color? selectedRowColor,
    Color? hoverRowColor,
    Color? gridLineColor,
    double? gridLineWidth,
    bool? showScrollShadows,
    Color? shadowColor,
    double? shadowExtent,
    double? sortIconSize,
    TextStyle? headerTextStyle,
    TextStyle? textStyle,
  }) {
    return StickyTableStyle(
      headerColor: headerColor ?? this.headerColor,
      legendColor: legendColor ?? this.legendColor,
      contentColor: contentColor ?? this.contentColor,
      stripeColor: stripeColor ?? this.stripeColor,
      selectedRowColor: selectedRowColor ?? this.selectedRowColor,
      hoverRowColor: hoverRowColor ?? this.hoverRowColor,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      gridLineWidth: gridLineWidth ?? this.gridLineWidth,
      showScrollShadows: showScrollShadows ?? this.showScrollShadows,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowExtent: shadowExtent ?? this.shadowExtent,
      sortIconSize: sortIconSize ?? this.sortIconSize,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  BoxDecoration? decoration(Color? color) {
    final line = gridLineColor;
    if (color == null && line == null) return null;
    final side = line == null
        ? BorderSide.none
        : BorderSide(color: line, width: gridLineWidth);
    return BoxDecoration(
      color: color,
      border: line == null ? null : Border(right: side, bottom: side),
    );
  }
}

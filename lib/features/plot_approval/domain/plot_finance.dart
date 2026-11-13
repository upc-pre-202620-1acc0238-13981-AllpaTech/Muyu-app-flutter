/// Amount helpers and the disbursement plan, ported from `PlotFinance.kt`.
abstract final class PlotFinance {
  /// Share of the total released at planting, irrigation and fertilization.
  /// Harvest receives whatever remains.
  static const double _milestoneShare = 0.2353;

  static double parseAmount(String raw) =>
      double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  /// Formats stored plot amounts (`25000` or `S/ 25 000`) like the Kotlin app.
  static String displayAmount(String raw) {
    final parsed = parseAmount(raw);
    if (parsed <= 0) return raw.trim().isEmpty ? 'S/ 0' : raw.trim();
    return formatAmount(parsed);
  }

  /// Formats a value like the Kotlin app: `S/ 8 500`.
  static String formatAmount(double value) {
    final digits = value.round().toString();
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(' ');
      grouped.write(digits[i]);
    }
    return 'S/ $grouped';
  }

  /// Planting, irrigation, fertilization and harvest amounts, in that order.
  static List<double> disbursement(double total) {
    final share = total * _milestoneShare;
    return [share, share, share, total - share * 3];
  }
}

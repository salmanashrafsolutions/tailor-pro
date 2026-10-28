/// Utility for parsing and formatting tailor fractions (¼, ½, ¾, ⅛, ⅜, ⅝, ⅞).
class FractionFormatter {
  static final Map<double, String> _fractionSymbols = {
    0.125: '⅛',
    0.25: '¼',
    0.375: '⅜',
    0.5: '½',
    0.625: '⅝',
    0.75: '¾',
    0.875: '⅞',
  };

  static const Map<String, double> _symbolValues = {
    '⅛': 0.125,
    '¼': 0.25,
    '⅜': 0.375,
    '½': 0.5,
    '⅝': 0.625,
    '¾': 0.75,
    '⅞': 0.875,
    '1/8': 0.125,
    '1/4': 0.25,
    '3/8': 0.375,
    '1/2': 0.5,
    '5/8': 0.625,
    '3/4': 0.75,
    '7/8': 0.875,
  };

  /// Converts a decimal number (e.g. 38.5) into tailor fraction format (e.g. "38½")
  static String format(double? value) {
    if (value == null) return '';
    final int wholePart = value.floor();
    final double remainder = double.parse((value - wholePart).toStringAsFixed(3));

    if (remainder == 0.0) {
      return wholePart.toString();
    }

    // Check exact fraction match with small epsilon
    for (final entry in _fractionSymbols.entries) {
      if ((remainder - entry.key).abs() < 0.01) {
        if (wholePart == 0) {
          return entry.value;
        }
        return '$wholePart${entry.value}';
      }
    }

    // Default clean decimal
    return value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  /// Parses a string representation (e.g. "38½", "38 1/2", "38.5") into a double
  static double? parse(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    String clean = input.trim();

    // Check for symbol at the end
    for (final entry in _symbolValues.entries) {
      if (clean.contains(entry.key)) {
        final parts = clean.split(entry.key);
        final wholeStr = parts[0].trim();
        final whole = wholeStr.isEmpty ? 0.0 : (double.tryParse(wholeStr) ?? 0.0);
        return whole + entry.value;
      }
    }

    // Direct decimal parse
    return double.tryParse(clean);
  }
}


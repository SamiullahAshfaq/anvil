/// Display-only formatting for weight. The domain/DB layers always hold integer
/// **Grams**; conversion to kg/ton happens only here at the UI boundary.
/// 1 kg = 1,000 g. 1 ton = 1,000,000 g.
extension GramsFormatting on int {
  /// e.g. `2500000` → `"2,500 kg"` (3 dp trimmed).
  String toKgString({int maxFractionDigits = 3, bool showUnit = true}) {
    final s = _fixedFromGrams(this, 1000, maxFractionDigits);
    return showUnit ? '$s kg' : s;
  }

  /// e.g. `2500000` → `"2.5 ton"`.
  String toTonString({int maxFractionDigits = 3, bool showUnit = true}) {
    final s = _fixedFromGrams(this, 1000000, maxFractionDigits);
    return showUnit ? '$s ton' : s;
  }
}

String _fixedFromGrams(int grams, int unitInGrams, int maxFractionDigits) {
  final negative = grams < 0;
  final abs = grams.abs();
  final whole = abs ~/ unitInGrams;
  final remainder = abs % unitInGrams;
  final sign = negative ? '-' : '';
  final wholeStr = _groupThousands(whole);
  if (remainder == 0 || maxFractionDigits == 0) return '$sign$wholeStr';

  // Build fractional digits without floating point.
  var frac = remainder.toString().padLeft(unitInGrams.toString().length - 1, '0');
  if (frac.length > maxFractionDigits) frac = frac.substring(0, maxFractionDigits);
  frac = frac.replaceFirst(RegExp(r'0+$'), '');
  if (frac.isEmpty) return '$sign$wholeStr';
  return '$sign$wholeStr.$frac';
}

String _groupThousands(int value) {
  final s = value.toString();
  if (s.length <= 3) return s;
  final buf = StringBuffer();
  final firstGroup = s.length % 3 == 0 ? 3 : s.length % 3;
  buf.write(s.substring(0, firstGroup));
  for (var i = firstGroup; i < s.length; i += 3) {
    buf.write(',');
    buf.write(s.substring(i, i + 3));
  }
  return buf.toString();
}

/// Parses user-typed weight in kg (e.g. "2.5", "1,000") into integer Grams.
int? kgStringToGrams(String input) {
  final cleaned = input.replaceAll(',', '').replaceAll('kg', '').trim();
  if (cleaned.isEmpty) return null;
  final negative = cleaned.startsWith('-');
  final body = negative ? cleaned.substring(1) : cleaned;
  final parts = body.split('.');
  if (parts.length > 2) return null;
  final kg = int.tryParse(parts[0].isEmpty ? '0' : parts[0]);
  if (kg == null) return null;
  var grams = 0;
  if (parts.length == 2) {
    final frac = parts[1].padRight(3, '0').substring(0, 3);
    grams = int.tryParse(frac) ?? -1;
    if (grams < 0) return null;
  }
  final total = kg * 1000 + grams;
  return negative ? -total : total;
}

import 'rounding.dart';

/// Display-only formatting for currency. The domain/DB layers always hold
/// integer **Paisa**; conversion to a Rupee string happens *only here*, at the
/// UI boundary (03_RULES.md §1.18). Never persist the formatted value.
extension PaisaFormatting on int {
  /// Rupees as an integer-exact `(whole, paise)` pair. 100 paisa = 1 rupee.
  ///
  /// Sign is carried on [rupees]; [paise] is always 0–99.
  (int rupees, int paise) get asRupeeParts {
    final negative = this < 0;
    final abs = this.abs();
    final r = abs ~/ 100;
    final p = abs % 100;
    return (negative ? -r : r, p);
  }

  /// e.g. `500050` → `"Rs 5,000.50"`. Grouped with the Pakistani/South-Asian
  /// lakh/crore convention off by default (plain thousands grouping) — kept
  /// simple and unambiguous for scannable mono figures.
  String toRupeeString({String symbol = 'Rs', bool showSymbol = true}) {
    final (rupees, paise) = asRupeeParts;
    final sign = (rupees < 0 || (rupees == 0 && this < 0)) ? '-' : '';
    final grouped = _groupThousands(rupees.abs());
    final paiseStr = paise.toString().padLeft(2, '0');
    final prefix = showSymbol ? '$symbol ' : '';
    return '$prefix$sign$grouped.$paiseStr';
  }
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

/// Parses a user-typed rupee amount (e.g. "5000.50", "5,000") into integer Paisa.
/// Returns null on invalid input rather than throwing — callers surface a calm
/// validation message.
int? rupeeStringToPaisa(String input) {
  final cleaned = input.replaceAll(',', '').replaceAll('Rs', '').trim();
  if (cleaned.isEmpty) return null;
  final negative = cleaned.startsWith('-');
  final body = negative ? cleaned.substring(1) : cleaned;
  final parts = body.split('.');
  if (parts.length > 2) return null;
  final rupeesStr = parts[0].isEmpty ? '0' : parts[0];
  final rupees = int.tryParse(rupeesStr);
  if (rupees == null) return null;
  var paise = 0;
  if (parts.length == 2) {
    var frac = parts[1];
    if (frac.length > 2) {
      // Round fractional paisa beyond 2 dp deterministically.
      final micro = int.tryParse(frac.padRight(3, '0').substring(0, 3));
      if (micro == null) return null;
      paise = divRound(micro, 10);
    } else {
      frac = frac.padRight(2, '0');
      paise = int.tryParse(frac) ?? -1;
      if (paise < 0) return null;
    }
  }
  final total = rupees * 100 + paise;
  return negative ? -total : total;
}

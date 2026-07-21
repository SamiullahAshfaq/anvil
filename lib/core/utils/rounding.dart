/// Integer-exact arithmetic helpers.
///
/// The entire financial core stores currency as integer **Paisa** and weight as
/// integer **Grams** — there is deliberately no `double`/`float` anywhere in the
/// domain layer (see 03_RULES.md §2.14). These helpers are the *only* sanctioned
/// place division happens, and they always round deterministically so results are
/// reproducible across devices and restores.
library;

/// Divides [numerator] by [denominator], rounding half **away from zero**.
///
/// Deterministic and sign-symmetric: `divRound(5, 2) == 3`, `divRound(-5, 2) == -3`.
/// Used wherever a Paisa amount must be derived from a ratio (e.g. COGS as a
/// proportional slice of a stock position's total cost basis).
int divRound(int numerator, int denominator) {
  if (denominator == 0) {
    throw ArgumentError('divRound: division by zero');
  }
  final negative = (numerator < 0) != (denominator < 0);
  final n = numerator.abs();
  final d = denominator.abs();
  final q = (n + d ~/ 2) ~/ d;
  return negative ? -q : q;
}

/// Money value of [weightGrams] at [ratePaisaPerKg], in Paisa, rounded to the
/// nearest whole Paisa (half away from zero).
///
/// Canonical unit choice: rates are stored as **Paisa per kilogram** (an integer —
/// Rs 55/kg → `5500`), weights as **Grams**. A per-gram rate would not be
/// integer-representable for common rates (Rs 55/kg = 5.5 paisa/g), which is why
/// per-kg is the stored rate unit. Line/stock money totals are always this
/// rounded Paisa value — never a persisted decimal.
int moneyForWeight({required int weightGrams, required int ratePaisaPerKg}) {
  return divRound(weightGrams * ratePaisaPerKg, 1000);
}

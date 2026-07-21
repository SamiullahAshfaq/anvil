import 'package:flutter_test/flutter_test.dart';
import 'package:anvil/core/utils/money.dart';
import 'package:anvil/core/utils/weight.dart';
import 'package:anvil/core/utils/rounding.dart';

void main() {
  group('divRound rounds half away from zero, sign-symmetric', () {
    test('positive', () => expect(divRound(5, 2), 3));
    test('negative', () => expect(divRound(-5, 2), -3));
    test('exact', () => expect(divRound(10, 2), 5));
    test('throws on zero denominator',
        () => expect(() => divRound(1, 0), throwsArgumentError));
  });

  group('moneyForWeight (Paisa per kg × grams)', () {
    test('500 g @ Rs 55/kg = Rs 27.50', () {
      expect(moneyForWeight(weightGrams: 500, ratePaisaPerKg: 5500), 2750);
    });
    test('rounds sub-paisa deterministically', () {
      // 333 g @ Rs 55/kg = 1831.5 paisa → 1832 (half away from zero).
      expect(moneyForWeight(weightGrams: 333, ratePaisaPerKg: 5500), 1832);
    });
  });

  group('rupee formatting/parsing round-trips', () {
    test('formats grouped with two paise', () {
      expect(500050.toRupeeString(), 'Rs 5,000.50');
      expect((-500050).toRupeeString(), 'Rs -5,000.50');
    });
    test('parses rupee strings to Paisa', () {
      expect(rupeeStringToPaisa('5,000.50'), 500050);
      expect(rupeeStringToPaisa('Rs 100'), 10000);
      expect(rupeeStringToPaisa('nonsense'), isNull);
    });
  });

  group('weight formatting/parsing', () {
    test('grams → kg and ton strings', () {
      expect(2500000.toKgString(), '2,500 kg');
      expect(2500000.toTonString(), '2.5 ton');
    });
    test('parses kg strings to grams', () {
      expect(kgStringToGrams('2.5'), 2500);
      expect(kgStringToGrams('1,000'), 1000000);
    });
  });
}

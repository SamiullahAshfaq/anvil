import '../utils/money.dart';
import '../utils/weight.dart';
import '../../domain/use_cases/use_case_result.dart';
import 'app_exception.dart';

/// The single place user-facing error copy is produced (03_RULES.md §4, §1.13):
/// calm and specific, never a stack trace, never ad-hoc strings in widgets.
String calmErrorCopy(Object error) {
  if (error is UnauthorizedException) {
    return 'You\'re in View-only mode — this change isn\'t allowed.';
  }
  if (error is ValidationException) return error.message;
  if (error is TransactionFailedException) return error.message;
  if (error is AppException) return error.message;
  return 'Something didn\'t work — nothing was changed. Please try again.';
}

/// Calm, specific copy for a soft warning surfaced before a write.
({String title, String body}) warningCopy(UseCaseWarning w) {
  switch (w) {
    case NegativeStockWarning():
      return (
        title: 'Stock will go negative',
        body:
            'This will put ${w.categoryName} stock at ${w.resultingQuantityGrams.toKgString()}. '
                'Selling ahead of stock is fine — continue?',
      );
    case OverdraftWarning():
      return (
        title: 'Cash pool will go negative',
        body:
            '${w.poolName} cash will show ${w.resultingBalancePaisa.toRupeeString()}. '
                'Did you forget to record a transfer into it?',
      );
  }
}

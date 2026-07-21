/// A soft warning surfaced by a use-case *before* committing. Warnings are not
/// exceptions and never block flow — the UI shows a calm confirmation and the
/// caller re-invokes the use-case with `confirmed: true` to proceed
/// (03_RULES.md §4, §1.6, §1.25).
sealed class UseCaseWarning {
  const UseCaseWarning();
}

/// A sale line would take a parent category's stock below zero.
class NegativeStockWarning extends UseCaseWarning {
  final String parentCategoryId;
  final String categoryName;
  final int resultingQuantityGrams;
  const NegativeStockWarning({
    required this.parentCategoryId,
    required this.categoryName,
    required this.resultingQuantityGrams,
  });
}

/// A withdrawal would take a cash pool below zero.
class OverdraftWarning extends UseCaseWarning {
  final String poolId;
  final String poolName;
  final int resultingBalancePaisa;
  const OverdraftWarning({
    required this.poolId,
    required this.poolName,
    required this.resultingBalancePaisa,
  });
}

/// The outcome of a use-case: either it committed ([Success]) or it stopped
/// before writing anything and needs the user to confirm one or more warnings
/// ([NeedsConfirmation]). Nothing is written in the NeedsConfirmation case.
sealed class UseCaseResult<T> {
  const UseCaseResult();
}

class Success<T> extends UseCaseResult<T> {
  final T value;
  const Success(this.value);
}

class NeedsConfirmation<T> extends UseCaseResult<T> {
  final List<UseCaseWarning> warnings;
  const NeedsConfirmation(this.warnings);
}

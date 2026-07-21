/// Pre-commit negative-balance check for any cash withdrawal. Returns a
/// `needsConfirmation`-style result rather than throwing — an overdraft is a
/// calm confirmation ("Record Transfer Now" / "Continue Anyway"), never a hard
/// block (03_RULES.md §1.25). The business must keep moving.
class OverdraftCheck {
  /// Pool balance before the withdrawal, Paisa.
  final int currentBalancePaisa;

  /// The withdrawal amount, Paisa.
  final int withdrawalPaisa;

  /// Balance the pool would show after the withdrawal (may be negative).
  final int resultingBalancePaisa;

  /// True when the withdrawal would take the pool below zero.
  bool get needsConfirmation => resultingBalancePaisa < 0;

  const OverdraftCheck({
    required this.currentBalancePaisa,
    required this.withdrawalPaisa,
    required this.resultingBalancePaisa,
  });
}

class CashOverdraftService {
  const CashOverdraftService();

  OverdraftCheck check({
    required int currentBalancePaisa,
    required int withdrawalPaisa,
  }) {
    if (withdrawalPaisa < 0) {
      throw ArgumentError('Withdrawal cannot be negative: $withdrawalPaisa');
    }
    return OverdraftCheck(
      currentBalancePaisa: currentBalancePaisa,
      withdrawalPaisa: withdrawalPaisa,
      resultingBalancePaisa: currentBalancePaisa - withdrawalPaisa,
    );
  }
}

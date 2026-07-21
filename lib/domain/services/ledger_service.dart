import '../entities/party_ledger.dart';

/// Derives a party's balance from its bills and payment allocations. Balances are
/// **never stored** — they are computed on read from the underlying ledger rows
/// (03_RULES.md §1.3). Reversed payments are excluded entirely, so reversing a
/// bounced payment automatically reopens the bills it had settled.
class LedgerService {
  const LedgerService();

  /// Computes receivable, payable, and unallocated advances for a party.
  ///
  /// - Receivable = Σ over **sale** bills of (billTotal − amount the buyer paid
  ///   toward that bill), floored at 0 per bill.
  /// - Payable = Σ over **purchase** bills of (billTotal − amount we paid toward
  ///   that bill), floored at 0 per bill.
  /// - Advances = payments not allocated to any bill, split by direction.
  ///
  /// Receivable and payable are returned separately and never netted.
  PartyBalance deriveBalance({
    required List<PartyBill> bills,
    required List<PartyPayment> payments,
  }) {
    final active = payments.where((p) => !p.reversed).toList(growable: false);

    // Sum allocations per bill, split by the paying direction.
    final receivedByBill = <String, int>{};
    final paidByBill = <String, int>{};
    var advanceReceived = 0;
    var advancePaid = 0;

    for (final p in active) {
      final target = p.direction == PaymentDirection.received
          ? receivedByBill
          : paidByBill;
      for (final a in p.allocations) {
        target[a.billId] = (target[a.billId] ?? 0) + a.amountPaisa;
      }
      if (p.direction == PaymentDirection.received) {
        advanceReceived += p.unallocatedPaisa;
      } else {
        advancePaid += p.unallocatedPaisa;
      }
    }

    var receivable = 0;
    var payable = 0;
    for (final bill in bills) {
      switch (bill.kind) {
        case PartyBillKind.sale:
          final outstanding = bill.totalPaisa - (receivedByBill[bill.id] ?? 0);
          if (outstanding > 0) receivable += outstanding;
        case PartyBillKind.purchase:
          final outstanding = bill.totalPaisa - (paidByBill[bill.id] ?? 0);
          if (outstanding > 0) payable += outstanding;
      }
    }

    return PartyBalance(
      receivablePaisa: receivable,
      payablePaisa: payable,
      advanceReceivedPaisa: advanceReceived,
      advancePaidPaisa: advancePaid,
    );
  }
}

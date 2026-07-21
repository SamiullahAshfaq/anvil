/// Pure-Dart projections of a party's bills and payments, used by
/// [LedgerService] to derive balances. These mirror the persisted rows but carry
/// no Drift/DB annotations — the domain layer is testable with plain fixtures.
library;

enum PartyBillKind { purchase, sale }

/// A bill involving a party. `expense` bills are not party-ledger events in the
/// receivable/payable sense and are excluded from this projection.
class PartyBill {
  final String id;
  final PartyBillKind kind;
  final int totalPaisa;

  const PartyBill({
    required this.id,
    required this.kind,
    required this.totalPaisa,
  });
}

enum PaymentDirection { received, paid }

/// A single allocation of a payment against a specific bill.
class PaymentAllocationView {
  final String billId;
  final int amountPaisa;

  const PaymentAllocationView({required this.billId, required this.amountPaisa});
}

/// A payment to/from a party, with its manual allocations. A reversed payment
/// (bounced cheque / failed transfer) is flagged, never deleted — [LedgerService]
/// excludes it entirely so the affected bills return to their prior open status.
class PartyPayment {
  final String id;
  final PaymentDirection direction;
  final int amountPaisa;
  final bool reversed;
  final List<PaymentAllocationView> allocations;

  const PartyPayment({
    required this.id,
    required this.direction,
    required this.amountPaisa,
    this.reversed = false,
    this.allocations = const [],
  });

  int get allocatedPaisa =>
      allocations.fold(0, (sum, a) => sum + a.amountPaisa);

  /// Money paid but not yet tied to any bill — an advance.
  int get unallocatedPaisa => amountPaisa - allocatedPaisa;
}

/// A party's derived financial position. Receivable and payable are held as two
/// **separate** numbers and never silently netted (01_PRD.md §4.1, worked
/// example) — a party can owe us on a standing debt while we owe them for an
/// in-progress purchase.
class PartyBalance {
  /// What the party owes us (unpaid portion of sale bills to them). >= 0.
  final int receivablePaisa;

  /// What we owe the party (unpaid portion of purchase bills from them). >= 0.
  final int payablePaisa;

  /// Money the party paid us not yet allocated to a sale bill (buyer advance).
  final int advanceReceivedPaisa;

  /// Money we paid the party not yet allocated to a purchase bill (our advance).
  final int advancePaidPaisa;

  const PartyBalance({
    required this.receivablePaisa,
    required this.payablePaisa,
    required this.advanceReceivedPaisa,
    required this.advancePaidPaisa,
  });

  @override
  bool operator ==(Object other) =>
      other is PartyBalance &&
      other.receivablePaisa == receivablePaisa &&
      other.payablePaisa == payablePaisa &&
      other.advanceReceivedPaisa == advanceReceivedPaisa &&
      other.advancePaidPaisa == advancePaidPaisa;

  @override
  int get hashCode => Object.hash(
      receivablePaisa, payablePaisa, advanceReceivedPaisa, advancePaidPaisa);

  @override
  String toString() =>
      'PartyBalance(recv=$receivablePaisa, pay=$payablePaisa, '
      'advRecv=$advanceReceivedPaisa, advPaid=$advancePaidPaisa)';
}

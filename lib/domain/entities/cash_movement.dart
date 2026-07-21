/// Pure-Dart projection of a cash movement, used by cash services. Mirrors the
/// persisted `CashMovement` row without DB annotations.
library;

enum CashDirection { moneyIn, moneyOut }

class CashMovementView {
  final String id;
  final CashDirection direction;
  final int amountPaisa;

  /// Ordering key. Sequence is a tiebreaker for movements on the same instant so
  /// FIFO consumption is deterministic (insertion order within a day).
  final DateTime date;
  final int sequence;

  /// For an inbound Godam transfer: id shared with its outbound Home/Bank half.
  final String? transferId;

  /// For an outbound spend: the bill/payment it funded, so a trace can name it.
  final String? relatedBillId;

  const CashMovementView({
    required this.id,
    required this.direction,
    required this.amountPaisa,
    required this.date,
    this.sequence = 0,
    this.transferId,
    this.relatedBillId,
  });
}

/// One transfer-in lot that funded (part of) a spend.
class FundingSource {
  final String transferMovementId;
  final String? transferId;
  final DateTime transferDate;
  final int amountConsumedPaisa;

  const FundingSource({
    required this.transferMovementId,
    required this.transferId,
    required this.transferDate,
    required this.amountConsumedPaisa,
  });
}

/// The FIFO funding trace of a single outbound spend: which transfer(s) paid for
/// it, oldest-first. [unfundedPaisa] > 0 means the spend drew the pool negative
/// (an overdraft that the owner chose to continue through) — surfaced, never hidden.
class SpendTrace {
  final String spendMovementId;
  final int spendAmountPaisa;
  final List<FundingSource> sources;
  final int unfundedPaisa;

  const SpendTrace({
    required this.spendMovementId,
    required this.spendAmountPaisa,
    required this.sources,
    required this.unfundedPaisa,
  });
}

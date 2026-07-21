import '../entities/cash_movement.dart';

/// Computes Godam spend traceability **dynamically at read time** by walking the
/// pool's `CashMovement` rows in chronological order and consuming inbound
/// transfers oldest-first (03_RULES.md §1.21). There is deliberately no stored
/// allocation table — a read-time calculation over the movements can never drift
/// out of sync with them.
class CashTraceService {
  const CashTraceService();

  int _order(CashMovementView a, CashMovementView b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    return a.sequence.compareTo(b.sequence);
  }

  /// Traces every outbound spend in [godamMovements] to the inbound transfer(s)
  /// that funded it, FIFO. Returns one [SpendTrace] per outbound movement, in
  /// chronological order.
  List<SpendTrace> traceAllSpends(List<CashMovementView> godamMovements) {
    final sorted = [...godamMovements]..sort(_order);

    // Queue of inbound lots with remaining balance, oldest first.
    final lots = <_Lot>[];
    final traces = <SpendTrace>[];

    for (final m in sorted) {
      if (m.direction == CashDirection.moneyIn) {
        lots.add(_Lot(m));
        continue;
      }
      // Outbound spend: consume from the front of the queue.
      var remaining = m.amountPaisa;
      final sources = <FundingSource>[];
      for (final lot in lots) {
        if (remaining <= 0) break;
        if (lot.remaining <= 0) continue;
        final take = remaining < lot.remaining ? remaining : lot.remaining;
        lot.remaining -= take;
        remaining -= take;
        sources.add(FundingSource(
          transferMovementId: lot.movement.id,
          transferId: lot.movement.transferId,
          transferDate: lot.movement.date,
          amountConsumedPaisa: take,
        ));
      }
      traces.add(SpendTrace(
        spendMovementId: m.id,
        spendAmountPaisa: m.amountPaisa,
        sources: sources,
        unfundedPaisa: remaining > 0 ? remaining : 0,
      ));
    }
    return traces;
  }

  /// Convenience: the trace for one specific spend id (null if not found).
  SpendTrace? traceSpend(
    List<CashMovementView> godamMovements,
    String spendMovementId,
  ) {
    for (final t in traceAllSpends(godamMovements)) {
      if (t.spendMovementId == spendMovementId) return t;
    }
    return null;
  }

  /// Running balance of a pool = Σ in − Σ out. Always derived, never stored
  /// (03_RULES.md §1.3).
  int poolBalance(List<CashMovementView> movements) {
    var balance = 0;
    for (final m in movements) {
      balance += m.direction == CashDirection.moneyIn
          ? m.amountPaisa
          : -m.amountPaisa;
    }
    return balance;
  }
}

class _Lot {
  final CashMovementView movement;
  int remaining;
  _Lot(this.movement) : remaining = movement.amountPaisa;
}

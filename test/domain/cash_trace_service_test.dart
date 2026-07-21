import 'package:flutter_test/flutter_test.dart';
import 'package:anvil/domain/entities/cash_movement.dart';
import 'package:anvil/domain/services/cash_trace_service.dart';

void main() {
  const svc = CashTraceService();

  CashMovementView tin(String id, int amt, int day, {String? transferId}) =>
      CashMovementView(
        id: id,
        direction: CashDirection.moneyIn,
        amountPaisa: amt,
        date: DateTime(2026, 7, day),
        transferId: transferId,
      );
  CashMovementView out(String id, int amt, int day, {String? bill}) =>
      CashMovementView(
        id: id,
        direction: CashDirection.moneyOut,
        amountPaisa: amt,
        date: DateTime(2026, 7, day),
        relatedBillId: bill,
      );

  test('a Godam spend is traced to two separate transfers-in, FIFO', () {
    // T1 Rs 10,000 (day 1), T2 Rs 15,000 (day 2), spend Rs 20,000 (day 3).
    final movements = [
      tin('T1', 1000000, 1, transferId: 'X1'),
      tin('T2', 1500000, 2, transferId: 'X2'),
      out('S1', 2000000, 3, bill: 'BILL1'),
    ];
    final trace = svc.traceSpend(movements, 'S1')!;
    expect(trace.sources.length, 2);
    expect(trace.sources[0].transferMovementId, 'T1');
    expect(trace.sources[0].amountConsumedPaisa, 1000000); // all of T1
    expect(trace.sources[1].transferMovementId, 'T2');
    expect(trace.sources[1].amountConsumedPaisa, 1000000); // Rs 10,000 of T2
    expect(trace.unfundedPaisa, 0);
    expect(svc.poolBalance(movements), 500000); // Rs 5,000 left
  });

  test('a spend exceeding all transfers reports the unfunded (overdraft) part', () {
    final movements = [
      tin('T1', 1000000, 1),
      out('S1', 1500000, 2),
    ];
    final trace = svc.traceSpend(movements, 'S1')!;
    expect(trace.sources.single.amountConsumedPaisa, 1000000);
    expect(trace.unfundedPaisa, 500000, reason: 'Rs 5,000 drew the pool negative');
    expect(svc.poolBalance(movements), -500000);
  });

  test('multiple sequential spends consume lots oldest-first', () {
    final movements = [
      tin('T1', 2000000, 1),
      out('S1', 500000, 2),
      out('S2', 800000, 3),
      out('S3', 1000000, 4),
    ];
    final traces = svc.traceAllSpends(movements);
    expect(traces.length, 3);
    // S3 gets the last Rs 7,000 of T1, then Rs 3,000 unfunded.
    final s3 = traces.firstWhere((t) => t.spendMovementId == 'S3');
    expect(s3.sources.single.amountConsumedPaisa, 700000);
    expect(s3.unfundedPaisa, 300000);
  });
}

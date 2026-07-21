import 'package:flutter_test/flutter_test.dart';
import 'package:anvil/domain/entities/party_ledger.dart';
import 'package:anvil/domain/services/ledger_service.dart';

void main() {
  const svc = LedgerService();

  test('receivable and payable are shown separately, never netted '
      '(01_PRD.md §4.1 worked example)', () {
    // Party owes us Rs 5,00,000 on a standing sale, AND we owe them Rs 1,00,000
    // for an in-progress purchase we fully paid (25k + 75k). The 5,00,000 must
    // NOT change from the stock transaction; the two figures stay separate.
    final bills = [
      const PartyBill(id: 'S1', kind: PartyBillKind.sale, totalPaisa: 50000000),
      const PartyBill(
          id: 'P1', kind: PartyBillKind.purchase, totalPaisa: 10000000),
    ];
    final payments = [
      const PartyPayment(
        id: 'PAY-adv',
        direction: PaymentDirection.paid,
        amountPaisa: 2500000, // Rs 25,000 advance
        allocations: [PaymentAllocationView(billId: 'P1', amountPaisa: 2500000)],
      ),
      const PartyPayment(
        id: 'PAY-bal',
        direction: PaymentDirection.paid,
        amountPaisa: 7500000, // Rs 75,000 balance
        allocations: [PaymentAllocationView(billId: 'P1', amountPaisa: 7500000)],
      ),
    ];

    final b = svc.deriveBalance(bills: bills, payments: payments);
    expect(b.receivablePaisa, 50000000, reason: 'standing debt untouched');
    expect(b.payablePaisa, 0, reason: 'purchase fully paid');
    expect(b.advancePaidPaisa, 0);
    // Never netted into a single Rs 4,00,000 figure.
  });

  test('one payment split across two sale bills (partial each)', () {
    final bills = [
      const PartyBill(id: 'S1', kind: PartyBillKind.sale, totalPaisa: 30000),
      const PartyBill(id: 'S2', kind: PartyBillKind.sale, totalPaisa: 20000),
    ];
    final payments = [
      const PartyPayment(
        id: 'PAY1',
        direction: PaymentDirection.received,
        amountPaisa: 40000,
        allocations: [
          PaymentAllocationView(billId: 'S1', amountPaisa: 25000),
          PaymentAllocationView(billId: 'S2', amountPaisa: 15000),
        ],
      ),
    ];
    final b = svc.deriveBalance(bills: bills, payments: payments);
    // (30000-25000) + (20000-15000) = 10000 still receivable.
    expect(b.receivablePaisa, 10000);
    expect(b.advanceReceivedPaisa, 0);
  });

  test('unallocated received payment surfaces as a buyer advance', () {
    final bills = [
      const PartyBill(id: 'S1', kind: PartyBillKind.sale, totalPaisa: 30000),
    ];
    final payments = [
      const PartyPayment(
        id: 'PAY1',
        direction: PaymentDirection.received,
        amountPaisa: 50000, // paid more than the one open bill
        allocations: [PaymentAllocationView(billId: 'S1', amountPaisa: 30000)],
      ),
    ];
    final b = svc.deriveBalance(bills: bills, payments: payments);
    expect(b.receivablePaisa, 0);
    expect(b.advanceReceivedPaisa, 20000, reason: 'Rs 20,000 advance on account');
  });

  test('reversing a payment reopens the bill and excludes it entirely', () {
    // A received payment that settled S1 later bounces (reversed = true).
    final bills = [
      const PartyBill(id: 'S1', kind: PartyBillKind.sale, totalPaisa: 50000),
    ];
    final reversed = [
      const PartyPayment(
        id: 'PAY1',
        direction: PaymentDirection.received,
        amountPaisa: 50000,
        reversed: true,
        allocations: [PaymentAllocationView(billId: 'S1', amountPaisa: 50000)],
      ),
    ];
    final b = svc.deriveBalance(bills: bills, payments: reversed);
    expect(b.receivablePaisa, 50000,
        reason: 'bill returns to fully-open when its payment is reversed');
    expect(b.advanceReceivedPaisa, 0,
        reason: 'reversed payment contributes nothing, incl. no phantom advance');
  });
}

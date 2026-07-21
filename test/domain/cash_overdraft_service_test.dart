import 'package:flutter_test/flutter_test.dart';
import 'package:anvil/domain/services/cash_overdraft_service.dart';

void main() {
  const svc = CashOverdraftService();

  test('a withdrawal below the balance does not need confirmation', () {
    final c = svc.check(currentBalancePaisa: 3000000, withdrawalPaisa: 2000000);
    expect(c.resultingBalancePaisa, 1000000);
    expect(c.needsConfirmation, isFalse);
  });

  test('a withdrawal that would go negative surfaces a calm confirmation', () {
    // Godam has Rs 10,000, an Rs 25,000 expense is entered.
    final c = svc.check(currentBalancePaisa: 1000000, withdrawalPaisa: 2500000);
    expect(c.resultingBalancePaisa, -1500000, reason: 'shows the −Rs 15,000');
    expect(c.needsConfirmation, isTrue, reason: 'warn, never hard-block');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anvil/app/providers.dart';
import 'package:anvil/core/theme/app_theme.dart';
import 'package:anvil/core/utils/ids.dart';
import 'package:anvil/data/local/database.dart';
import 'package:anvil/data/local/read_queries.dart';
import 'package:anvil/data/local/tables.dart';
import 'package:anvil/presentation/bills/bills_screen.dart';
import 'package:anvil/presentation/bills/new_bill_screen.dart';
import 'package:anvil/security/access_mode.dart';

import '../sqlite_loader.dart';

/// Critical-flow widget tests (04_PHASES.md §1.15): the New Bill UI drives the
/// real record-purchase use-case (stock + bill + derived payable, one atomic
/// transaction), and View-only mode hides the mutating action.
void main() {
  setUpAll(overrideSqliteForTests);

  testWidgets('New Bill records a purchase end-to-end and shows the receipt',
      (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db.customStatement('SELECT 1;');

    final supplier = newId();
    await db.into(db.parties).insert(PartiesCompanion.insert(
        id: supplier,
        name: 'Ali Traders',
        type: PartyTypeDb.supplier,
        createdAt: DateTime.now()));
    final scrap = (await (db.select(db.stockCategories)
              ..where((t) => t.name.equals('Scrap')))
            .getSingle())
        .id;

    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: NewBillScreen(
            initialType: BillTypeDb.purchase, initialPartyId: supplier),
      ),
    ));
    await tester.pumpAndSettle();

    // Field 0 is the bill-level rate (per-bill is the default mode). Rs 40/kg.
    await tester.enterText(find.byType(TextField).at(0), '40');

    // Pick the Scrap category for the single line.
    await tester.tap(find.text('Choose category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scrap').last);
    await tester.pumpAndSettle();

    // Field 2 is the line weight (0 = rate, 1 = sub-category tag, 2 = weight).
    await tester.enterText(find.byType(TextField).at(2), '100');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Save bill'), 400,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save bill'));
    await tester.pumpAndSettle();

    expect(find.text('Saved. Everything updated.'), findsOneWidget);

    final cat =
        await (db.select(db.stockCategories)..where((t) => t.id.equals(scrap)))
            .getSingle();
    expect(cat.quantityGrams, 100000);
    expect(cat.totalCostBasisPaisa, 400000);
    final bal = await db.partyBalance(supplier);
    expect(bal.payablePaisa, 400000);
  });

  testWidgets('View-only mode hides the New bill action on the Bills list',
      (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db.customStatement('SELECT 1;');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        accessModeProvider.overrideWith((ref) => AccessMode.view),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const BillsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('New bill'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:anvil/data/local/connection.dart';

import '../sqlite_loader.dart';

/// Verifies the pre-migration vaulting mechanism at the file level — the safety
/// net for a live business's only copy of its ledger (02_ARCHITECTURE.md §7).
void main() {
  late Directory tmp;

  setUpAll(overrideSqliteForTests);
  setUp(() => tmp = Directory.systemTemp.createTempSync('anvil_vault_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('createVaultCopy makes a byte-identical copy alongside the db', () {
    final db = File('${tmp.path}/db.sqlite')..writeAsStringSync('LEDGER-V1');
    final vault = DbVault.createVaultCopy(db);
    expect(vault.existsSync(), isTrue);
    expect(vault.readAsStringSync(), 'LEDGER-V1');
    expect(vault.path, contains('vault_pre_upgrade'));
  });

  test('restoreFromVault recovers the pre-migration data after corruption', () {
    final db = File('${tmp.path}/db.sqlite')..writeAsStringSync('GOOD-DATA');
    final vault = DbVault.createVaultCopy(db);

    // Simulate a half-migrated / corrupted db.
    db.writeAsStringSync('CORRUPTED-HALF-MIGRATED');
    DbVault.restoreFromVault(vault, db);

    expect(db.readAsStringSync(), 'GOOD-DATA',
        reason: 'business data restored intact, no partial-schema loss');
  });

  test('pruneVaults keeps only the most recent N vaults', () {
    final db = File('${tmp.path}/db.sqlite')..writeAsStringSync('X');
    for (var i = 0; i < 5; i++) {
      DbVault.createVaultCopy(db, now: DateTime(2026, 7, 21, 10, i));
    }
    DbVault.pruneVaults(db, keep: 3);
    final vaults = tmp
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('vault_pre_upgrade'))
        .toList();
    expect(vaults.length, 3);
  });
}

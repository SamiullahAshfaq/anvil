import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

/// Pre-migration vaulting (02_ARCHITECTURE.md §7). Because the local SQLite file
/// is the **primary** source of truth (Supabase is backup-only), a failed schema
/// migration is a total-data-loss risk. Before any `onUpgrade` runs, the current
/// database file is copied to a timestamped vault; on migration failure the app
/// restores from the vault rather than proceeding on a half-migrated schema.
///
/// These are deliberately plain file operations so the safety behaviour is unit
/// testable without forcing a real Drift migration.
class DbVault {
  const DbVault._();

  /// Reads `PRAGMA user_version` from an existing SQLite file without opening it
  /// through Drift. Returns null if the file doesn't exist or can't be read.
  static int? readSchemaVersion(File dbFile) {
    if (!dbFile.existsSync()) return null;
    Database? db;
    try {
      db = sqlite3.open(dbFile.path, mode: OpenMode.readOnly);
      final row = db.select('PRAGMA user_version;').first;
      return row.values.first as int;
    } catch (_) {
      return null;
    } finally {
      // ignore: deprecated_member_use — sqlite3's Database uses dispose(); the
      // deprecation hint matches a different (drift) Database type.
      db?.dispose();
    }
  }

  /// Copies [dbFile] to a timestamped vault file next to it, returning the vault.
  static File createVaultCopy(File dbFile, {DateTime? now}) {
    final ts = (now ?? DateTime.now())
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final version = readSchemaVersion(dbFile) ?? 0;
    final dir = dbFile.parent.path;
    final base = p.basenameWithoutExtension(dbFile.path);
    final vault = File(p.join(dir, '${base}_vault_pre_upgrade_v${version}_$ts.sqlite'));
    dbFile.copySync(vault.path);
    return vault;
  }

  /// Restores [dbFile] from [vault] (used on a detected migration failure).
  static void restoreFromVault(File vault, File dbFile) {
    if (!vault.existsSync()) {
      throw StateError('Vault file missing: ${vault.path}');
    }
    vault.copySync(dbFile.path);
  }

  /// Keeps the most recent [keep] vaults for [dbFile], deleting older ones.
  /// Storage is cheap relative to a live business's ledger, so we retain a few.
  static void pruneVaults(File dbFile, {int keep = 3}) {
    final base = p.basenameWithoutExtension(dbFile.path);
    final marker = '${base}_vault_pre_upgrade_';
    final vaults = dbFile.parent
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith(marker))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path)); // newest first (ISO ts sorts)
    for (final old in vaults.skip(keep)) {
      old.deleteSync();
    }
  }
}

/// Opens the app database backed by [file], vaulting first if a schema upgrade is
/// pending, and restoring automatically if the migration throws.
Future<AppDatabase> openAppDatabase(File file, {int keepVaults = 3}) async {
  File? vault;
  final existingVersion = DbVault.readSchemaVersion(file);

  // We can't know the target schemaVersion without an instance; construct one to
  // read it, then decide. (schemaVersion is a cheap constant getter.)
  final probe = AppDatabase(NativeDatabase(file));
  final target = probe.schemaVersion;

  if (existingVersion != null && existingVersion < target) {
    vault = DbVault.createVaultCopy(file);
    DbVault.pruneVaults(file, keep: keepVaults);
  }

  try {
    // Force the migration to run now so any failure surfaces here.
    await probe.customStatement('SELECT 1;');
    return probe;
  } catch (e) {
    await probe.close();
    if (vault != null) {
      DbVault.restoreFromVault(vault, file);
    }
    rethrow;
  }
}

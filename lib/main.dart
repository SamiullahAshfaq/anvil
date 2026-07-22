import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/local/connection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local SQLite is the single source of truth. openAppDatabase vaults before any
  // pending migration and restores on failure (02_ARCHITECTURE.md §7).
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'godam_ledger.sqlite'));
  final db = await openAppDatabase(file);

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const GodamLedgerApp(),
    ),
  );
}

import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

/// Host test VMs don't ship the unversioned `libsqlite3.so`; point the loader at
/// the versioned system library so Drift's NativeDatabase (and our DbVault
/// sqlite3 reads) work under `flutter test`. On-device this is provided by
/// `sqlite3_flutter_libs` and never runs.
var _done = false;
void overrideSqliteForTests() {
  if (_done) return;
  _done = true;
  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
  }
}

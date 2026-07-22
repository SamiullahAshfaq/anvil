import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'access_mode.dart';

/// Stores the business name and gates the app behind a 4-digit Admin PIN plus an
/// optional 4-digit View PIN (01_PRD.md §4.8 — deliberately minimal, no RBAC).
///
/// Abstracted so widget/unit tests inject an in-memory fake instead of the real
/// platform keystore.
abstract class PinService {
  Future<bool> isSetupComplete();
  Future<String?> businessName();
  Future<void> completeSetup({
    required String businessName,
    required String adminPin,
    String? viewPin,
  });

  /// Returns the [AccessMode] a PIN unlocks, or null if it matches neither.
  Future<AccessMode?> verify(String pin);
}

/// A small deterministic salted hash so the raw PIN is not persisted verbatim.
/// The PIN space is only 4 digits by design, and the value already sits inside
/// the OS-encrypted keystore — a strong KDF here would be theatre; this just
/// avoids storing the digits in the clear. (Deterministic across restarts, unlike
/// Dart's per-isolate `String.hashCode`.)
String hashPin(String pin) {
  const salt = 'godam-ledger-v1';
  var hash = 0xcbf29ce484222325; // FNV-1a 64-bit offset basis
  const prime = 0x100000001b3;
  for (final code in '$salt:$pin'.codeUnits) {
    hash = (hash ^ code) & 0xFFFFFFFFFFFFFFFF;
    hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toRadixString(16);
}

class SecurePinService implements PinService {
  final FlutterSecureStorage _storage;
  SecurePinService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _kSetup = 'setup_complete';
  static const _kName = 'business_name';
  static const _kAdmin = 'admin_pin_hash';
  static const _kView = 'view_pin_hash';

  @override
  Future<bool> isSetupComplete() async =>
      (await _storage.read(key: _kSetup)) == 'true';

  @override
  Future<String?> businessName() => _storage.read(key: _kName);

  @override
  Future<void> completeSetup({
    required String businessName,
    required String adminPin,
    String? viewPin,
  }) async {
    await _storage.write(key: _kName, value: businessName);
    await _storage.write(key: _kAdmin, value: hashPin(adminPin));
    if (viewPin != null && viewPin.isNotEmpty) {
      await _storage.write(key: _kView, value: hashPin(viewPin));
    } else {
      await _storage.delete(key: _kView);
    }
    await _storage.write(key: _kSetup, value: 'true');
  }

  @override
  Future<AccessMode?> verify(String pin) async {
    final h = hashPin(pin);
    if (h == await _storage.read(key: _kAdmin)) return AccessMode.admin;
    if (h == await _storage.read(key: _kView)) return AccessMode.view;
    return null;
  }
}

/// In-memory implementation for tests (no platform channel).
class InMemoryPinService implements PinService {
  String? _name;
  String? _adminHash;
  String? _viewHash;
  bool _setup;

  InMemoryPinService({bool alreadySetUp = false}) : _setup = alreadySetUp;

  @override
  Future<bool> isSetupComplete() async => _setup;

  @override
  Future<String?> businessName() async => _name;

  @override
  Future<void> completeSetup({
    required String businessName,
    required String adminPin,
    String? viewPin,
  }) async {
    _name = businessName;
    _adminHash = hashPin(adminPin);
    _viewHash =
        (viewPin != null && viewPin.isNotEmpty) ? hashPin(viewPin) : null;
    _setup = true;
  }

  @override
  Future<AccessMode?> verify(String pin) async {
    final h = hashPin(pin);
    if (h == _adminHash) return AccessMode.admin;
    if (h == _viewHash) return AccessMode.view;
    return null;
  }
}

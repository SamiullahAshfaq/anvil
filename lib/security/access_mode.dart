import '../core/errors/app_exception.dart';

/// Admin (full control) vs View-only. A single 4-digit Admin PIN + optional
/// 4-digit View PIN gate the app — deliberately minimal, no RBAC (01_PRD.md §4.8).
enum AccessMode { admin, view }

/// Holds the current access mode and enforces it. The **real** security boundary
/// is [ensureCanMutate], called at the top of every mutating use-case — hiding
/// UI buttons is advisory only (03_RULES.md §1.22).
class AccessController {
  AccessMode mode;
  AccessController([this.mode = AccessMode.admin]);

  bool get isViewOnly => mode == AccessMode.view;

  /// Throws [UnauthorizedException] if a write is attempted in View-only mode.
  void ensureCanMutate() {
    if (mode == AccessMode.view) {
      throw const UnauthorizedException();
    }
  }
}

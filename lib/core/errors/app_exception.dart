/// Single typed exception hierarchy for the domain layer (03_RULES.md §4).
/// The UI catches these and maps them to calm, specific copy in one place —
/// never constructing user-facing error text ad hoc in a widget.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

/// A mutating operation was attempted while in View-only mode. This is the real
/// security boundary — enforced in the use-case layer, not just by hiding
/// buttons (03_RULES.md §1.22).
class UnauthorizedException extends AppException {
  const UnauthorizedException(
      [super.message = 'This action is not allowed in View-only mode.']);
}

/// A use-case transaction failed and was rolled back; nothing was changed.
class TransactionFailedException extends AppException {
  final Object? cause;
  const TransactionFailedException(
      [super.message = 'Something didn\'t save — nothing was changed, try again.',
      this.cause]);

  // Includes the cause for local logs only; user-facing copy uses [message].
  @override
  String toString() =>
      'TransactionFailedException: $message${cause == null ? '' : ' (cause: $cause)'}';
}

/// Input failed validation before any write was attempted.
class ValidationException extends AppException {
  const ValidationException(super.message);
}

import 'package:flutter/material.dart';

import '../../domain/use_cases/use_case_result.dart';
import 'calm_sheet.dart';

/// Runs a use-case, handling the [NeedsConfirmation] soft-warning round-trip and
/// calm error surfacing in one place, so every write screen behaves consistently
/// (03_RULES.md §4). Returns the [Success] value, or null if the user cancelled a
/// warning or an error occurred (already shown).
///
/// [action] must forward `confirmed` to the use-case, e.g.
/// `({confirmed = false}) => useCase.call(input, confirmed: confirmed)`.
Future<T?> runWithConfirm<T>(
  BuildContext context, {
  required Future<UseCaseResult<T>> Function({bool confirmed}) action,
}) async {
  try {
    var result = await action(confirmed: false);
    if (result is NeedsConfirmation<T>) {
      if (!context.mounted) return null;
      final proceed = await showWarningsSheet(context, result.warnings);
      if (!proceed) return null;
      result = await action(confirmed: true);
    }
    if (result is Success<T>) return result.value;
    return null;
  } catch (e) {
    if (context.mounted) showCalmError(context, e);
    return null;
  }
}

/// Bool-returning variant for use-cases whose success value is `void` (delete,
/// restore, edit). Returns true only if the operation committed.
Future<bool> confirmAndRun(
  BuildContext context, {
  required Future<UseCaseResult<void>> Function({bool confirmed}) action,
}) async {
  try {
    var result = await action(confirmed: false);
    if (result is NeedsConfirmation<void>) {
      if (!context.mounted) return false;
      final proceed = await showWarningsSheet(context, result.warnings);
      if (!proceed) return false;
      result = await action(confirmed: true);
    }
    return result is Success<void>;
  } catch (e) {
    if (context.mounted) showCalmError(context, e);
    return false;
  }
}

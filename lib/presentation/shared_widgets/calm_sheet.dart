import 'package:flutter/material.dart';

import '../../core/errors/error_copy.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/use_cases/use_case_result.dart';
import 'pill_button.dart';

/// Calm bottom sheets replace native alert dialogs everywhere (03_RULES.md §2.8):
/// no harsh red modals, no shake, just a muted sheet with clear choices.

Future<bool> showCalmConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _SheetShell(
      title: title,
      message: message,
      actions: [
        Expanded(
          child: PillButton(cancelLabel,
              primary: false, onPressed: () => Navigator.of(ctx).pop(false)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PillButton(confirmLabel,
              danger: danger, onPressed: () => Navigator.of(ctx).pop(true)),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Shows the soft warnings a use-case returned (negative stock / overdraft) with
/// a calm Continue / Cancel choice. Returns true if the user chose to proceed.
Future<bool> showWarningsSheet(
    BuildContext context, List<UseCaseWarning> warnings) async {
  final copies = warnings.map(warningCopy).toList();
  final title = copies.length == 1 ? copies.first.title : 'Please confirm';
  final message = copies.map((c) => c.body).join('\n\n');
  return showCalmConfirm(
    context,
    title: title,
    message: message,
    confirmLabel: 'Continue',
    cancelLabel: 'Cancel',
  );
}

class _SheetShell extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;
  const _SheetShell(
      {required this.title, required this.message, required this.actions});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.hairline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Text(message,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.4)),
              const SizedBox(height: 22),
              Row(children: actions),
            ],
          ),
        ),
      ),
    );
  }
}

/// A calm inline error toast (never a red native SnackBar with an icon-alarm).
void showCalmError(BuildContext context, Object error) {
  final c = context.c;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.surfaceStrong,
      content: Text(calmErrorCopy(error), style: TextStyle(color: c.ink)),
    ));
}

/// A calm success confirmation toast.
void showCalmInfo(BuildContext context, String message) {
  final c = context.c;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.surfaceStrong,
      content: Text(message, style: TextStyle(color: c.ink)),
    ));
}

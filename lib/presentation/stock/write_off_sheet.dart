import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/weight.dart';
import '../../domain/services/stock_costing_service.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import '../shared_widgets/use_case_runner.dart';

/// Stock Write-Off / Wastage entry (01_PRD.md §4.3, 03_RULES.md §1.23). Two
/// explicit modes: absorb the loss into remaining stock's cost (avg/kg rises), or
/// log it as a Wastage expense on the P&L (avg untouched).
Future<bool> showWriteOffSheet(
    BuildContext context, WidgetRef ref, String categoryId, String categoryName) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _WriteOffSheet(categoryId: categoryId, categoryName: categoryName),
  );
  return result ?? false;
}

class _WriteOffSheet extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;
  const _WriteOffSheet({required this.categoryId, required this.categoryName});

  @override
  ConsumerState<_WriteOffSheet> createState() => _WriteOffSheetState();
}

class _WriteOffSheetState extends ConsumerState<_WriteOffSheet> {
  final _weight = TextEditingController();
  final _note = TextEditingController();
  WriteOffMode _mode = WriteOffMode.absorbIntoRemaining;
  bool _busy = false;

  @override
  void dispose() {
    _weight.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final grams = kgStringToGrams(_weight.text);
    if (grams == null || grams <= 0) {
      showCalmError(context, Exception('Enter a weight to write off.'));
      return;
    }
    setState(() => _busy = true);
    final ok = await confirmAndRun(context,
        action: ({confirmed = false}) => ref.read(writeOffStockProvider).call(
              parentCategoryId: widget.categoryId,
              weightGrams: grams,
              mode: _mode,
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            ));
    if (!mounted) return;
    if (ok) {
      bumpLedger(ref);
      Navigator.of(context).pop(true);
    } else {
      setState(() => _busy = false);
    }
  }

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.hairline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Write off ${widget.categoryName}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text('Reduce physical stock without a sale.',
                  style: TextStyle(color: c.muted)),
              const SizedBox(height: 18),
              AppTextField(
                  controller: _weight,
                  label: 'WEIGHT TO REMOVE (KG)',
                  numeric: true,
                  autofocus: true),
              const SizedBox(height: 16),
              Text('HOW TO ACCOUNT FOR IT',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              _ModeOption(
                selected: _mode == WriteOffMode.absorbIntoRemaining,
                title: 'Absorb into remaining stock',
                subtitle:
                    'Cost stays, spread over less weight — avg cost per kg rises.',
                onTap: () => setState(
                    () => _mode = WriteOffMode.absorbIntoRemaining),
              ),
              const SizedBox(height: 8),
              _ModeOption(
                selected: _mode == WriteOffMode.expenseWastage,
                title: 'Log as Wastage expense',
                subtitle:
                    'Value drops off as a P&L cost; avg cost per kg unchanged.',
                onTap: () =>
                    setState(() => _mode = WriteOffMode.expenseWastage),
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _note, label: 'NOTE (OPTIONAL)'),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: PillButton('Cancel',
                        primary: false,
                        onPressed: () => Navigator.of(context).pop(false)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PillButton('Write off',
                        busy: _busy, onPressed: _busy ? null : _save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ModeOption(
      {required this.selected,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.secondary),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? c.primary.withValues(alpha: 0.08) : c.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.secondary),
          border: Border.all(color: selected ? c.primary : c.hairline),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20, color: selected ? c.primary : c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: c.ink, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

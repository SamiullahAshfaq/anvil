import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A labelled text field matching the calm, hairline design language.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool numeric;
  final bool mono;
  final String? prefix;
  final int? maxLength;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.numeric = false,
    this.mono = false,
    this.prefix,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,
          maxLength: maxLength,
          keyboardType: keyboardType ??
              (numeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text),
          inputFormatters: numeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
              : null,
          style: (mono || numeric)
              ? monoStyle(size: 16, color: c.ink)
              : TextStyle(color: c.ink, fontSize: 16),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            prefixText: prefix,
            prefixStyle: monoStyle(size: 16, color: c.muted),
            filled: true,
            fillColor: c.surfaceSoft,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.secondary),
              borderSide: BorderSide(color: c.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.secondary),
              borderSide: BorderSide(color: c.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// A pill-based segmented control. [values] must be non-empty; [selected] is one
/// of them. Used for the bill type switch, rate-mode toggle, and pool picker.
class SegmentedPills<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;
  const SegmentedPills({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceStrong,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: v == selected ? c.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: v == selected
                        ? Border.all(color: c.hairline)
                        : null,
                  ),
                  child: Text(
                    labelOf(v),
                    style: TextStyle(
                      color: v == selected ? c.ink : c.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

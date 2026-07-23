import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/use_cases/use_case_result.dart';

typedef PickedCategory = ({String id, String name});

/// Picks a parent stock category, with an inline "New category" affordance
/// (03_RULES.md §9). Sub-categories are NOT chosen here — they are free-text tags
/// entered per line (§1.16).
Future<PickedCategory?> showCategoryPicker(BuildContext context) {
  return showModalBottomSheet<PickedCategory>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _CategoryPicker(),
  );
}

class _CategoryPicker extends ConsumerStatefulWidget {
  const _CategoryPicker();
  @override
  ConsumerState<_CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<_CategoryPicker> {
  final _newName = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    final result =
        await ref.read(manageStockProvider).createCategory(_newName.text);
    if (!mounted) return;
    if (result is Success<String>) {
      bumpLedger(ref);
      Navigator.of(context).pop((id: result.value, name: _newName.text.trim()));
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cats = ref.watch(stockPositionsProvider);
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.hairline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose category',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Flexible(
                child: cats.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                  // Transparent Material so ListTile ink/splash has a Material
                  // ancestor nearer than the coloured Container (Flutter asserts
                  // on ListTile-inside-DecoratedBox).
                  data: (list) => Material(
                    type: MaterialType.transparency,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final item in list)
                          ListTile(
                            title: Text(item.category.name,
                                style: TextStyle(color: c.ink)),
                            trailing: Text(
                                item.position.quantityGrams == 0
                                    ? ''
                                    : '${(item.position.quantityGrams / 1000).toStringAsFixed(0)} kg',
                                style: TextStyle(color: c.muted, fontSize: 12)),
                            onTap: () => Navigator.of(context).pop(
                                (id: item.category.id, name: item.category.name)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newName,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'New category name',
                        filled: true,
                        fillColor: c.surfaceSoft,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.secondary),
                          borderSide: BorderSide(color: c.hairline),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed:
                        _busy || _newName.text.trim().isEmpty ? null : _create,
                    icon: const Icon(Icons.add),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../../domain/use_cases/use_case_result.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import 'party_common.dart';

/// Bottom-sheet form to create a party. Returns the new party id (or null if
/// cancelled). Used by the Parties screen and inline from the New Bill flow.
Future<String?> showNewPartySheet(BuildContext context, WidgetRef ref,
    {String? initialName}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _NewPartySheet(initialName: initialName),
  );
}

/// Edit an existing party — writes go through [ManageParty.edit], logging each
/// changed field to `UpdateHistory` (03_RULES.md §1.19).
Future<void> showEditPartySheet(
    BuildContext context, WidgetRef ref, Party party) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _NewPartySheet(existing: party),
  );
}

class _NewPartySheet extends ConsumerStatefulWidget {
  final String? initialName;
  final Party? existing;
  const _NewPartySheet({this.initialName, this.existing});

  @override
  ConsumerState<_NewPartySheet> createState() => _NewPartySheetState();
}

class _NewPartySheetState extends ConsumerState<_NewPartySheet> {
  late final _name =
      TextEditingController(text: widget.existing?.name ?? widget.initialName ?? '');
  late final _phone =
      TextEditingController(text: widget.existing?.phone ?? '');
  late PartyTypeDb _type = widget.existing?.type ?? PartyTypeDb.both;
  bool _busy = false;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final manage = ref.read(managePartyProvider);
    if (_isEdit) {
      final result = await manage.edit(
        partyId: widget.existing!.id,
        name: _name.text,
        type: _type,
        phone: _phone.text,
      );
      if (!mounted) return;
      if (result is Success) {
        bumpLedger(ref);
        Navigator.of(context).pop();
      } else {
        setState(() => _busy = false);
      }
      return;
    }
    final result = await manage.create(
      name: _name.text,
      type: _type,
      phone: _phone.text,
    );
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        bumpLedger(ref);
        Navigator.of(context).pop(value);
      default:
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
              Text(_isEdit ? 'Edit party' : 'New party',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 18),
              AppTextField(
                  controller: _name, label: 'NAME', autofocus: true, hint: 'e.g. Ali Traders'),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text('TYPE',
                    style: Theme.of(context).textTheme.labelSmall),
              ),
              SegmentedPills<PartyTypeDb>(
                values: PartyTypeDb.values,
                selected: _type,
                labelOf: (t) => switch (t) {
                  PartyTypeDb.supplier => 'Supplier',
                  PartyTypeDb.buyer => 'Buyer',
                  PartyTypeDb.both => 'Both',
                },
                onSelect: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 16),
              AppTextField(
                  controller: _phone,
                  label: 'PHONE (OPTIONAL)',
                  keyboardType: TextInputType.phone,
                  mono: true),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: PillButton('Cancel',
                        primary: false,
                        onPressed: () => Navigator.of(context).pop()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PillButton(_isEdit ? 'Save changes' : 'Save party',
                        busy: _busy,
                        onPressed: _name.text.trim().isEmpty ? null : _save),
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

/// A searchable picker returning an existing party id, with an inline
/// "New party" affordance (03_RULES.md §9 — no manage-categories detour).
Future<String?> showPartyPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _PartyPicker(),
  );
}

class _PartyPicker extends ConsumerStatefulWidget {
  const _PartyPicker();
  @override
  ConsumerState<_PartyPicker> createState() => _PartyPickerState();
}

class _PartyPickerState extends ConsumerState<_PartyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final parties = ref.watch(partiesListProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Choose party',
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: () async {
                      final id = await showNewPartySheet(context, ref,
                          initialName: _query.trim().isEmpty ? null : _query);
                      if (id != null && context.mounted) {
                        Navigator.of(context).pop(id);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search parties',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: c.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.secondary),
                    borderSide: BorderSide(color: c.hairline),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: parties.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                  data: (list) {
                    final filtered = list
                        .where((p) => p.party.name
                            .toLowerCase()
                            .contains(_query.toLowerCase()))
                        .toList();
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('No parties yet — add one above.',
                            style: TextStyle(color: c.muted)),
                      );
                    }
                    // Wrap in a transparent Material so ListTile ink/splash has
                    // a Material ancestor nearer than the coloured Container
                    // (Flutter asserts on ListTile-inside-DecoratedBox).
                    return Material(
                      type: MaterialType.transparency,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final p in filtered)
                            ListTile(
                              leading: PartyAvatar(p.party.name, size: 36),
                              title: Text(p.party.name,
                                  style: TextStyle(color: c.ink)),
                              subtitle: Text(partyTypeLabel(p.party.type),
                                  style: TextStyle(color: c.muted, fontSize: 12)),
                              onTap: () =>
                                  Navigator.of(context).pop(p.party.id),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

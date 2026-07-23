import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cash_read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../data/local/tables.dart';
import '../bills/bill_detail_screen.dart';
import '../parties/party_detail_screen.dart';
import '../shared_widgets/amount_text.dart';
import 'cash_entry_tile.dart';

/// Date-range presets for the Roznamcha (01_PRD.md §4.5). "This week" starts
/// Monday; "This month" is the calendar month (03_RULES.md §5, local timezone).
enum _DateRange { all, today, week, month }

class _Filters {
  final PoolNameDb? pool;
  final bool? isIn; // null = both directions
  final _DateRange range;
  final String? partyId;
  final String? expenseCategoryId;

  const _Filters({
    this.pool,
    this.isIn,
    this.range = _DateRange.all,
    this.partyId,
    this.expenseCategoryId,
  });

  _Filters copyWith({
    PoolNameDb? pool,
    bool clearPool = false,
    bool? isIn,
    bool clearDir = false,
    _DateRange? range,
    String? partyId,
    bool clearParty = false,
    String? expenseCategoryId,
    bool clearExpense = false,
  }) =>
      _Filters(
        pool: clearPool ? null : (pool ?? this.pool),
        isIn: clearDir ? null : (isIn ?? this.isIn),
        range: range ?? this.range,
        partyId: clearParty ? null : (partyId ?? this.partyId),
        expenseCategoryId:
            clearExpense ? null : (expenseCategoryId ?? this.expenseCategoryId),
      );

  bool get isEmpty =>
      pool == null &&
      isIn == null &&
      range == _DateRange.all &&
      partyId == null &&
      expenseCategoryId == null;
}

DateTime? _rangeStart(_DateRange r, DateTime now) {
  switch (r) {
    case _DateRange.all:
      return null;
    case _DateRange.today:
      return DateTime(now.year, now.month, now.day);
    case _DateRange.week:
      final monday = now.subtract(Duration(days: now.weekday - 1));
      return DateTime(monday.year, monday.month, monday.day);
    case _DateRange.month:
      return DateTime(now.year, now.month);
  }
}

class RoznamchaScreen extends ConsumerStatefulWidget {
  const RoznamchaScreen({super.key});

  @override
  ConsumerState<RoznamchaScreen> createState() => _RoznamchaScreenState();
}

class _RoznamchaScreenState extends ConsumerState<RoznamchaScreen> {
  _Filters _filters = const _Filters();

  bool _matches(CashLedgerEntry e) {
    if (_filters.pool != null && e.pool != _filters.pool) return false;
    if (_filters.isIn != null && e.isIn != _filters.isIn) return false;
    if (_filters.partyId != null && e.partyId != _filters.partyId) return false;
    if (_filters.expenseCategoryId != null &&
        e.expenseCategoryId != _filters.expenseCategoryId) {
      return false;
    }
    final start = _rangeStart(_filters.range, DateTime.now());
    if (start != null && e.date.isBefore(start)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ledger = ref.watch(cashLedgerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Roznamcha')),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (all) {
          final filtered = all.where(_matches).toList(growable: false);
          return Column(
            children: [
              _FilterBar(
                filters: _filters,
                entries: all,
                onChanged: (f) => setState(() => _filters = f),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _empty(context)
                    : _DayGroupedList(entries: filtered),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final c = context.c;
    return Center(
      child: Text(
          _filters.isEmpty ? 'No cash movements yet.' : 'Nothing matches these filters.',
          style: TextStyle(color: c.muted)),
    );
  }
}

/// A day header + its entries, with the day's net and a running cumulative
/// balance (over the filtered set) so "balance at the end of any day" is always
/// answerable (01_PRD.md §4.5).
class _DayGroupedList extends StatelessWidget {
  final List<CashLedgerEntry> entries; // newest first
  const _DayGroupedList({required this.entries});

  int _signed(CashLedgerEntry e) => e.isIn ? e.amountPaisa : -e.amountPaisa;

  @override
  Widget build(BuildContext context) {
    // Cumulative balance oldest -> newest, keyed to each entry.
    final oldestFirst = entries.reversed.toList(growable: false);
    final cumulativeAfter = <String, int>{};
    var running = 0;
    for (final e in oldestFirst) {
      running += _signed(e);
      cumulativeAfter[e.movement.id] = running;
    }

    // Group newest-first into days (preserving order).
    final days = <DateTime, List<CashLedgerEntry>>{};
    for (final e in entries) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      days.putIfAbsent(key, () => []).add(e);
    }

    final c = context.c;
    final children = <Widget>[];
    for (final day in days.keys) {
      final rows = days[day]!;
      final dayNet = rows.fold<int>(0, (s, e) => s + _signed(e));
      // Cumulative at end of this day = cumulative after the day's newest entry.
      final endOfDay = cumulativeAfter[rows.first.movement.id] ?? 0;
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Row(
          children: [
            Text(formatDate(day),
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('Day ', style: TextStyle(color: c.muted, fontSize: 11)),
            Text(dayNet >= 0 ? '+' : '−',
                style: TextStyle(
                    color: dayNet >= 0 ? c.semanticUp : c.semanticDown,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            AmountText(dayNet, size: 12, showSymbol: false),
            Text('   Bal ', style: TextStyle(color: c.muted, fontSize: 11)),
            AmountText(endOfDay,
                size: 12,
                showSymbol: false,
                tone:
                    endOfDay < 0 ? AmountTone.payable : AmountTone.neutral),
          ],
        ),
      ));
      for (final e in rows) {
        children.add(_TappableEntry(entry: e));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: children,
    );
  }
}

class _TappableEntry extends StatelessWidget {
  final CashLedgerEntry entry;
  const _TappableEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    VoidCallback? onTap;
    if (entry.billId != null) {
      onTap = () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BillDetailScreen(billId: entry.billId!)));
    } else if (entry.partyId != null) {
      onTap = () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PartyDetailScreen(partyId: entry.partyId!)));
    }
    return CashEntryTile(entry: entry, showPool: true, onTap: onTap);
  }
}

class _FilterBar extends StatelessWidget {
  final _Filters filters;
  final List<CashLedgerEntry> entries;
  final ValueChanged<_Filters> onChanged;
  const _FilterBar({
    required this.filters,
    required this.entries,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Parties / expense categories present in the data, for the popups.
    final partyNames = <String, String>{};
    final expenseNames = <String, String>{};
    for (final e in entries) {
      if (e.partyId != null && e.subtitle != null) {
        partyNames[e.partyId!] = e.subtitle!;
      }
      if (e.expenseCategoryId != null && e.subtitle != null) {
        expenseNames[e.expenseCategoryId!] = e.subtitle!;
      }
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.hairline)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _RangeChip(filters: filters, onChanged: onChanged),
            const SizedBox(width: 8),
            _PoolChip(filters: filters, onChanged: onChanged),
            const SizedBox(width: 8),
            _DirChip(filters: filters, onChanged: onChanged),
            if (partyNames.isNotEmpty) ...[
              const SizedBox(width: 8),
              _PartyChip(
                  filters: filters, onChanged: onChanged, names: partyNames),
            ],
            if (expenseNames.isNotEmpty) ...[
              const SizedBox(width: 8),
              _ExpenseChip(
                  filters: filters, onChanged: onChanged, names: expenseNames),
            ],
            if (!filters.isEmpty) ...[
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Clear'),
                onPressed: () => onChanged(const _Filters()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final _Filters filters;
  final ValueChanged<_Filters> onChanged;
  const _RangeChip({required this.filters, required this.onChanged});

  String _label(_DateRange r) => switch (r) {
        _DateRange.all => 'All time',
        _DateRange.today => 'Today',
        _DateRange.week => 'This week',
        _DateRange.month => 'This month',
      };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_DateRange>(
      onSelected: (r) => onChanged(filters.copyWith(range: r)),
      itemBuilder: (_) => [
        for (final r in _DateRange.values)
          PopupMenuItem(value: r, child: Text(_label(r))),
      ],
      child: _ChipShell(
        label: _label(filters.range),
        active: filters.range != _DateRange.all,
        icon: Icons.event_outlined,
      ),
    );
  }
}

class _PoolChip extends StatelessWidget {
  final _Filters filters;
  final ValueChanged<_Filters> onChanged;
  const _PoolChip({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PoolNameDb?>(
      onSelected: (p) => onChanged(
          p == null ? filters.copyWith(clearPool: true) : filters.copyWith(pool: p)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All pools')),
        for (final p in PoolNameDb.values)
          PopupMenuItem(value: p, child: Text(poolLabel(p))),
      ],
      child: _ChipShell(
        label: filters.pool == null ? 'All pools' : poolLabel(filters.pool!),
        active: filters.pool != null,
        icon: Icons.account_balance_wallet_outlined,
      ),
    );
  }
}

class _DirChip extends StatelessWidget {
  final _Filters filters;
  final ValueChanged<_Filters> onChanged;
  const _DirChip({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (v) => onChanged(v == 0
          ? filters.copyWith(clearDir: true)
          : filters.copyWith(isIn: v == 1)),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 0, child: Text('In & out')),
        PopupMenuItem(value: 1, child: Text('Money in')),
        PopupMenuItem(value: 2, child: Text('Money out')),
      ],
      child: _ChipShell(
        label: filters.isIn == null
            ? 'In & out'
            : filters.isIn!
                ? 'Money in'
                : 'Money out',
        active: filters.isIn != null,
        icon: Icons.swap_vert,
      ),
    );
  }
}

class _PartyChip extends StatelessWidget {
  final _Filters filters;
  final ValueChanged<_Filters> onChanged;
  final Map<String, String> names;
  const _PartyChip(
      {required this.filters, required this.onChanged, required this.names});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: (id) => onChanged(id == null
          ? filters.copyWith(clearParty: true)
          : filters.copyWith(partyId: id)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All parties')),
        for (final e in names.entries)
          PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
      child: _ChipShell(
        label: filters.partyId == null
            ? 'Party'
            : (names[filters.partyId] ?? 'Party'),
        active: filters.partyId != null,
        icon: Icons.person_outline,
      ),
    );
  }
}

class _ExpenseChip extends StatelessWidget {
  final _Filters filters;
  final ValueChanged<_Filters> onChanged;
  final Map<String, String> names;
  const _ExpenseChip(
      {required this.filters, required this.onChanged, required this.names});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: (id) => onChanged(id == null
          ? filters.copyWith(clearExpense: true)
          : filters.copyWith(expenseCategoryId: id)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All expenses')),
        for (final e in names.entries)
          PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
      child: _ChipShell(
        label: filters.expenseCategoryId == null
            ? 'Expense'
            : (names[filters.expenseCategoryId] ?? 'Expense'),
        active: filters.expenseCategoryId != null,
        icon: Icons.category_outlined,
      ),
    );
  }
}

class _ChipShell extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  const _ChipShell(
      {required this.label, required this.active, required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? c.primary.withValues(alpha: 0.12) : c.surfaceStrong,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
            color: active ? c.primary.withValues(alpha: 0.4) : c.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: active ? c.primary : c.muted),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: active ? c.primary : c.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Icon(Icons.expand_more, size: 15, color: active ? c.primary : c.muted),
        ],
      ),
    );
  }
}

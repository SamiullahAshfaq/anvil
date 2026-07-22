import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../presentation/bills/bills_screen.dart';
import '../presentation/home_dashboard/dashboard_screen.dart';
import '../presentation/onboarding/day_zero_screen.dart';
import '../presentation/parties/parties_screen.dart';
import '../presentation/stock/stock_screen.dart';
import '../presentation/trash/trash_screen.dart';
import '../security/access_mode.dart';
import 'providers.dart';

/// Navigation destinations from the drawer (02_ARCHITECTURE.md §1).
enum _Destination {
  dashboard('Dashboard', Icons.dashboard_outlined),
  parties('Parties', Icons.people_outline),
  bills('Bills', Icons.receipt_long_outlined),
  stock('Stock', Icons.inventory_2_outlined),
  trash('Trash', Icons.delete_outline);

  const _Destination(this.label, this.icon);
  final String label;
  final IconData icon;

  Widget get screen => switch (this) {
        _Destination.dashboard => const DashboardScreen(),
        _Destination.parties => const PartiesScreen(),
        _Destination.bills => const BillsScreen(),
        _Destination.stock => const StockScreen(),
        _Destination.trash => const TrashScreen(),
      };
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  _Destination _current = _Destination.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _Drawer(
        current: _current,
        onSelect: (d) {
          setState(() => _current = d);
          Navigator.of(context).pop();
        },
      ),
      body: _current.screen,
    );
  }
}

class _Drawer extends ConsumerWidget {
  final _Destination current;
  final ValueChanged<_Destination> onSelect;
  const _Drawer({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final isView = ref.watch(accessModeProvider) == AccessMode.view;
    return Drawer(
      backgroundColor: c.canvas,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Godam Ledger',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (isView)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: c.surfaceStrong,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text('View only',
                          style: TextStyle(color: c.muted, fontSize: 11)),
                    ),
                ],
              ),
            ),
            for (final d in _Destination.values)
              ListTile(
                leading: Icon(d.icon,
                    color: d == current ? c.primary : c.muted, size: 22),
                title: Text(
                  d.label,
                  style: TextStyle(
                    color: d == current ? c.ink : c.body,
                    fontWeight:
                        d == current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: d == current,
                onTap: () => onSelect(d),
              ),
            const Spacer(),
            const Divider(height: 1),
            if (!isView)
              ListTile(
                leading: Icon(Icons.playlist_add_check_circle_outlined,
                    color: c.muted, size: 22),
                title: Text('Opening position (Day-0)',
                    style: TextStyle(color: c.body)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const DayZeroScreen()));
                },
              ),
            ListTile(
              leading: Icon(Icons.lock_outline, color: c.muted, size: 22),
              title: Text('Lock', style: TextStyle(color: c.body)),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(sessionUnlockedProvider.notifier).state = false;
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../shared_widgets/calm_sheet.dart';
import 'pin_pad.dart';

/// The lock screen. Verifying the Admin PIN unlocks full control; the optional
/// View PIN unlocks read-only mode. The real write boundary is still enforced in
/// the use-case layer (03_RULES.md §1.22) — this only chooses the session mode.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  int _resetToken = 0;
  String? _businessName;

  @override
  void initState() {
    super.initState();
    ref.read(pinServiceProvider).businessName().then((n) {
      if (mounted) setState(() => _businessName = n);
    });
  }

  Future<void> _onEntered(String pin) async {
    final mode = await ref.read(pinServiceProvider).verify(pin);
    if (!mounted) return;
    if (mode == null) {
      setState(() => _resetToken++);
      showCalmError(context, Exception('That PIN didn\'t match. Try again.'));
      return;
    }
    ref.read(accessModeProvider.notifier).state = mode;
    ref.read(sessionUnlockedProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(14)),
                ),
                const SizedBox(height: 16),
                PinPad(
                  title: _businessName ?? 'Godam Ledger',
                  subtitle: 'Enter your PIN',
                  resetToken: _resetToken,
                  onCompleted: _onEntered,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

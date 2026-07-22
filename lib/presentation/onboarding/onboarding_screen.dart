import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../security/access_mode.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import 'pin_pad.dart';

enum _Stage { name, adminPin, adminConfirm, viewChoice, viewPin, viewConfirm }

/// First-run onboarding: business name, a required Admin PIN, and an optional
/// View-only PIN (01_PRD.md §4.8). Opening balances are entered afterwards via
/// the Day-0 wizard (reachable from the drawer), as real dated ledger entries.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Stage _stage = _Stage.name;
  final _name = TextEditingController();
  String? _adminPin;
  String? _viewPin;
  int _resetToken = 0;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(pinServiceProvider).completeSetup(
          businessName: _name.text.trim(),
          adminPin: _adminPin!,
          viewPin: _viewPin,
        );
    if (!mounted) return;
    ref.read(accessModeProvider.notifier).state = AccessMode.admin;
    ref.read(sessionUnlockedProvider.notifier).state = true;
    ref.invalidate(setupCompleteProvider);
  }

  void _onAdmin(String pin) {
    setState(() {
      _adminPin = pin;
      _stage = _Stage.adminConfirm;
      _resetToken++;
    });
  }

  void _onAdminConfirm(String pin) {
    if (pin != _adminPin) {
      _adminPin = null;
      setState(() {
        _stage = _Stage.adminPin;
        _resetToken++;
      });
      showCalmError(context, Exception('PINs didn\'t match. Set it again.'));
      return;
    }
    setState(() => _stage = _Stage.viewChoice);
  }

  void _onView(String pin) {
    setState(() {
      _viewPin = pin;
      _stage = _Stage.viewConfirm;
      _resetToken++;
    });
  }

  Future<void> _onViewConfirm(String pin) async {
    if (pin != _viewPin) {
      _viewPin = null;
      setState(() {
        _stage = _Stage.viewPin;
        _resetToken++;
      });
      showCalmError(context, Exception('PINs didn\'t match. Set it again.'));
      return;
    }
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: switch (_stage) {
              _Stage.name => _nameStep(),
              _Stage.adminPin => PinPad(
                  title: 'Set an Admin PIN',
                  subtitle: 'Full control. 4 digits.',
                  resetToken: _resetToken,
                  onCompleted: _onAdmin),
              _Stage.adminConfirm => PinPad(
                  title: 'Confirm Admin PIN',
                  resetToken: _resetToken,
                  onCompleted: _onAdminConfirm),
              _Stage.viewChoice => _viewChoiceStep(),
              _Stage.viewPin => PinPad(
                  title: 'Set a View-only PIN',
                  subtitle: 'Read-only. Cannot edit anything.',
                  resetToken: _resetToken,
                  onCompleted: _onView),
              _Stage.viewConfirm => PinPad(
                  title: 'Confirm View PIN',
                  resetToken: _resetToken,
                  onCompleted: _onViewConfirm),
            },
          ),
        ),
      ),
    );
  }

  Widget _nameStep() {
    final c = context.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              color: c.primary, borderRadius: BorderRadius.circular(15)),
        ),
        const SizedBox(height: 24),
        Text('Welcome to Godam Ledger',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Let\'s set up your ledger. First, name your business.',
            style: TextStyle(color: c.muted)),
        const SizedBox(height: 28),
        AppTextField(
            controller: _name,
            label: 'BUSINESS NAME',
            autofocus: true,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 24),
        PillButton('Continue',
            onPressed: _name.text.trim().isEmpty
                ? null
                : () => setState(() => _stage = _Stage.adminPin)),
      ],
    );
  }

  Widget _viewChoiceStep() {
    final c = context.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Add a View-only PIN?',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
            'Optional. Hand the phone to someone in read-only mode — they can see balances but cannot change anything.',
            style: TextStyle(color: c.muted)),
        const SizedBox(height: 24),
        PillButton('Add View PIN',
            onPressed: () => setState(() {
                  _stage = _Stage.viewPin;
                  _resetToken++;
                })),
        const SizedBox(height: 12),
        PillButton('Skip for now', primary: false, onPressed: _finish),
      ],
    );
  }
}

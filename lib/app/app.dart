import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/onboarding/pin_screen.dart';
import 'app_shell.dart';
import 'providers.dart';

class GodamLedgerApp extends StatelessWidget {
  const GodamLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Godam Ledger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const _AppRoot(),
    );
  }
}

/// Gates the app: first run → onboarding; otherwise the PIN lock until the
/// session is unlocked; then the shell. The PIN chooses the session's access
/// mode, but the real write boundary lives in the use-case layer.
class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(setupCompleteProvider);
    return setup.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const OnboardingScreen(),
      data: (complete) {
        if (!complete) return const OnboardingScreen();
        final unlocked = ref.watch(sessionUnlockedProvider);
        return unlocked ? const AppShell() : const PinScreen();
      },
    );
  }
}

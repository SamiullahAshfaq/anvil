import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A calm 4-digit PIN entry: four dots + an on-screen keypad. Emits [onCompleted]
/// when the fourth digit is entered, then clears itself for the next attempt.
class PinPad extends StatefulWidget {
  final String title;
  final String? subtitle;
  final ValueChanged<String> onCompleted;

  /// Bumped by the parent to shake/clear on a wrong PIN.
  final int resetToken;

  const PinPad({
    super.key,
    required this.title,
    this.subtitle,
    required this.onCompleted,
    this.resetToken = 0,
  });

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';

  @override
  void didUpdateWidget(PinPad old) {
    super.didUpdateWidget(old);
    if (old.resetToken != widget.resetToken) {
      setState(() => _pin = '');
    }
  }

  void _tap(String d) {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);
    if (_pin.length == 4) {
      final entered = _pin;
      widget.onCompleted(entered);
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(widget.subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted)),
        ],
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 4; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? c.primary : Colors.transparent,
                  border: Border.all(
                      color: i < _pin.length ? c.primary : c.hairline,
                      width: 1.5),
                ),
              ),
          ],
        ),
        const SizedBox(height: 36),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in row) _key(d)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 76, height: 76),
            _key('0'),
            SizedBox(
              width: 76,
              height: 76,
              child: IconButton(
                onPressed: _backspace,
                icon: Icon(Icons.backspace_outlined, color: c.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _key(String d) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Material(
          color: c.surfaceSoft,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _tap(d),
            child: Center(
              child: Text(d, style: monoStyle(size: 24, color: c.ink)),
            ),
          ),
        ),
      ),
    );
  }
}

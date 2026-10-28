import 'package:flutter/material.dart';
import 'package:tailor_pro/core/utils/fraction_formatter.dart';

class FractionalKeypad extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onNext;
  final VoidCallback? onDone;
  final String unit;

  const FractionalKeypad({
    super.key,
    required this.controller,
    this.onNext,
    this.onDone,
    this.unit = 'inch',
  });

  void _insertText(String text) {
    final current = controller.text;
    controller.text = current + text;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  void _backspace() {
    final current = controller.text;
    if (current.isNotEmpty) {
      controller.text = current.substring(0, current.length - 1);
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  void _clear() {
    controller.clear();
  }

  void _adjust(double delta) {
    final val = FractionFormatter.parse(controller.text) ?? 0.0;
    final newVal = (val + delta).clamp(0.0, 200.0);
    controller.text = FractionFormatter.format(newVal);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyBg = isDark ? const Color(0xFF334155) : Colors.white;
    final keyFg = isDark ? Colors.white : const Color(0xFF0F172A);
    final accentBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF);
    final accentFg = isDark ? Colors.white : const Color(0xFF1E3A8A);

    Widget buildKey(String label, VoidCallback onTap, {Color? bg, Color? fg, double flex = 1}) {
      return Expanded(
        flex: (flex * 10).toInt(),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Material(
            color: bg ?? keyBg,
            elevation: 1,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: fg ?? keyFg,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 0: Quick Steppers & Fractions
          Row(
            children: [
              buildKey('-½"', () => _adjust(-0.5), bg: accentBg, fg: accentFg),
              buildKey('+½"', () => _adjust(0.5), bg: accentBg, fg: accentFg),
              buildKey('¼', () => _insertText('¼'), bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
              buildKey('½', () => _insertText('½'), bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
              buildKey('¾', () => _insertText('¾'), bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
            ],
          ),
          // Row 1: 1, 2, 3, Backspace
          Row(
            children: [
              buildKey('1', () => _insertText('1')),
              buildKey('2', () => _insertText('2')),
              buildKey('3', () => _insertText('3')),
              buildKey('⌫', _backspace, bg: const Color(0xFFFEE2E2), fg: const Color(0xFFB91C1C)),
            ],
          ),
          // Row 2: 4, 5, 6, Clear
          Row(
            children: [
              buildKey('4', () => _insertText('4')),
              buildKey('5', () => _insertText('5')),
              buildKey('6', () => _insertText('6')),
              buildKey('C', _clear, bg: const Color(0xFFF3F4F6), fg: const Color(0xFF4B5563)),
            ],
          ),
          // Row 3: 7, 8, 9, Decimal point
          Row(
            children: [
              buildKey('7', () => _insertText('7')),
              buildKey('8', () => _insertText('8')),
              buildKey('9', () => _insertText('9')),
              buildKey('.', () => _insertText('.')),
            ],
          ),
          // Row 4: 0, ⅛, Next
          Row(
            children: [
              buildKey('0', () => _insertText('0'), flex: 1),
              buildKey('⅛', () => _insertText('⅛'), bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
              buildKey(
                onNext != null ? 'اگلا (Next) ➔' : 'مکمل (Done) ✓',
                () {
                  if (onNext != null) {
                    onNext!();
                  } else if (onDone != null) {
                    onDone!();
                  }
                },
                bg: const Color(0xFF1E3A8A),
                fg: Colors.white,
                flex: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


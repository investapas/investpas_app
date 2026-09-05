import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';

// ── 4 dot indicators ──────────────────────────────────────────────────────────
class PinDots extends StatelessWidget {
  final int filledCount;
  const PinDots({super.key, required this.filledCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 18, height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Colorz.primary : Colors.transparent,
            border: Border.all(
              color: filled ? Colorz.primary : Colorz.hintTextColor,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

// ── Number pad ────────────────────────────────────────────────────────────────
class PinPad extends StatelessWidget {
  final void Function(String key) onKey;
  final Widget? extraBottomLeft; // e.g. biometric button on lock screen

  const PinPad({super.key, required this.onKey, this.extraBottomLeft});

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1','2','3'],
      ['4','5','6'],
      ['7','8','9'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          ...keys.map((row) => _buildRow(row)),
          // Bottom row: extra left, 0, delete
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: extraBottomLeft ?? const SizedBox()),
                const SizedBox(width: 8),
                Expanded(child: _PinKey(label: '0', onTap: () => onKey('0'))),
                const SizedBox(width: 8),
                Expanded(
                  child: _PinKey(
                    icon: Icons.backspace_outlined,
                    onTap: () => onKey('del'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: keys.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
              child: _PinKey(label: e.value, onTap: () => onKey(e.value)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _PinKey({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colorz.backgroundColor2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colorz.dividerColor),
        ),
        alignment: Alignment.center,
        child: label != null
            ? Text(label!,
                style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor, fontSize: SizeConfig.largeFont))
            : Icon(icon, color: Colorz.textColor, size: 22),
      ),
    );
  }
}

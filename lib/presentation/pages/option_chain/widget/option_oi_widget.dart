import 'dart:math';

import 'package:flutter/material.dart';
import 'package:investapas/data/models/option_chain_model.dart';
import 'package:investapas/presentation/bloc/option_chain/option_chain_state.dart';

import '../../../../core/constants/constants.dart';
import '../../../../data/services/live_price_service.dart';

class OptionOiWidget extends StatelessWidget {
  final OptionChainState? optionChainState;
  final void Function(OptionChainModel)? onTapCe;
  final void Function(OptionChainModel)? onTapPe;
  final String? selectedSecId;
  final ScrollController? scrollController;

  const OptionOiWidget({
    super.key,
    this.optionChainState,
    this.onTapCe,
    this.onTapPe,
    this.selectedSecId,
    this.scrollController,
  });

  static double _parseOiVal(String s) {
    if (s == '—' || s.isEmpty) return 0;
    if (s.endsWith('Cr')) return (double.tryParse(s.replaceAll('Cr', '')) ?? 0) * 1e7;
    if (s.endsWith('L')) return (double.tryParse(s.replaceAll('L', '')) ?? 0) * 1e5;
    if (s.endsWith('K')) return (double.tryParse(s.replaceAll('K', '')) ?? 0) * 1e3;
    return double.tryParse(s) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final items = optionChainState!.allItems;
    final maxCall = items.isEmpty
        ? 1.0
        : items.map((i) => _parseOiVal(i.callOi)).reduce(max).clamp(1, double.maxFinite).toDouble();
    final maxPut = items.isEmpty
        ? 1.0
        : items.map((i) => _parseOiVal(i.putOi)).reduce(max).clamp(1, double.maxFinite).toDouble();

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Column header ──────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.spaceBetween * 2,
                vertical: SizeConfig.spaceBetween * 0.9),
            color: Colorz.bottomPillBg,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text("CE LTP / OI",
                      style: AppTextStyles.medium.copyWith(
                          fontSize: SizeConfig.smallerFont,
                          color: Colorz.hintTextColor)),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text("STRIKE",
                        style: AppTextStyles.medium.copyWith(
                            fontSize: SizeConfig.smallerFont,
                            color: Colorz.hintTextColor)),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("PE LTP / OI",
                        style: AppTextStyles.medium.copyWith(
                            fontSize: SizeConfig.smallerFont,
                            color: Colorz.hintTextColor)),
                  ),
                ),
              ],
            ),
          ),

          // ── Rows ─────────────────────────────────────────────────────
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              return OiChainItem(
                item: item,
                maxCallOi: maxCall,
                maxPutOi: maxPut,
                onTapCe: onTapCe != null ? () => onTapCe!(item) : null,
                onTapPe: onTapPe != null ? () => onTapPe!(item) : null,
                selectedSecId: selectedSecId,
              );
            },
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
        ],
      ),
    );
  }
}

class OiChainItem extends StatelessWidget {
  final OptionChainModel? item;
  final double maxCallOi;
  final double maxPutOi;
  final VoidCallback? onTapCe;
  final VoidCallback? onTapPe;
  final String? selectedSecId;

  const OiChainItem({
    super.key,
    this.item,
    this.maxCallOi = 1,
    this.maxPutOi = 1,
    this.onTapCe,
    this.onTapPe,
    this.selectedSecId,
  });

  static double _parseOiVal(String s) {
    if (s == '—' || s.isEmpty) return 0;
    if (s.endsWith('Cr')) return (double.tryParse(s.replaceAll('Cr', '')) ?? 0) * 1e7;
    if (s.endsWith('L')) return (double.tryParse(s.replaceAll('L', '')) ?? 0) * 1e5;
    if (s.endsWith('K')) return (double.tryParse(s.replaceAll('K', '')) ?? 0) * 1e3;
    return double.tryParse(s) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isAtm = item!.isAtm;
    final ceSelected = selectedSecId != null &&
        selectedSecId == item!.callSecId &&
        item!.callSecId.isNotEmpty;
    final peSelected = selectedSecId != null &&
        selectedSecId == item!.putSecId &&
        item!.putSecId.isNotEmpty;

    final callOiRatio = (_parseOiVal(item!.callOi) / maxCallOi).clamp(0.0, 1.0);
    final putOiRatio  = (_parseOiVal(item!.putOi)  / maxPutOi).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colorz.dividerColor, width: 0.5),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Call side ─────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: onTapCe,
                child: Container(
                  color: ceSelected
                      ? Colorz.greenColor.withValues(alpha: 0.08)
                      : isAtm
                          ? const Color(0xFFEBF0FF)
                          : null,
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spaceBetween,
                      vertical: 10),
                  child: Stack(
                    children: [
                      // OI bar (right-aligned, growing rightward from right edge)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: FractionallySizedBox(
                          widthFactor: callOiRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3737).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Text content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _liveText(item!.callSecId, item!.callVolume, Colorz.greenColor),
                          Text(item!.callOi,
                              style: AppTextStyles.medium.copyWith(
                                  fontSize: SizeConfig.smallerFont,
                                  color: Colorz.hintTextColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Strike ────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Container(
                color: isAtm
                    ? const Color(0xFF2A2F3A).withValues(alpha: 0.05)
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: isAtm
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2F3A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item!.strike,
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colors.white,
                              fontSize: SizeConfig.smallFont),
                        ),
                      )
                    : Text(
                        item!.strike,
                        style: AppTextStyles.medium.copyWith(
                            color: Colorz.textColor,
                            fontSize: SizeConfig.smallFont),
                      ),
              ),
            ),

            // ── Put side ─────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: onTapPe,
                child: Container(
                  color: peSelected
                      ? Colorz.redColor.withValues(alpha: 0.08)
                      : isAtm
                          ? const Color(0xFFEBF0FF)
                          : null,
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spaceBetween,
                      vertical: 10),
                  child: Stack(
                    children: [
                      // OI bar (left-aligned, growing leftward from left edge)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: FractionallySizedBox(
                          widthFactor: putOiRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF3AAE00).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Text content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _liveText(item!.putSecId, item!.putVolume, Colorz.redColor,
                              align: TextAlign.right),
                          Text(item!.putOi,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.medium.copyWith(
                                  fontSize: SizeConfig.smallerFont,
                                  color: Colorz.hintTextColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveText(String secId, String fallback, Color color,
      {TextAlign align = TextAlign.left}) {
    return StreamBuilder<Map<String, double>>(
      stream: LivePriceService.instance.stream,
      initialData: LivePriceService.instance.prices,
      builder: (_, snap) {
        final prices = snap.data ?? {};
        final live = secId.isNotEmpty ? prices[secId] : null;
        final text =
            (live != null && live > 0) ? live.toStringAsFixed(2) : fallback;
        return Text(text,
            textAlign: align,
            style: AppTextStyles.semiBold.copyWith(
                color: color, fontSize: SizeConfig.smallFont));
      },
    );
  }
}

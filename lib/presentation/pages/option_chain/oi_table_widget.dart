import 'dart:math';
import 'package:flutter/material.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/data/services/live_price_service.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_state.dart';

const double _kStrikeW = 90.0;
const double _kOiColW = 76.0;
const double _kRowH = 64.0;
const double _kHdrH = 34.0;
const double _kOiSideW = _kOiColW * 2; // 152

class OITableWidget extends StatefulWidget {
  final List<OptionStrike> strikes;
  final double lastPrice;
  final ScrollController vertCtrl;
  final Function(String, String, String, bool) onSelectOption;
  final Function(String, bool) onTap;

  const OITableWidget({
    Key? key,
    required this.strikes,
    required this.lastPrice,
    required this.vertCtrl,
    required this.onSelectOption,
    required this.onTap,
  }) : super(key: key);

  @override
  State<OITableWidget> createState() => _OITableWidgetState();
}

class _OITableWidgetState extends State<OITableWidget> {
  // ONE master horizontal offset - shared by Call and Put
  final ValueNotifier<double> _hOff = ValueNotifier(0.0);
  double _maxHScroll = 0.0;
  double _sideViewW = 150.0;

  @override
  void dispose() {
    _hOff.dispose();
    super.dispose();
  }

  void _onHDrag(DragUpdateDetails d) {
    final newOff = (_hOff.value - d.delta.dx).clamp(0.0, _maxHScroll);
    _hOff.value = newOff;
  }

  String _oiLakhs(dynamic v) {
    if (v == null) return '—';
    final n = (v as num).toDouble();
    return n <= 0 ? '—' : (n / 100000).toStringAsFixed(2);
  }

  String _pct(double? v) {
    if (v == null || v.isNaN || v.isInfinite) return '';
    return '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';
  }

  double? _oiChgPct(dynamic oi, dynamic prev) {
    if (oi == null || prev == null) return null;
    final p = (prev as num).toDouble();
    if (p == 0) return null;
    return ((oi as num).toDouble() - p) / p * 100;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.strikes.isEmpty) {
      return Center(
        child: Text('No data',
            style: AppTextStyles.medium.copyWith(color: Colorz.textColor)),
      );
    }

    // Compute max OI for bar sizing
    double maxCallOi = 1, maxPutOi = 1;
    for (final st in widget.strikes) {
      final co = (st.ce?['oi'] as num?)?.toDouble() ?? 0;
      final po = (st.pe?['oi'] as num?)?.toDouble() ?? 0;
      if (co > maxCallOi) maxCallOi = co;
      if (po > maxPutOi) maxPutOi = po;
    }

    return LayoutBuilder(builder: (ctx, box) {
      _sideViewW = (box.maxWidth - _kStrikeW) / 2;
      _maxHScroll = max(0.0, _kOiSideW - _sideViewW);

      return Column(children: [
        // Header
        _buildHeader(),
        // Table
        Expanded(
          child: Row(children: [
            // Call side
            Expanded(
              child: GestureDetector(
                onHorizontalDragUpdate: _onHDrag,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: _buildPane(
                    strikes: widget.strikes,
                    isCall: true,
                    maxCallOi: maxCallOi,
                    maxPutOi: maxPutOi,
                  ),
                ),
              ),
            ),
            // Strike column
            SizedBox(
              width: _kStrikeW,
              child: _buildStrikePane(widget.strikes),
            ),
            // Put side
            Expanded(
              child: GestureDetector(
                onHorizontalDragUpdate: _onHDrag,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: _buildPane(
                    strikes: widget.strikes,
                    isCall: false,
                    maxCallOi: maxCallOi,
                    maxPutOi: maxPutOi,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]);
    });
  }

  Widget _buildHeader() {
    return Container(
      height: _kHdrH,
      color: Colorz.bottomPillBg,
      child: Row(children: [
        // Call header
        Expanded(
          child: ValueListenableBuilder<double>(
            valueListenable: _hOff,
            builder: (_, off, __) => ClipRect(
              child: Transform.translate(
                offset: Offset(-off, 0),
                child: SizedBox(
                  width: _kOiSideW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: _kOiColW,
                          child: Text('OI (in lakhs)',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.medium.copyWith(
                                  fontSize: 10, color: Colorz.hintTextColor)),
                        ),
                        SizedBox(
                          width: _kOiColW,
                          child: Text('Call LTP',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.medium.copyWith(
                                  fontSize: 10, color: Colorz.hintTextColor)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Strike header
        Container(
          width: _kStrikeW,
          alignment: Alignment.center,
          child: Text('STRIKE',
              style: AppTextStyles.semiBold.copyWith(
                  fontSize: 10, color: Colorz.hintTextColor)),
        ),
        // Put header
        Expanded(
          child: ValueListenableBuilder<double>(
            valueListenable: _hOff,
            builder: (_, off, __) => ClipRect(
              child: Transform.translate(
                offset: Offset(-off, 0),
                child: SizedBox(
                  width: _kOiSideW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _kOiColW,
                          child: Text('Put LTP',
                              textAlign: TextAlign.left,
                              style: AppTextStyles.medium.copyWith(
                                  fontSize: 10, color: Colorz.hintTextColor)),
                        ),
                        SizedBox(
                          width: _kOiColW,
                          child: Text('OI (in lakhs)',
                              textAlign: TextAlign.left,
                              style: AppTextStyles.medium.copyWith(
                                  fontSize: 10, color: Colorz.hintTextColor)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPane({
    required List<OptionStrike> strikes,
    required bool isCall,
    required double maxCallOi,
    required double maxPutOi,
  }) {
    return ListView.builder(
      controller: widget.vertCtrl,
      itemCount: strikes.length,
      itemBuilder: (ctx, i) {
        final st = strikes[i];
        final isAtm = widget.lastPrice > 0 &&
            (st.strike - widget.lastPrice).abs() <
                (i + 1 < strikes.length
                    ? (strikes[i + 1].strike - strikes[i].strike) / 2 + 1
                    : 50);

        if (isCall) {
          final oi = (st.ce?['oi'] as num?)?.toDouble() ?? 0;
          final prev = (st.ce?['previous_oi'] as num?)?.toDouble() ?? 0;
          final ltp = st.ce?['last_price'];
          final chPct = ((st.ce?['change_percentage'] as num?)?.toDouble());
          final oiPct = _oiChgPct(oi, prev);
          final callOiRatio = (oi / maxCallOi).clamp(0.0, 1.0);

          return Container(
            height: _kRowH,
            decoration: BoxDecoration(
              color: isAtm ? const Color(0xFFF0F4FF) : null,
              border: Border(
                  bottom:
                      BorderSide(color: Colorz.dividerColor, width: 0.5)),
            ),
            child: GestureDetector(
              onTap: () => widget.onTap(st.ce?['security_id']?.toString() ?? '', true),
              child: Stack(children: [
                // OI bar
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: FractionallySizedBox(
                    widthFactor: callOiRatio,
                    child: Container(
                      color: const Color(0xFFFF3737).withValues(alpha: 0.10),
                    ),
                  ),
                ),
                // Content
                ValueListenableBuilder<double>(
                  valueListenable: _hOff,
                  builder: (_, off, __) => ClipRect(
                    child: Transform.translate(
                      offset: Offset(-off, 0),
                      child: SizedBox(
                        width: _kOiSideW,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // OI
                              SizedBox(
                                width: _kOiColW,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(_oiLakhs(oi),
                                        style: AppTextStyles.semiBold
                                            .copyWith(
                                                fontSize:
                                                    SizeConfig.smallFont,
                                                color: Colorz.textColor)),
                                    if (oiPct != null)
                                      Text(_pct(oiPct),
                                          style: AppTextStyles.medium
                                              .copyWith(
                                                  fontSize: 10,
                                                  color: (oiPct >= 0)
                                                      ? Colorz.greenColor
                                                      : Colorz.redColor))
                                  ],
                                ),
                              ),
                              // LTP
                              SizedBox(
                                width: _kOiColW,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    _liveLtp(
                                        st.ce?['security_id']
                                                ?.toString() ??
                                            '',
                                        ltp != null
                                            ? (ltp as num)
                                                .toDouble()
                                                .toStringAsFixed(2)
                                            : '—',
                                        Colorz.greenColor),
                                    if (chPct != null)
                                      Text(_pct(chPct),
                                          style: AppTextStyles.medium
                                              .copyWith(
                                                  fontSize: 10,
                                                  color: (chPct >= 0)
                                                      ? Colorz.greenColor
                                                      : Colorz.redColor))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          );
        } else {
          final oi = (st.pe?['oi'] as num?)?.toDouble() ?? 0;
          final prev = (st.pe?['previous_oi'] as num?)?.toDouble() ?? 0;
          final ltp = st.pe?['last_price'];
          final chPct = ((st.pe?['change_percentage'] as num?)?.toDouble());
          final oiPct = _oiChgPct(oi, prev);
          final putOiRatio = (oi / maxPutOi).clamp(0.0, 1.0);

          return Container(
            height: _kRowH,
            decoration: BoxDecoration(
              color: isAtm ? const Color(0xFFF0F4FF) : null,
              border: Border(
                  bottom:
                      BorderSide(color: Colorz.dividerColor, width: 0.5)),
            ),
            child: GestureDetector(
              onTap: () => widget.onTap(st.pe?['security_id']?.toString() ?? '', false),
              child: Stack(children: [
                // OI bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: FractionallySizedBox(
                    widthFactor: putOiRatio,
                    child: Container(
                      color: const Color(0xFF3AAE00).withValues(alpha: 0.10),
                    ),
                  ),
                ),
                // Content
                ValueListenableBuilder<double>(
                  valueListenable: _hOff,
                  builder: (_, off, __) => ClipRect(
                    child: Transform.translate(
                      offset: Offset(-off, 0),
                      child: SizedBox(
                        width: _kOiSideW,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              // LTP
                              SizedBox(
                                width: _kOiColW,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    _liveLtp(
                                        st.pe?['security_id']
                                                ?.toString() ??
                                            '',
                                        ltp != null
                                            ? (ltp as num)
                                                .toDouble()
                                                .toStringAsFixed(2)
                                            : '—',
                                        Colorz.redColor),
                                    if (chPct != null)
                                      Text(_pct(chPct),
                                          style: AppTextStyles.medium
                                              .copyWith(
                                                  fontSize: 10,
                                                  color: (chPct >= 0)
                                                      ? Colorz.greenColor
                                                      : Colorz.redColor))
                                  ],
                                ),
                              ),
                              // OI
                              SizedBox(
                                width: _kOiColW,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(_oiLakhs(oi),
                                        style: AppTextStyles.semiBold
                                            .copyWith(
                                                fontSize:
                                                    SizeConfig.smallFont,
                                                color: Colorz.textColor)),
                                    if (oiPct != null)
                                      Text(_pct(oiPct),
                                          style: AppTextStyles.medium
                                              .copyWith(
                                                  fontSize: 10,
                                                  color: (oiPct >= 0)
                                                      ? Colorz.greenColor
                                                      : Colorz.redColor))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          );
        }
      },
    );
  }

  Widget _buildStrikePane(List<OptionStrike> strikes) {
    return ListView.builder(
      controller: widget.vertCtrl,
      itemCount: strikes.length,
      itemBuilder: (ctx, i) {
        final st = strikes[i];
        final isAtm = widget.lastPrice > 0 &&
            (st.strike - widget.lastPrice).abs() <
                (i + 1 < strikes.length
                    ? (strikes[i + 1].strike - strikes[i].strike) / 2 + 1
                    : 50);

        return Container(
          height: _kRowH,
          decoration: BoxDecoration(
            color: isAtm ? const Color(0xFFF0F4FF) : null,
            border: Border(
                bottom: BorderSide(color: Colorz.dividerColor, width: 0.5)),
          ),
          child: Center(
            child: isAtm
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2F3A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(st.strike.toStringAsFixed(0),
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colors.white,
                            fontSize: SizeConfig.smallFont)),
                  )
                : Text(st.strike.toStringAsFixed(0),
                    style: AppTextStyles.medium.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.smallFont)),
          ),
        );
      },
    );
  }

  Widget _liveLtp(String secId, String fallback, Color color) {
    return StreamBuilder<Map<String, double>>(
      stream: LivePriceService.instance.stream,
      initialData: LivePriceService.instance.prices,
      builder: (_, snap) {
        final live = secId.isNotEmpty ? (snap.data?[secId] ?? 0) : 0;
        final text = live > 0 ? live.toStringAsFixed(2) : fallback;
        return Text(text,
            style: AppTextStyles.semiBold.copyWith(
                fontSize: SizeConfig.smallFont, color: color));
      },
    );
  }
}

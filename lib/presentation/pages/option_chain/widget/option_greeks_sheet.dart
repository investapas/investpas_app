import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_bloc.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_event.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_state.dart';

class OptionGreeksSheet extends StatefulWidget {
  final List<OptionStrike> strikes;
  final double lastPrice;
  final String underlying;
  final String expiry;
  final double? selectedStrike;
  final bool isLoading;
  final String error;
  final VoidCallback onRefresh;

  const OptionGreeksSheet({
    super.key,
    required this.strikes,
    required this.lastPrice,
    required this.underlying,
    required this.expiry,
    this.selectedStrike,
    this.isLoading = false,
    this.error = '',
    required this.onRefresh,
  });

  static void show(
    BuildContext context, {
    required List<OptionStrike> strikes,
    required double lastPrice,
    required String underlying,
    required String expiry,
    double? selectedStrike,
    required bool isLoading,
    required String error,
    required VoidCallback onRefresh,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<StockDetailsBloc>(),
        child: OptionGreeksSheet(
          strikes: strikes,
          lastPrice: lastPrice,
          underlying: underlying,
          expiry: expiry,
          selectedStrike: selectedStrike,
          isLoading: isLoading,
          error: error,
          onRefresh: onRefresh,
        ),
      ),
    );
  }

  @override
  State<OptionGreeksSheet> createState() => _OptionGreeksSheetState();
}

enum _CpFilter { ce, pe, both }
enum _StrikeView { selected, all }

class _OptionGreeksSheetState extends State<OptionGreeksSheet> {
  _CpFilter _cpFilter = _CpFilter.both;
  _StrikeView _strikeView = _StrikeView.selected;
  bool _showDefinitions = false;

  String _formatExpiry(String expiry) {
    try {
      final date = DateTime.parse(expiry.split('T').first);
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return expiry.split('T').first;
    }
  }

  String _fmtDelta(dynamic v)  => v == null ? '—' : (v as num).toDouble().toStringAsFixed(4);
  String _fmtGamma(dynamic v)  => v == null ? '—' : (v as num).toDouble().toStringAsFixed(6);
  String _fmtThetaVega(dynamic v) => v == null ? '—' : (v as num).toDouble().toStringAsFixed(2);
  String _fmtIv(dynamic v)     => v == null ? '—' : '${(v as num).toDouble().toStringAsFixed(2)}%';
  String _fmtLtp(dynamic v)    {
    if (v == null) return '—';
    final n = (v as num).toDouble();
    return '₹${n.toStringAsFixed(2)}';
  }

  Map<String, dynamic>? _greeks(Map<String, dynamic>? side) => side?['greeks'] as Map<String, dynamic>?;

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockDetailsBloc, StockDetailsState>(
      listener: (ctx, state) {
        // Dismiss if state updates externally with no error (refresh completed)
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Colorz.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.sp)),
          ),
          child: Column(
            children: [
              // ── Handle bar
              Container(
                margin: EdgeInsets.only(top: 10.sp, bottom: 4.sp),
                width: 40.sp,
                height: 4.sp,
                decoration: BoxDecoration(
                  color: Colorz.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ── Header
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 2,
                    vertical: SizeConfig.spaceBetween),
                child: Row(
                  children: [
                    Text(
                      'Option Greeks',
                      style: AppTextStyles.semiBold.copyWith(
                          fontSize: SizeConfig.headerTwoFont,
                          color: Colorz.textColor),
                    ),
                    const Spacer(),
                    // Refresh button
                    BlocBuilder<StockDetailsBloc, StockDetailsState>(
                      builder: (ctx, state) {
                        if (state.isOptionChainLoading) {
                          return SizedBox(
                            width: 18.sp, height: 18.sp,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colorz.primary),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            ctx.read<StockDetailsBloc>().add(
                              LoadOptionChainEvent(
                                ctx.read<StockDetailsBloc>().state.selectedExpiry,
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig.spaceBetween * 0.7),
                            decoration: BoxDecoration(
                              color: Colorz.backgroundColor1,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh_rounded,
                                    color: Colorz.primary, size: 16.sp),
                                SizeConfig.horizontalSpace(
                                    width: SizeConfig.spaceBetween * 0.4),
                                Text('Refresh',
                                    style: AppTextStyles.medium.copyWith(
                                        fontSize: SizeConfig.smallFont,
                                        color: Colorz.primary)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Info strip: underlying | expiry | LTP
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 2),
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 1.5,
                    vertical: SizeConfig.spaceBetween),
                decoration: BoxDecoration(
                  color: Colorz.backgroundColor2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _infoChip('Underlying', widget.underlying),
                    _vDivider(),
                    _infoChip('Expiry', _formatExpiry(widget.expiry)),
                    _vDivider(),
                    _infoChip(
                      'LTP',
                      widget.lastPrice > 0
                          ? '₹${widget.lastPrice.toStringAsFixed(2)}'
                          : '—',
                      valueColor: Colorz.primary,
                    ),
                  ],
                ),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

              // ── CE / PE / Both toggle  +  Selected / All toggle
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween * 2),
                child: Row(
                  children: [
                    _pillGroup<_CpFilter>(
                      options: [
                        _PillOption('CE', _CpFilter.ce),
                        _PillOption('PE', _CpFilter.pe),
                        _PillOption('Both', _CpFilter.both),
                      ],
                      selected: _cpFilter,
                      onTap: (v) => setState(() => _cpFilter = v),
                    ),
                    const Spacer(),
                    _pillGroup<_StrikeView>(
                      options: [
                        _PillOption('Strike', _StrikeView.selected),
                        _PillOption('All', _StrikeView.all),
                      ],
                      selected: _strikeView,
                      onTap: (v) => setState(() => _strikeView = v),
                    ),
                  ],
                ),
              ),
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

              Divider(height: 1, color: Colorz.dividerColor),

              // ── Main content
              Expanded(
                child: BlocBuilder<StockDetailsBloc, StockDetailsState>(
                  builder: (ctx, state) {
                    final strikes =
                        state.optionStrikes.isNotEmpty ? state.optionStrikes : widget.strikes;
                    final lp = state.lastPrice > 0 ? state.lastPrice : widget.lastPrice;

                    if (state.isOptionChainLoading) return _buildLoading();
                    if (state.optionChainError.isNotEmpty) {
                      return _buildError(ctx, state.optionChainError);
                    }
                    if (strikes.isEmpty) return _buildEmpty();

                    return SingleChildScrollView(
                      controller: scrollCtrl,
                      padding: EdgeInsets.only(
                          top: SizeConfig.spaceBetween,
                          bottom: SizeConfig.spaceBetween * 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_strikeView == _StrikeView.selected)
                            _buildSelectedStrikeView(strikes, lp)
                          else
                            _buildAllStrikesView(strikes, lp),

                          SizeConfig.verticalSpace(
                              height: SizeConfig.spaceBetween * 2),
                          _buildDefinitions(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Selected-strike view ─────────────────────────────────────────────────────
  Widget _buildSelectedStrikeView(List<OptionStrike> strikes, double lp) {
    final atm = _computeAtm(strikes, lp);
    final target = widget.selectedStrike ?? atm;

    OptionStrike? data;
    try {
      data = strikes.firstWhere((s) => (s.strike - target).abs() < 0.01);
    } catch (_) {}

    final isAtm = data != null && (data.strike - atm).abs() < 0.01;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spaceBetween * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strike label
          Row(
            children: [
              Text(
                'Strike  ',
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor,
                    fontSize: SizeConfig.smallFont),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spaceBetween,
                    vertical: 3),
                decoration: BoxDecoration(
                  color: isAtm
                      ? const Color(0xFFFFF3CD)
                      : Colorz.backgroundColor1,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isAtm
                        ? const Color(0xFFFFD700)
                        : Colorz.dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data != null
                          ? _fmtStrike(data.strike)
                          : _fmtStrike(target),
                      style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.mediumFont),
                    ),
                    if (isAtm) ...[
                      SizeConfig.horizontalSpace(
                          width: SizeConfig.spaceBetween * 0.5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('ATM',
                            style: AppTextStyles.semiBold.copyWith(
                                color: const Color(0xFF7A5800),
                                fontSize: SizeConfig.smallerFont)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

          if (data == null)
            Center(
              child: Text(
                'No data for this strike',
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor),
              ),
            )
          else ...[
            if (_cpFilter != _CpFilter.pe)
              _buildSingleGreeksCard(
                label: 'Call (CE)',
                side: data.ce,
                accentColor: Colorz.greenColor,
                lightColor: const Color(0xFFEAFAE3),
              ),
            if (_cpFilter == _CpFilter.both)
              SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            if (_cpFilter != _CpFilter.ce)
              _buildSingleGreeksCard(
                label: 'Put (PE)',
                side: data.pe,
                accentColor: Colorz.redColor,
                lightColor: const Color(0xFFFFECEC),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleGreeksCard({
    required String label,
    required Map<String, dynamic>? side,
    required Color accentColor,
    required Color lightColor,
  }) {
    final g = _greeks(side);
    final hasData = g != null &&
        (g['delta'] != null ||
            g['gamma'] != null ||
            g['theta'] != null ||
            g['vega'] != null);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colorz.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.spaceBetween * 1.5,
                vertical: SizeConfig.spaceBetween),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: accentColor),
                ),
                SizeConfig.horizontalSpace(
                    width: SizeConfig.spaceBetween * 0.5),
                Text(label,
                    style: AppTextStyles.semiBold.copyWith(
                        color: accentColor,
                        fontSize: SizeConfig.smallFont)),
                const Spacer(),
                // LTP
                if (side?['last_price'] != null)
                  Text(
                    _fmtLtp(side!['last_price']),
                    style: AppTextStyles.semiBold.copyWith(
                        color: accentColor,
                        fontSize: SizeConfig.mediumFont),
                  ),
              ],
            ),
          ),

          if (!hasData)
            Padding(
              padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
              child: Text('No Greeks data available for this option',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallFont)),
            )
          else
            Padding(
              padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
              child: Column(
                children: [
                  // Row 1: Delta + Gamma
                  Row(
                    children: [
                      Expanded(
                          child: _greekTile('Delta', _fmtDelta(g['delta']),
                              'Change in premium per ₹1 move')),
                      SizeConfig.horizontalSpace(
                          width: SizeConfig.spaceBetween),
                      Expanded(
                          child: _greekTile('Gamma', _fmtGamma(g['gamma']),
                              'Rate of change of Delta')),
                    ],
                  ),
                  SizeConfig.verticalSpace(
                      height: SizeConfig.spaceBetween),
                  // Row 2: Theta + Vega
                  Row(
                    children: [
                      Expanded(
                          child: _greekTile('Theta', _fmtThetaVega(g['theta']),
                              'Time decay per day')),
                      SizeConfig.horizontalSpace(
                          width: SizeConfig.spaceBetween),
                      Expanded(
                          child: _greekTile('Vega', _fmtThetaVega(g['vega']),
                              'Sensitivity to IV change')),
                    ],
                  ),
                  SizeConfig.verticalSpace(
                      height: SizeConfig.spaceBetween),
                  // Row 3: IV
                  Row(
                    children: [
                      Expanded(
                          child: _greekTile(
                              'IV', _fmtIv(side?['implied_volatility']),
                              'Implied Volatility')),
                      SizeConfig.horizontalSpace(
                          width: SizeConfig.spaceBetween),
                      Expanded(child: Container()),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _greekTile(String name, String value, String hint) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.spaceBetween),
      decoration: BoxDecoration(
        color: Colorz.backgroundColor2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: AppTextStyles.semiBold.copyWith(
                  color: Colorz.hintTextColor,
                  fontSize: SizeConfig.smallFont)),
          SizeConfig.verticalSpace(height: 3),
          Text(
            value,
            style: AppTextStyles.semiBold.copyWith(
                color: value == '—' ? Colorz.hintTextColor : Colorz.textColor,
                fontSize: SizeConfig.largeFont),
          ),
        ],
      ),
    );
  }

  // ── All-strikes table ────────────────────────────────────────────────────────
  Widget _buildAllStrikesView(List<OptionStrike> strikes, double lp) {
    final atm = _computeAtm(strikes, lp);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spaceBetween * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Strikes — Greeks Summary',
            style: AppTextStyles.semiBold.copyWith(
                color: Colorz.textColor,
                fontSize: SizeConfig.mediumFont),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildGreeksTable(strikes, atm),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeksTable(List<OptionStrike> strikes, double atm) {
    // Build column headers based on filter
    final showCe = _cpFilter != _CpFilter.pe;
    final showPe = _cpFilter != _CpFilter.ce;

    List<String> headers = ['Strike'];
    if (showCe) headers.addAll(['CE LTP', 'CE IV', 'CE Δ', 'CE Γ', 'CE θ', 'CE ν']);
    if (showPe) headers.addAll(['PE LTP', 'PE IV', 'PE Δ', 'PE Γ', 'PE θ', 'PE ν']);

    return Table(
      defaultColumnWidth: IntrinsicColumnWidth(),
      border: TableBorder(
        horizontalInside: BorderSide(color: Colorz.dividerColor, width: 0.8),
        top: BorderSide(color: Colorz.dividerColor),
        bottom: BorderSide(color: Colorz.dividerColor),
      ),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: Colorz.backgroundColor1),
          children: headers
              .map((h) => _tableCell(h, isHeader: true))
              .toList(),
        ),
        // Data rows
        ...strikes.map((s) {
          final isAtmRow = (s.strike - atm).abs() < 0.01;
          final ceG = _greeks(s.ce);
          final peG = _greeks(s.pe);

          List<Widget> cells = [
            // Strike cell (always visible, ATM highlighted)
            _strikeCellWidget(s.strike, isAtmRow),
          ];

          if (showCe) {
            cells.addAll([
              _tableCell(_fmtLtp(s.ce?['last_price']), isAtm: isAtmRow),
              _tableCell(_fmtIv(s.ce?['implied_volatility']), isAtm: isAtmRow),
              _tableCell(_fmtDelta(ceG?['delta']), isAtm: isAtmRow, ceColor: true),
              _tableCell(_fmtGamma(ceG?['gamma']), isAtm: isAtmRow),
              _tableCell(_fmtThetaVega(ceG?['theta']), isAtm: isAtmRow),
              _tableCell(_fmtThetaVega(ceG?['vega']), isAtm: isAtmRow),
            ]);
          }
          if (showPe) {
            cells.addAll([
              _tableCell(_fmtLtp(s.pe?['last_price']), isAtm: isAtmRow),
              _tableCell(_fmtIv(s.pe?['implied_volatility']), isAtm: isAtmRow),
              _tableCell(_fmtDelta(peG?['delta']), isAtm: isAtmRow, peColor: true),
              _tableCell(_fmtGamma(peG?['gamma']), isAtm: isAtmRow),
              _tableCell(_fmtThetaVega(peG?['theta']), isAtm: isAtmRow),
              _tableCell(_fmtThetaVega(peG?['vega']), isAtm: isAtmRow),
            ]);
          }

          return TableRow(
            decoration: BoxDecoration(
              color: isAtmRow ? const Color(0xFFFFFBE6) : null,
            ),
            children: cells,
          );
        }),
      ],
    );
  }

  Widget _strikeCellWidget(double strike, bool isAtm) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spaceBetween,
          vertical: SizeConfig.spaceBetween * 0.8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _fmtStrike(strike),
            style: AppTextStyles.semiBold.copyWith(
              color: isAtm ? const Color(0xFF7A5800) : Colorz.textColor,
              fontSize: SizeConfig.smallFont,
            ),
          ),
          if (isAtm) ...[
            SizeConfig.horizontalSpace(
                width: SizeConfig.spaceBetween * 0.4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('ATM',
                  style: AppTextStyles.semiBold.copyWith(
                      color: const Color(0xFF7A5800),
                      fontSize: 8.sp)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tableCell(
    String value, {
    bool isHeader = false,
    bool isAtm = false,
    bool ceColor = false,
    bool peColor = false,
  }) {
    Color textColor = Colorz.hintTextColor;
    if (isHeader) textColor = Colorz.hintTextColor;
    else if (value == '—') textColor = Colorz.hintTextColor;
    else if (ceColor) textColor = Colorz.greenColor;
    else if (peColor) textColor = Colorz.redColor;
    else textColor = Colorz.textColor;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spaceBetween,
          vertical: SizeConfig.spaceBetween * 0.8),
      child: Text(
        value,
        style: isHeader
            ? AppTextStyles.semiBold.copyWith(
                color: Colorz.hintTextColor,
                fontSize: SizeConfig.smallFont)
            : AppTextStyles.medium.copyWith(
                color: textColor,
                fontSize: SizeConfig.smallFont),
        textAlign: isHeader ? TextAlign.center : TextAlign.right,
      ),
    );
  }

  // ── Greeks definitions ───────────────────────────────────────────────────────
  Widget _buildDefinitions() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spaceBetween * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showDefinitions = !_showDefinitions),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colorz.primary, size: 16.sp),
                SizeConfig.horizontalSpace(
                    width: SizeConfig.spaceBetween * 0.5),
                Text('What are Greeks?',
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.primary,
                        fontSize: SizeConfig.smallFont)),
                const Spacer(),
                Icon(
                  _showDefinitions
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colorz.primary,
                  size: 18.sp,
                ),
              ],
            ),
          ),
          if (_showDefinitions) ...[
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            Container(
              padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
              decoration: BoxDecoration(
                color: Colorz.backgroundColor2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colorz.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _defRow('Δ Delta',
                      'Change in option premium for a ₹1 change in the underlying. CE delta is positive (0 to 1); PE delta is negative (-1 to 0).'),
                  Divider(color: Colorz.dividerColor, height: 20),
                  _defRow('Γ Gamma',
                      'Rate of change of Delta when the underlying moves ₹1. Highest near ATM; approaches 0 deep ITM or OTM.'),
                  Divider(color: Colorz.dividerColor, height: 20),
                  _defRow('θ Theta',
                      'Approximate time decay of the option per day. Almost always negative — options lose value as expiry nears.'),
                  Divider(color: Colorz.dividerColor, height: 20),
                  _defRow('ν Vega',
                      'Sensitivity of the option premium to a 1% change in implied volatility. Higher for longer-dated options.'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _defRow(String name, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64.sp,
          child: Text(name,
              style: AppTextStyles.semiBold.copyWith(
                  color: Colorz.primary,
                  fontSize: SizeConfig.smallFont)),
        ),
        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
        Expanded(
          child: Text(desc,
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor,
                  fontSize: SizeConfig.smallFont)),
        ),
      ],
    );
  }

  // ── Loading / Error / Empty ──────────────────────────────────────────────────
  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colorz.primary, strokeWidth: 2.5),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
          Text('Loading market data…',
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor,
                  fontSize: SizeConfig.smallFont)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext ctx, String msg) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colorz.redColor, size: 36.sp),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          Text(
            'Unable to load Option Greeks.\n$msg',
            style: AppTextStyles.medium
                .copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont),
            textAlign: TextAlign.center,
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
          OutlinedButton.icon(
            onPressed: () {
              ctx.read<StockDetailsBloc>().add(
                LoadOptionChainEvent(
                    ctx.read<StockDetailsBloc>().state.selectedExpiry),
              );
            },
            icon: Icon(Icons.refresh_rounded, size: 16.sp),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colorz.primary,
              side: BorderSide(color: Colorz.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded,
              color: Colorz.hintTextColor, size: 36.sp),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
          Text('No Greeks data available.',
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor,
                  fontSize: SizeConfig.smallFont)),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  double _computeAtm(List<OptionStrike> strikes, double lp) {
    if (strikes.isEmpty) return 0;
    if (lp <= 0) return strikes[strikes.length ~/ 2].strike;
    double minDiff = double.maxFinite;
    double atm = strikes.first.strike;
    for (final s in strikes) {
      final diff = (s.strike - lp).abs();
      if (diff < minDiff) {
        minDiff = diff;
        atm = s.strike;
      }
    }
    return atm;
  }

  String _fmtStrike(double v) {
    if (v == v.toInt()) {
      final n = v.toInt();
      if (n >= 1000) {
        final s = n.toString();
        final buf = StringBuffer();
        final len = s.length;
        final rem = len % 3 == 0 ? 3 : len % 3;
        buf.write(s.substring(0, rem));
        for (int i = rem; i < len; i += 3) {
          buf.write(',');
          buf.write(s.substring(i, i + 3));
        }
        return buf.toString();
      }
      return n.toString();
    }
    return v.toStringAsFixed(2);
  }

  Widget _infoChip(String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor,
                  fontSize: SizeConfig.smallerFont)),
          SizeConfig.verticalSpace(height: 2),
          Text(value,
              style: AppTextStyles.semiBold.copyWith(
                  color: valueColor ?? Colorz.textColor,
                  fontSize: SizeConfig.smallFont),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 36,
        color: Colorz.dividerColor,
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween),
      );

  Widget _pillGroup<T>({
    required List<_PillOption<T>> options,
    required T selected,
    required void Function(T) onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colorz.backgroundColor2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colorz.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isActive = opt.value == selected;
          return GestureDetector(
            onTap: () => onTap(opt.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.spaceBetween,
                  vertical: SizeConfig.spaceBetween * 0.5),
              decoration: BoxDecoration(
                color: isActive ? Colorz.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opt.label,
                style: AppTextStyles.semiBold.copyWith(
                  color: isActive ? Colorz.white : Colorz.hintTextColor,
                  fontSize: SizeConfig.smallFont,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PillOption<T> {
  final String label;
  final T value;
  const _PillOption(this.label, this.value);
}

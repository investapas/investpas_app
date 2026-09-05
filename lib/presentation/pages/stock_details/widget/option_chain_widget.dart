import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/core/constants/constants.dart';
import '../../../../Widgets/live_price_widget.dart';
import '../../../../data/services/live_price_service.dart';
import '../../../bloc/stock_details/stock_details_bloc.dart';
import '../../../bloc/stock_details/stock_details_event.dart';
import '../../../bloc/stock_details/stock_details_state.dart';

class OptionChainWidget extends StatefulWidget {
  const OptionChainWidget({super.key});

  @override
  State<OptionChainWidget> createState() => _OptionChainWidgetState();
}

class _OptionChainWidgetState extends State<OptionChainWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = context.read<StockDetailsBloc>().state;
      // Only fetch expiry dates if not already loaded — prevents duplicate Dhan calls
      if (s.availableExpiries.isEmpty) {
        context.read<StockDetailsBloc>().add(LoadExpiryDatesEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockDetailsBloc, StockDetailsState>(
      builder: (context, state) {

        // ── Expiry selector header ──────────────────────────────────────
        return Column(
          children: [
            // LTP + expiry dropdown row
            Container(
              margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
              child: Row(
                children: [
                  // LTP live price
                  if (state.securityId.isNotEmpty) ...[
                    Text('LTP  ',
                        style: AppTextStyles.medium
                            .copyWith(color: Colorz.hintTextColor)),
                    LivePriceWidget(
                      securityId: state.securityId,
                      style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.primary,
                        fontSize: SizeConfig.headerThreeFont,
                      ),
                    ),
                  ],
                  const Spacer(),

                  // Expiry dropdown — shows all unique sm_expiry_date from DB
                  if (state.availableExpiries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colorz.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colorz.primary.withValues(alpha: 0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.availableExpiries
                                  .contains(state.selectedExpiry)
                              ? state.selectedExpiry
                              : state.availableExpiries.first,
                          isDense: true,
                          icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colorz.primary,
                              size: 18),
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.primary,
                              fontSize: SizeConfig.smallFont),
                          dropdownColor: Colorz.white,
                          borderRadius: BorderRadius.circular(12),
                          items: state.availableExpiries.map((expiry) {
                            return DropdownMenuItem<String>(
                              value: expiry,
                              child: Text(
                                _formatExpiry(expiry),
                                style: AppTextStyles.medium.copyWith(
                                    color: Colorz.textColor,
                                    fontSize: SizeConfig.smallFont),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<StockDetailsBloc>().add(
                                    ChangeOptionExpiryEvent(value),
                                  );
                            }
                          },
                        ),
                      ),
                    )
                  else if (state.isOptionChainLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colorz.primary),
                    ),
                ],
              ),
            ),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

            // ── Column headers ────────────────────────────────────────────
            Container(
              color: Colorz.bottomPillBg,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('CE', style: AppTextStyles.semiBold.copyWith(color: Colorz.greenColor, fontSize: SizeConfig.smallFont), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('Strike', style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor, fontSize: SizeConfig.smallFont), textAlign: TextAlign.center)),
                  Expanded(flex: 3, child: Text('PE', style: AppTextStyles.semiBold.copyWith(color: Colorz.redColor, fontSize: SizeConfig.smallFont), textAlign: TextAlign.center)),
                ],
              ),
            ),
            Container(
              color: Colorz.bottomPillBg,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('LTP', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('OI', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('Vol', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('Strike', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('LTP', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('OI', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('Vol', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                ],
              ),
            ),
            Divider(color: Colorz.dividerColor, height: 1),

            // ── Loading / empty / list ────────────────────────────────────
            if (state.isOptionChainLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: Colorz.primary)))
            else if (state.optionChainError.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.optionChainError, style: AppTextStyles.medium.copyWith(color: Colorz.redColor), textAlign: TextAlign.center),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                      ElevatedButton(
                        onPressed: () => context.read<StockDetailsBloc>().add(LoadOptionChainEvent(state.selectedExpiry)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colorz.primary),
                        child: Text('Retry', style: AppTextStyles.medium.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else if (state.optionStrikes.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Select expiry to load option chain', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor)),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                      ElevatedButton(
                        onPressed: () => _pickExpiry(context, state),
                        style: ElevatedButton.styleFrom(backgroundColor: Colorz.primary),
                        child: Text('Pick Expiry', style: AppTextStyles.medium.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: state.optionStrikes.length,
                  separatorBuilder: (_, __) => Divider(color: Colorz.dividerColor, height: 1),
                  itemBuilder: (context, i) {
                    final s     = state.optionStrikes[i];
                    final isAtm = state.lastPrice > 0 &&
                        (s.strike - state.lastPrice).abs() < 200;
                    final ceId  = s.ce?['security_id']?.toString() ?? '';
                    final peId  = s.pe?['security_id']?.toString() ?? '';
                    final ceOi  = _fmtOI(s.ce?['oi'] as int?);
                    final ceVol = _fmtOI(s.ce?['volume'] as int?);
                    final peOi  = _fmtOI(s.pe?['oi'] as int?);
                    final peVol = _fmtOI(s.pe?['volume'] as int?);
                    // Fallback to API last_price when live price not yet received
                    final ceFallback = (s.ce?['last_price'] as num?)?.toDouble() ?? 0;
                    final peFallback = (s.pe?['last_price'] as num?)?.toDouble() ?? 0;

                    return Container(
                      color: isAtm ? Colorz.primary.withValues(alpha: 0.06) : null,
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2, vertical: 8),
                      child: Row(
                        children: [
                          // CE LTP — live price with fallback
                          Expanded(
                            flex: 1,
                            child: ceId.isNotEmpty
                                ? _OptionPrice(securityId: ceId, fallbackPrice: ceFallback, color: Colorz.greenColor)
                                : Text(ceFallback > 0 ? ceFallback.toStringAsFixed(2) : '—',
                                    style: AppTextStyles.medium.copyWith(color: Colorz.greenColor, fontSize: SizeConfig.smallerFont),
                                    textAlign: TextAlign.center),
                          ),
                          Expanded(flex: 1, child: Text(ceOi, style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                          Expanded(flex: 1, child: Text(ceVol, style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                          // Strike
                          Expanded(
                            flex: 2,
                            child: Text(
                              s.strike.toStringAsFixed(0),
                              style: AppTextStyles.semiBold.copyWith(
                                color: isAtm ? Colorz.primary : Colorz.textColor,
                                fontSize: SizeConfig.smallFont,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // PE LTP — live price with fallback
                          Expanded(
                            flex: 1,
                            child: peId.isNotEmpty
                                ? _OptionPrice(securityId: peId, fallbackPrice: peFallback, color: Colorz.redColor)
                                : Text(peFallback > 0 ? peFallback.toStringAsFixed(2) : '—',
                                    style: AppTextStyles.medium.copyWith(color: Colorz.redColor, fontSize: SizeConfig.smallerFont),
                                    textAlign: TextAlign.center),
                          ),
                          Expanded(flex: 1, child: Text(peOi, style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                          Expanded(flex: 1, child: Text(peVol, style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont), textAlign: TextAlign.center)),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  String _fmtOI(int? v) {
    if (v == null) return '—';
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  // ignore: unused_element
  void _pickExpiry(BuildContext context, StockDetailsState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(primary: Colorz.primary, surface: const Color(0xFF1E1E2E)),
        ),
        child: child!,
      ),
    );
    if (picked != null && context.mounted) {
      final expiry = '${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
      context.read<StockDetailsBloc>().add(ChangeOptionExpiryEvent(expiry));
    }
  }
}

String _formatExpiry(String expiry) {

  try {

    final date = DateTime.parse(expiry);

    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];

    return '${date.day} ${months[date.month - 1]}';

  } catch (e) {

    return expiry;

  }
}

// ── Live price for a single option (CE or PE) ─────────────────────────────────
// Shows live price from WebSocket; falls back to API last_price
class _OptionPrice extends StatelessWidget {
  final String securityId;
  final double fallbackPrice;
  final Color color;

  const _OptionPrice({
    required this.securityId,
    required this.fallbackPrice,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: LivePriceService.instance.stream,
      initialData: LivePriceService.instance.prices,
      builder: (context, snapshot) {
        final prices = snapshot.data ?? {};
        final live   = prices[securityId];
        final ltp    = (live != null && live > 0) ? live : (fallbackPrice > 0 ? fallbackPrice : null);

        return Text(
          ltp != null ? ltp.toStringAsFixed(2) : '—',
          style: AppTextStyles.medium.copyWith(color: color, fontSize: SizeConfig.smallerFont),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

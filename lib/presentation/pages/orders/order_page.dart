import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widgets/Widgets.dart';
import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/demo_mode_service.dart';
import '../../../core/services/unified_trading_service.dart';
import '../../../core/utils/app_dialog.dart';
import '../../../core/utils/navigationService.dart';

class OrderPage extends StatefulWidget {
  final VoidCallback? onBack;
  const OrderPage({super.key, this.onBack});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

enum _OrderTab { open, executed }

class _OrderPageState extends State<OrderPage> {
  _OrderTab _activeTab = _OrderTab.open;
  bool _isLoading = true;
  String _error = '';
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _error = ''; });
    final status = _activeTab == _OrderTab.open ? 'OPEN' : 'EXECUTED';
    final orders = await UnifiedTradingService.getOrders(status: status, forceReal: true);
    setState(() { _orders = orders; _isLoading = false; });
  }

  void _changeTab(_OrderTab tab) {
    if (tab == _activeTab) return;
    setState(() => _activeTab = tab);
    _loadOrders();
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDetailsSheet(order: order, onOrderUpdated: _loadOrders),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDemoActive = DemoModeService.instance.isActive;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(top: 50.sp, bottom: 24.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                  child: InkWell(
                    onTap: () => widget.onBack != null
                        ? widget.onBack!()
                        : NavigatorService.goBack(),
                    child: CircleWidget(
                      backgroundColor: Colorz.white,
                      child: Icon(Icons.arrow_back_rounded, color: Colorz.hintTextColor2),
                    ),
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

                // Title row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Orders',
                            style: AppTextStyles.semiBold.copyWith(
                                fontSize: SizeConfig.headerTwoFont,
                                color: Colorz.textColor)),
                      ),
                      if (_isLoading && _orders.isNotEmpty)
                        const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colorz.primary, strokeWidth: 2),
                        ),
                    ],
                  ),
                ),

                // Demo banner
                if (isDemoActive) ...[
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.75),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                    child: GestureDetector(
                      onTap: () => NavigatorService.pushNamed('/demoPage'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colorz.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colorz.primary.withValues(alpha: 0.25)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: Colorz.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo mode ON — these are your Dhan live orders. Tap to view demo orders.',
                              style: AppTextStyles.medium.copyWith(
                                  color: Colorz.primary,
                                  fontSize: SizeConfig.smallFont),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 12, color: Colorz.primary),
                        ]),
                      ),
                    ),
                  ),
                ],

                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

                // Tab switcher
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                  child: _buildTabs(),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

                // Body
                Expanded(
                  child: _isLoading && _orders.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Colorz.primary))
                      : _error.isNotEmpty
                          ? _buildErrorState()
                          : _orders.isEmpty
                              ? _buildEmptyState()
                              : _buildOrderList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colorz.bottomPillBg,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(children: [
        _buildTab(_OrderTab.open, 'Open'),
        _buildTab(_OrderTab.executed, 'Executed'),
      ]),
    );
  }

  Widget _buildTab(_OrderTab tab, String label) {
    final active = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeTab(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: active ? Colorz.primaryButtonGradient : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: active ? [
              BoxShadow(color: Colorz.primary.withValues(alpha: 0.25),
                  blurRadius: 8, offset: const Offset(0, 2))
            ] : [],
          ),
          child: Center(
            child: Text(label,
                style: AppTextStyles.semiBold.copyWith(
                  fontSize: SizeConfig.mediumFont,
                  color: active ? Colors.white : Colorz.hintTextColor,
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      color: Colorz.primary,
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.spaceBetween * 2,
            vertical: SizeConfig.spaceBetween * 0.5),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _showOrderDetails(order),
              child: _OrderCard(order: order),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colorz.backgroundColor2,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 34, color: Colorz.primary),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),
          Text(
            _activeTab == _OrderTab.open ? 'No open orders' : 'No executed orders',
            style: AppTextStyles.semiBold.copyWith(
                fontSize: SizeConfig.headerThreeFont, color: Colorz.textColor),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 4),
            child: Text(
              _activeTab == _OrderTab.open
                  ? 'Your pending and active orders will appear here.'
                  : 'Your completed and cancelled orders will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium.copyWith(
                  color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colorz.hintTextColor),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            Text(_error,
                style: AppTextStyles.medium.copyWith(color: Colorz.redColor),
                textAlign: TextAlign.center),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
            Button(text: 'Retry', buttonColor: Colorz.primary,
                textColor: Colors.white, onPressed: _loadOrders),
          ],
        ),
      ),
    );
  }
}

// ── Order Card ─────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  bool get _isBuy => order.transactionType == 'BUY';

  Color get _statusColor {
    switch (order.status.toUpperCase()) {
      case 'TRADED':
      case 'EXECUTED': return Colorz.greenColor;
      case 'CANCELLED':
      case 'REJECTED':  return Colorz.redColor;
      default:          return const Color(0xFFFFA726);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // BUY / SELL gradient badge
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: _isBuy ? Colorz.primaryButtonGradient : Colorz.sellButtonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _isBuy ? 'B' : 'S',
                style: AppTextStyles.semiBold.copyWith(
                    color: Colors.white, fontSize: SizeConfig.largeFont),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Symbol + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.tradingSymbol,
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.mediumFont),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  _chip(order.orderType, Colorz.primary),
                  const SizedBox(width: 6),
                  _chip(order.transactionType,
                      _isBuy ? Colorz.greenColor : Colorz.sellButtonColor),
                ]),
              ],
            ),
          ),

          // Qty + price + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Qty ${order.quantity}',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.smallFont)),
              const SizedBox(height: 4),
              Text(
                order.price > 0
                    ? '₹${order.price.toStringAsFixed(2)}'
                    : 'Market',
                style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor,
                    fontSize: SizeConfig.smallFont),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(order.status,
                    style: AppTextStyles.semiBold.copyWith(
                        color: _statusColor,
                        fontSize: SizeConfig.smallerFont)),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded,
              color: Colorz.hintTextColor, size: 18),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: AppTextStyles.medium.copyWith(
                color: color, fontSize: SizeConfig.smallerFont)),
      );
}

// ── Order Details & Modify Sheet ───────────────────────────────────────────────
class OrderDetailsSheet extends StatefulWidget {
  final Order order;
  final VoidCallback onOrderUpdated;
  const OrderDetailsSheet({required this.order, required this.onOrderUpdated, super.key});

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  late Order _order;
  late TextEditingController _priceCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _targetCtrl;
  late TextEditingController _slCtrl;
  late TextEditingController _trailingJumpCtrl;
  late String _orderType; // MARKET or LIMIT
  bool _isLoading = false;

  bool get _isBuy => _order.transactionType == 'BUY';
  bool get _isSuperOrder => _order.targetPrice != null || _order.stopLossPrice != null;
  bool get _canModify {
    final s = _order.status.toUpperCase();
    return s != 'TRADED' && s != 'EXECUTED' && s != 'CANCELLED' && s != 'REJECTED';
  }

  Color get _accentColor => _isBuy ? Colorz.primary : Colorz.sellButtonColor;
  LinearGradient get _gradient =>
      _isBuy ? Colorz.primaryButtonGradient : Colorz.sellButtonGradient;

  Color get _statusColor {
    switch (_order.status.toUpperCase()) {
      case 'TRADED':
      case 'EXECUTED': return Colorz.greenColor;
      case 'CANCELLED':
      case 'REJECTED':  return Colorz.redColor;
      default:          return const Color(0xFFFFA726);
    }
  }

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _priceCtrl   = TextEditingController(text: _order.price > 0 ? _order.price.toString() : '');
    _qtyCtrl     = TextEditingController(text: _order.quantity.toString());
    _targetCtrl  = TextEditingController(text: _order.targetPrice?.toString() ?? '');
    _slCtrl      = TextEditingController(text: _order.stopLossPrice?.toString() ?? '');
    _trailingJumpCtrl = TextEditingController(text: _order.trailingJump != null && _order.trailingJump! > 0 ? _order.trailingJump.toString() : '');
    _orderType   = _order.orderType.toUpperCase() == 'MARKET' ? 'MARKET' : 'LIMIT';
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _targetCtrl.dispose();
    _slCtrl.dispose();
    _trailingJumpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colorz.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // ── Header banner ─────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _isBuy ? 'B' : 'S',
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colors.white, fontSize: SizeConfig.headerThreeFont),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Symbol + type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_order.tradingSymbol,
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colors.white,
                            fontSize: SizeConfig.headerThreeFont),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${_order.orderType}  •  ${_order.transactionType}',
                        style: AppTextStyles.medium.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: SizeConfig.smallFont)),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_order.status,
                    style: AppTextStyles.semiBold.copyWith(
                        color: Colors.white, fontSize: SizeConfig.smallFont)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Info tiles ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Info',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.mediumFont)),
              const SizedBox(height: 12),
              _InfoGrid(order: _order),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Modify section (only for open orders) ─────────────────────────
        if (_canModify) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  gradient: _gradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('Modify Order',
                  style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.mediumFont)),
            ]),
          ),
          const SizedBox(height: 14),

          // Order type toggle (Market / Limit) — regular orders only.
          // Super orders keep their entry leg as LIMIT.
          if (!_isSuperOrder) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildOrderTypeToggle(),
            ),
            const SizedBox(height: 12),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: _ModifyField(
                label: 'Quantity',
                controller: _qtyCtrl,
                icon: Icons.numbers_rounded,
                isDecimal: false,
                isBuy: _isBuy,
              )),
              if (_isSuperOrder || _orderType == 'LIMIT') ...[
                const SizedBox(width: 12),
                Expanded(child: _ModifyField(
                  label: 'Price',
                  controller: _priceCtrl,
                  icon: Icons.currency_rupee_rounded,
                  isDecimal: true,
                  isBuy: _isBuy,
                )),
              ],
            ]),
          ),
          if (_isSuperOrder) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(child: _ModifyField(
                  label: 'Target ₹',
                  controller: _targetCtrl,
                  icon: Icons.trending_up_rounded,
                  isDecimal: true,
                  isBuy: _isBuy,
                )),
                const SizedBox(width: 12),
                Expanded(child: _ModifyField(
                  label: 'Stop Loss ₹',
                  controller: _slCtrl,
                  icon: Icons.trending_down_rounded,
                  isDecimal: true,
                  isBuy: _isBuy,
                )),
              ]),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ModifyField(
                label: 'Trailing Jump',
                controller: _trailingJumpCtrl,
                icon: Icons.swap_vert_rounded,
                isDecimal: true,
                isBuy: _isBuy,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Update button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : _gradient,
                  color: _isLoading
                      ? Colorz.hintTextColor.withValues(alpha: 0.2)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isLoading ? [] : [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _modifyOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('Update Order',
                                style: AppTextStyles.semiBold.copyWith(
                                    color: Colors.white,
                                    fontSize: SizeConfig.mediumFont)),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel order button (outlined)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _confirmCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colorz.redColor, width: 1.5),
                  foregroundColor: Colorz.redColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.close_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('Cancel Order',
                        style: AppTextStyles.semiBold.copyWith(
                            color: Colorz.redColor,
                            fontSize: SizeConfig.mediumFont)),
                  ],
                ),
              ),
            ),
          ),
        ],

        // Closed order notice
        if (!_canModify)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor.withValues(alpha: 0.25)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, color: _statusColor, size: 16),
                const SizedBox(width: 8),
                Text('This order cannot be modified (${_order.status})',
                    style: AppTextStyles.medium.copyWith(
                        color: _statusColor, fontSize: SizeConfig.smallFont)),
              ]),
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOrderTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Type',
            style: AppTextStyles.medium.copyWith(
                color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: _orderTypeOption('MARKET', 'Market')),
          const SizedBox(width: 12),
          Expanded(child: _orderTypeOption('LIMIT', 'Limit')),
        ]),
      ],
    );
  }

  Widget _orderTypeOption(String value, String label) {
    final selected = _orderType == value;
    final accent = _accentColor;
    return InkWell(
      onTap: () => setState(() => _orderType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accent : Colorz.backgroundColor2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? accent : Colorz.textFieldBorderColor,
              width: 1.5),
        ),
        child: Center(
          child: Text(label,
              style: AppTextStyles.semiBold.copyWith(
                  fontSize: SizeConfig.mediumFont,
                  color: selected ? Colors.white : Colorz.textColor)),
        ),
      ),
    );
  }

  Future<void> _modifyOrder() async {
    final quantity = int.tryParse(_qtyCtrl.text) ?? _order.quantity;
    final price    = double.tryParse(_priceCtrl.text) ?? _order.price;
    setState(() => _isLoading = true);

    final result = _isSuperOrder
        ? await UnifiedTradingService.modifyDhanSuperOrder(
            orderId: _order.orderId,
            orderType: 'LIMIT',
            quantity: quantity,
            price: price,
            targetPrice: double.tryParse(_targetCtrl.text) ?? (_order.targetPrice ?? 0),
            stopLossPrice: double.tryParse(_slCtrl.text) ?? (_order.stopLossPrice ?? 0),
            trailingJump: double.tryParse(_trailingJumpCtrl.text) ?? (_order.trailingJump ?? 0),
            legName: _order.legName ?? 'ENTRY_LEG',
          )
        : await UnifiedTradingService.modifyDhanOrder(
            orderId: _order.orderId,
            orderType: _orderType,
            quantity: quantity,
            price: _orderType == 'LIMIT' ? price : 0,
            disclosedQuantity: _order.disclosedQuantity,
            triggerPrice: _order.triggerPrice,
            validity: _order.validity,
            legName: _order.legName ?? 'ENTRY_LEG',
          );

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.status) {
      AppSnackBar.showSuccess(context,
          result.message.isNotEmpty ? result.message : 'Order updated');
      widget.onOrderUpdated();
      Navigator.pop(context);
    } else {
      AppSnackBar.showError(context,
          result.message.isNotEmpty ? result.message : 'Unable to update order');
    }
  }

  void _confirmCancel() {
    AppDialog.showConfirm(context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order?',
      confirmText: 'Yes, Cancel',
      cancelText: 'Go Back',
    ).then((confirmed) { if (confirmed == true) _cancelOrder(); });
  }

  Future<void> _cancelOrder() async {
    setState(() => _isLoading = true);
    final result = await UnifiedTradingService.cancelOrder(orderId: _order.orderId);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result) {
      AppSnackBar.showSuccess(context, 'Order cancelled');
      widget.onOrderUpdated();
      Navigator.pop(context);
    } else {
      AppSnackBar.showError(context, 'Unable to cancel order');
    }
  }
}

// ── Info grid ──────────────────────────────────────────────────────────────────
class _InfoGrid extends StatelessWidget {
  final Order order;
  const _InfoGrid({required this.order});

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem('Order ID', order.orderId, Icons.tag_rounded),
      _InfoItem('Quantity', order.quantity.toString(), Icons.numbers_rounded),
      _InfoItem(
        'Price',
        order.price > 0 ? '₹${order.price.toStringAsFixed(2)}' : 'Market',
        Icons.currency_rupee_rounded,
      ),
      _InfoItem(
        'Date',
        _formatDate(order.createdAt),
        Icons.calendar_today_rounded,
      ),
      if (order.targetPrice != null)
        _InfoItem('Target', '₹${order.targetPrice!.toStringAsFixed(2)}',
            Icons.trending_up_rounded),
      if (order.stopLossPrice != null)
        _InfoItem('Stop Loss', '₹${order.stopLossPrice!.toStringAsFixed(2)}',
            Icons.trending_down_rounded),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) => _buildTile(item)).toList(),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}/${local.month}/${local.year}  ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTile(_InfoItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final tileWidth = (screenWidth - 32 - 10) / 2;
        return SizedBox(
          width: tileWidth,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colorz.backgroundColor2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colorz.dividerColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colorz.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: Colorz.primary, size: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label,
                          style: AppTextStyles.medium.copyWith(
                              color: Colorz.hintTextColor,
                              fontSize: SizeConfig.smallerFont)),
                      const SizedBox(height: 2),
                      Text(item.value,
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.textColor,
                              fontSize: SizeConfig.smallFont),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  const _InfoItem(this.label, this.value, this.icon);
}

// ── Modify input field ─────────────────────────────────────────────────────────
class _ModifyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isDecimal;
  final bool isBuy;

  const _ModifyField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.isDecimal,
    required this.isBuy,
  });

  Color get _accent => isBuy ? Colorz.primary : Colorz.sellButtonColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.medium.copyWith(
                color: Colorz.hintTextColor,
                fontSize: SizeConfig.smallFont)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colorz.backgroundColor2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colorz.textFieldBorderColor, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            inputFormatters: [
              isDecimal
                  ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            style: AppTextStyles.semiBold.copyWith(
                color: Colorz.textColor, fontSize: SizeConfig.mediumFont),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Icon(icon, color: _accent, size: 16),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
          ),
        ),
      ],
    );
  }
}

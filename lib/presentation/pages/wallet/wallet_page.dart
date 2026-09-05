import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/app_dialog.dart';
import '../../../core/utils/navigationService.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final List<Map<String, dynamic>> _packs = [
    {'coins': 100,  'price': 100,  'label': '100 Coins',  'popular': false},
    {'coins': 250,  'price': 250,  'label': '250 Coins',  'popular': false},
    {'coins': 500,  'price': 500,  'label': '500 Coins',  'popular': true},
    {'coins': 1000, 'price': 1000, 'label': '1000 Coins', 'popular': false},
  ];

  List<dynamic> _transactions = [];
  bool _txLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadWalletBalance());
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final resp = await ApiHelper.get(ApiEndpoints.walletTransactionsApi);
      if (mounted && resp != null && resp['status'] == true) {
        setState(() {
          _transactions = resp['data'] ?? [];
          _txLoading = false;
        });
      } else {
        if (mounted) setState(() => _txLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _txLoading = false);
    }
  }

  Future<void> _purchase(int coins, int price) async {
    final bloc = context.read<WalletBloc>();
    final confirmed = await AppDialog.showConfirm(
      context,
      title: 'Buy $coins Coins',
      message: 'You are about to purchase $coins coins for ₹$price.\nCoins can be used for Instant Quick Unlock.',
      confirmText: 'Buy ₹$price',
      cancelText: 'Cancel',
      isDestructive: false,
    );
    if (!confirmed) return;

    bloc.add(AddCoins(coins));
    await Future.delayed(const Duration(milliseconds: 800));
    _loadTransactions();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final d = DateTime.parse(dateStr).toLocal();
      return '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false,
          child: BlocBuilder<WalletBloc, WalletState>(
            builder: (context, wState) {
              return Column(
                children: [
                  SizedBox(height: 50.sp),

                  // ── Header ────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: NavigatorService.goBack,
                          child: CircleWidget(
                            backgroundColor: Colorz.white,
                            child: Icon(Icons.arrow_back_rounded, color: Colorz.hintTextColor2),
                          ),
                        ),
                        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                        Text('My Wallet',
                            style: AppTextStyles.semiBold.copyWith(
                                fontSize: SizeConfig.headerTwoFont, color: Colorz.textColor)),
                      ],
                    ),
                  ),
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Balance card ──────────────────────────────
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(SizeConfig.spaceBetween * 2.5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colorz.primary, Colorz.primary.withValues(alpha: 0.75)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.toll_rounded, color: Colors.amber, size: 22),
                                    SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                                    Text('Coin Balance',
                                        style: AppTextStyles.medium.copyWith(
                                            color: Colors.white70, fontSize: SizeConfig.smallFont)),
                                  ],
                                ),
                                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                                wState.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    : Text(
                                        '${wState.balance}',
                                        style: AppTextStyles.semiBold.copyWith(
                                            color: Colors.white,
                                            fontSize: 40,
                                            fontWeight: FontWeight.w800),
                                      ),
                                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
                                Text('1 Coin = ₹1',
                                    style: AppTextStyles.medium.copyWith(
                                        color: Colors.white54, fontSize: SizeConfig.smallerFont)),
                              ],
                            ),
                          ),
                          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2.5),

                          // ── Coin packs ────────────────────────────────
                          Text('Add Coins',
                              style: AppTextStyles.semiBold.copyWith(
                                  fontSize: SizeConfig.headerThreeFont, color: Colorz.textColor)),
                          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: _packs.map((pack) {
                              final isPopular = pack['popular'] == true;
                              return GestureDetector(
                                onTap: wState.isAdding
                                    ? null
                                    : () => _purchase(pack['coins'] as int, pack['price'] as int),
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isPopular
                                            ? Colorz.primary.withValues(alpha: 0.08)
                                            : Colorz.bottomPillBg,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isPopular ? Colorz.primary : Colorz.dividerColor,
                                          width: isPopular ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.toll_rounded, color: Colors.amber, size: 18),
                                              const SizedBox(width: 4),
                                              Text('${pack['coins']}',
                                                  style: AppTextStyles.semiBold.copyWith(
                                                      fontSize: SizeConfig.headerThreeFont,
                                                      color: Colorz.textColor)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text('₹${pack['price']}',
                                              style: AppTextStyles.semiBold.copyWith(
                                                  color: Colorz.primary,
                                                  fontSize: SizeConfig.mediumFont)),
                                        ],
                                      ),
                                    ),
                                    if (isPopular)
                                      Positioned(
                                        top: 0, right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colorz.primary,
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(14),
                                              bottomLeft: Radius.circular(8),
                                            ),
                                          ),
                                          child: Text('Popular',
                                              style: AppTextStyles.medium.copyWith(
                                                  color: Colors.white,
                                                  fontSize: SizeConfig.smallerFont)),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          if (wState.isAdding) ...[
                            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                            const Center(child: CircularProgressIndicator(color: Colorz.primary)),
                          ],

                          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2.5),

                          // ── Transaction history ───────────────────────
                          Text('History',
                              style: AppTextStyles.semiBold.copyWith(
                                  fontSize: SizeConfig.headerThreeFont, color: Colorz.textColor)),
                          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

                          if (_txLoading)
                            const Center(child: CircularProgressIndicator(color: Colorz.primary))
                          else if (_transactions.isEmpty)
                            Center(
                              child: Text('No transactions yet',
                                  style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor)),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _transactions.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: Colorz.dividerColor, height: 1),
                              itemBuilder: (_, i) {
                                final tx = _transactions[i] as Map;
                                final isCredit = tx['type'] == 'PURCHASE';
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(
                                          color: isCredit
                                              ? Colorz.greenColor.withValues(alpha: 0.1)
                                              : Colorz.redColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          isCredit ? Icons.add_rounded : Icons.remove_rounded,
                                          color: isCredit ? Colorz.greenColor : Colorz.redColor,
                                          size: 18,
                                        ),
                                      ),
                                      SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(tx['description'] ?? '',
                                                style: AppTextStyles.medium.copyWith(
                                                    color: Colorz.textColor,
                                                    fontSize: SizeConfig.smallFont)),
                                            Text(_formatDate(tx['created_at']?.toString()),
                                                style: AppTextStyles.medium.copyWith(
                                                    color: Colorz.hintTextColor,
                                                    fontSize: SizeConfig.smallerFont)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isCredit ? '+' : '-'}${tx['amount']}',
                                        style: AppTextStyles.semiBold.copyWith(
                                          color: isCredit ? Colorz.greenColor : Colorz.redColor,
                                          fontSize: SizeConfig.mediumFont,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 3),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

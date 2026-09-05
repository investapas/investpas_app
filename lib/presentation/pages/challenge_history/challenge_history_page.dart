import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widgets/app_background.dart';
import '../../../Widgets/circle_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/navigationService.dart';
import '../../../core/utils/app_dialog.dart';

class ChallengeHistoryPage extends StatefulWidget {
  const ChallengeHistoryPage({super.key});

  @override
  State<ChallengeHistoryPage> createState() => _ChallengeHistoryPageState();
}

class _ChallengeHistoryPageState extends State<ChallengeHistoryPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final resp = await ApiHelper.get(ApiEndpoints.challengeHistoryApi);
      if (resp != null && resp['status'] == true) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(resp['data'] ?? []);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _completeChallenge() async {
    final confirmed = await AppDialog.showConfirm(
      context,
      title: 'Complete Challenge',
      message: 'Are you sure you want to complete this challenge and start a new one? Your progress will be saved.',
      confirmText: 'Complete',
      cancelText: 'Go Back',
      isDestructive: false,
    );
    if (!confirmed) return;

    final resp = await ApiHelper.post(ApiEndpoints.challengeCompleteApi, {});
    if (resp != null && resp['status'] == true) {
      if (mounted) AppSnackBar.showSuccess(context, 'Challenge completed! Start a new one.');
      _loadHistory();
    } else {
      if (mounted) AppSnackBar.showError(context, resp?['message'] ?? 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false,
          child: Container(
            margin: EdgeInsets.only(top: 50.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                      Text('Challenge History',
                          style: AppTextStyles.semiBold.copyWith(
                              color: Colorz.textColor, fontSize: SizeConfig.headerTwoFont)),
                      const Spacer(),
                      // Complete current challenge
                      // if (_history.isNotEmpty && (_history.first['isActive'] == true))
                      //   TextButton.icon(
                      //     onPressed: _completeChallenge,
                      //     icon: const Icon(Icons.check_circle_outline, size: 16),
                      //     label: const Text('Complete'),
                      //     style: TextButton.styleFrom(foregroundColor: Colorz.primary),
                      //   ),
                    ],
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),

                // Stats summary
                if (_history.isNotEmpty)
                  _buildSummary(),

                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

                // List
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colorz.primary))
                      : _history.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emoji_events_outlined, size: 48, color: Colorz.hintTextColor),
                                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                                  Text('No challenges yet', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadHistory,
                              child: ListView.separated(
                                padding: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
                                itemCount: _history.length,
                                separatorBuilder: (_, __) => SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                                itemBuilder: (_, i) => _ChallengeCard(
                                  challenge: _history[i],
                                  index: _history.length - i,
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final total     = _history.length;
    final completed = _history.where((c) => c['status'] == 'COMPLETED').length;
    final active    = _history.where((c) => c['isActive'] == true).length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 2),
      decoration: BoxDecoration(
        color: Colorz.bottomPillBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBox('Total', total.toString(), Colorz.textColor),
          _statBox('Completed', completed.toString(), Colorz.greenColor),
          _statBox('Active', active.toString(), Colorz.primary),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.semiBold.copyWith(color: color, fontSize: SizeConfig.headerTwoFont)),
        Text(label, style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final int index;

  const _ChallengeCard({required this.challenge, required this.index});

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final status    = challenge['status'] as String? ?? 'ACTIVE';
    final isActive  = challenge['isActive'] == true;
    final finalPnl  = _toDouble(challenge['finalPnl']);
    final trades    = _toInt(challenge['totalTrades']);
    final capital   = _toDouble(challenge['tradingCapital']);
    final maxProfit = _toDouble(challenge['maxProfit']);
    final days      = _toInt(challenge['challengeDays']);
    final start     = challenge['startDate']?.toString().split('T').first ?? '';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'COMPLETED': statusColor = Colorz.greenColor; statusIcon = Icons.check_circle_rounded; break;
      case 'ABANDONED': statusColor = Colorz.hintTextColor; statusIcon = Icons.cancel_outlined; break;
      default:          statusColor = Colorz.primary;     statusIcon = Icons.play_circle_outline; break;
    }

    return Container(
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
      decoration: BoxDecoration(
        color: Colorz.bottomPillBg,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: Colorz.primary, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(status, style: AppTextStyles.medium.copyWith(color: statusColor, fontSize: SizeConfig.smallerFont)),
                  ],
                ),
              ),
              const Spacer(),
              Text('Challenge #$index',
                  style: AppTextStyles.semiBold.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
            ],
          ),

          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

          // Stats grid
          Row(
            children: [
              _infoItem('Capital', '₹${capital.toStringAsFixed(0)}'),
              _infoItem('Target',  '₹${maxProfit.toStringAsFixed(0)}'),
              _infoItem('Days',    '$days'),
              _infoItem('Trades',  '$trades'),
            ],
          ),

          if (status != 'ACTIVE') ...[
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
            Divider(color: Colorz.dividerColor, height: 1),
            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.8),
            Row(
              children: [
                Text('Final P&L: ', style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
                Text(
                  '${finalPnl >= 0 ? '+' : ''}₹${finalPnl.toStringAsFixed(2)}',
                  style: AppTextStyles.semiBold.copyWith(
                    color: finalPnl >= 0 ? Colorz.greenColor : Colorz.redColor,
                    fontSize: SizeConfig.smallFont,
                  ),
                ),
                const Spacer(),
                if (start.isNotEmpty)
                  Text(start, style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor, fontSize: SizeConfig.smallerFont)),
          Text(value, style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor, fontSize: SizeConfig.smallFont)),
        ],
      ),
    );
  }
}

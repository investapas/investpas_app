import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/Widgets/Widgets.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/presentation/pages/dashBoard/home/widget/challange_progress.dart';
import 'package:investapas/presentation/pages/dashBoard/home/widget/create_challange_widget.dart';
import 'package:investapas/presentation/pages/dashBoard/home/widget/free_challange_widget.dart';
import 'package:investapas/presentation/pages/dashBoard/home/widget/rule_summary_widget.dart';

import '../../../../core/utils/navigationService.dart';
import '../../../../routes/appRoutes.dart';
import '../../../bloc/dashboard/bloc.dart';
import '../../../bloc/dashboard/event.dart';
import '../../../bloc/dashboard/state.dart';
import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../bloc/wallet/wallet_bloc.dart';
import '../../../bloc/wallet/wallet_event.dart';
import '../../../bloc/wallet/wallet_state.dart';
import '../../challenge_history/challenge_history_page.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadWalletBalance());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashBoardBloc, DashBoardState>(
      builder: (context,state) {
        return Container(
          margin: EdgeInsets.only(
            left: SizeConfig.spaceBetween * 2,
            right: SizeConfig.spaceBetween * 2,
            top: 50.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, profileState) {
                      return Container(
                        width: 48.sp,
                        height: 48.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colorz.primary.withValues(alpha: 0.15),
                          border: Border.all(color: Colorz.primary, width: 1.5),
                        ),
                        child: ClipOval(
                          child: profileState.profilePicture.isNotEmpty
                              ? Image.network(
                                  profileState.profilePicture,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: Colorz.primary, size: 26.sp),
                                )
                              : Icon(Icons.person_rounded, color: Colorz.primary, size: 26.sp),
                        ),
                      );
                    },
                  ),
                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back, ${state.clientName} 👋",
                          style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.mediumFont,color: Colorz.textColor),
                        ),
                        Text(
                          "Good luck for today's session",
                          style: AppTextStyles.medium.copyWith(fontWeight: FontWeight.w500,color: Colorz.hintTextColor),
                        )
                      ],
                    ),
                  ),
                  // ── Wallet badge ──────────────────────────────────────
                  BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, wState) => GestureDetector(
                      onTap: () => NavigatorService.pushNamed(AppRoutes.walletPage),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colorz.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colorz.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.toll_rounded, color: Colors.amber, size: 16.sp),
                            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.4),
                            Text(
                              '${wState.balance}',
                              style: AppTextStyles.semiBold.copyWith(
                                color: Colorz.primary,
                                fontSize: SizeConfig.smallFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*5),
                      if (state.challengeLoading)
                        const Center(child: CircularProgressIndicator(color: Colorz.primary))
                      else if (state.hasChallenge)
                        ChallengeProgress(
                          completedDays: state.completedDays,
                          totalDays: state.totalDays,
                          challengeName: state.challengeName,
                          isActive: state.completedDays < state.totalDays,
                          startDate: state.startDate,
                          endDate: state.endDate,
                        )
                      else
                        const SizedBox.shrink(),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                      if (state.hasChallenge && !state.challengeLoading) ...[
                        const _DisciplineScoreCard(),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                      ],
                      // Challenge History button
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChallengeHistoryPage()),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.spaceBetween * 1.5,
                              vertical: SizeConfig.spaceBetween * 0.6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colorz.primary),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_rounded, size: 14, color: Colorz.primary),
                                SizeConfig.horizontalSpace(width: 4),
                                Text('Challenge History',
                                    style: AppTextStyles.medium.copyWith(
                                      color: Colorz.primary,
                                      fontSize: SizeConfig.smallFont,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
                      // Show create widget when no challenge
                      if (!state.hasChallenge && !state.challengeLoading) ...[
                        const CreateChallangeWidget(),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
                        const FreeChallangeWidget(),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
                      ],

                      // Show "Start New Challenge" only when challenge is COMPLETED (days over)
                      if (state.hasChallenge && !state.challengeLoading &&
                          state.completedDays >= state.totalDays) ...[
                        InkWell(
                          onTap: () => NavigatorService.pushNamed(AppRoutes.setupChallengePage),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.spaceBetween * 1.5,
                              horizontal: SizeConfig.spaceBetween * 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colorz.primary, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded,
                                    color: Colorz.primary, size: 20),
                                SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.5),
                                Text(
                                  'Start New Challenge',
                                  style: AppTextStyles.semiBold.copyWith(
                                    color: Colorz.primary,
                                    fontSize: SizeConfig.mediumFont,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
                      ],
                      Text(
                        "Your Rules Summary",
                        style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.headerThreeFont,color: Colorz.textColor),
                      ),
                      Text(
                        "Quick view of today's limits",
                        style: AppTextStyles.medium.copyWith(fontSize: SizeConfig.mediumFont,color: Colorz.hintTextColor),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                      const RuleSummaryWidget(),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*1.5),
                      Button(
                        text: 'Continue to Trading Terminal',
                        isOutlined: false,
                        isBig: true,
                        radius: 100,
                        gradient: Colorz.primaryButtonGradient,
                        onPressed: () {
                          context.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(1));
                        },
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// ── Discipline Score Card ────────────────────────────────────────────────────
class _DisciplineScoreCard extends StatefulWidget {
  const _DisciplineScoreCard();

  @override
  State<_DisciplineScoreCard> createState() => _DisciplineScoreCardState();
}

class _DisciplineScoreCardState extends State<_DisciplineScoreCard> {
  int _score = 100;
  String _grade = 'A';
  List<String> _deductions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchScore();
  }

  Future<void> _fetchScore() async {
    try {
      final resp = await ApiHelper.get(ApiEndpoints.challengeDisciplineScoreApi);
      if (!mounted) return;
      if (resp != null && resp['status'] == true && resp['data'] != null) {
        final d = resp['data'];
        setState(() {
          _score = (d['score'] as num?)?.toInt() ?? 100;
          _grade = d['grade']?.toString() ?? 'A';
          _deductions = (d['deductions'] as List? ?? []).map((e) => e.toString()).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color get _scoreColor {
    if (_score >= 80) return Colorz.greenColor;
    if (_score >= 65) return Colors.amber.shade700;
    if (_score >= 50) return Colors.orange;
    return Colorz.redColor;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
      decoration: BoxDecoration(
        color: Colorz.bottomPillBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _scoreColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.sp,
            height: 48.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _scoreColor.withValues(alpha: 0.15),
              border: Border.all(color: _scoreColor, width: 2),
            ),
            child: Center(
              child: Text('$_score',
                  style: AppTextStyles.semiBold.copyWith(
                    color: _scoreColor,
                    fontSize: SizeConfig.mediumFont,
                  )),
            ),
          ),
          SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Discipline Score',
                        style: AppTextStyles.semiBold.copyWith(
                          color: Colorz.textColor,
                          fontSize: SizeConfig.mediumFont,
                        )),
                    SizeConfig.horizontalSpace(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _scoreColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Grade $_grade',
                          style: AppTextStyles.semiBold.copyWith(
                            color: _scoreColor,
                            fontSize: SizeConfig.smallerFont,
                          )),
                    ),
                  ],
                ),
                SizeConfig.verticalSpace(height: 3),
                Text(
                  _deductions.isEmpty
                      ? 'Trading with full discipline today 🎯'
                      : _deductions.join(' • '),
                  style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor,
                    fontSize: SizeConfig.smallerFont,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Coaching Card ─────────────────────────────────────────────────────────


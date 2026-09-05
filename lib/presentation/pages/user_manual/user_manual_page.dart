import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';

class UserManualPage extends StatelessWidget {
  const UserManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorz.backgroundColor2,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200.sp,
            pinned: true,
            backgroundColor: Colorz.primary,
            leading: GestureDetector(
              onTap: () => NavigatorService.goBack(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colorz.primary,
                      const Color(0xFF6B8FF8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo
                      Container(
                        width: 64.sp,
                        height: 64.sp,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.sp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          Assets.logoTransparent,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'User Manual',
                        style: AppTextStyles.semiBold.copyWith(
                          color: Colors.white,
                          fontSize: SizeConfig.headerTwoFont,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'INVESTAPAS',
                        style: AppTextStyles.medium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: SizeConfig.smallFont,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.sp, vertical: 20.sp),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome
                _InfoCard(
                  icon: Icons.waving_hand_rounded,
                  iconColor: const Color(0xFFFFA726),
                  title: 'Welcome to Investapas',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bodyText(
                          'Investapas is a behavioural trading discipline platform designed to help traders follow their own trading rules and avoid emotional decision-making.'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Colorz.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colorz.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: Colorz.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _bodyText(
                                  'Investapas is not a broker, investment advisor, or stock recommendation platform.'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Getting Started
                _InfoCard(
                  icon: Icons.rocket_launch_rounded,
                  iconColor: Colorz.primary,
                  title: 'Getting Started',
                  child: Column(
                    children: [
                      _Step(
                        number: 1,
                        title: 'Create Your Account',
                        body:
                            'Register using your mobile number and email address.',
                      ),
                      _Step(
                        number: 2,
                        title: 'Link Your Broker Account',
                        body:
                            'Connect your supported broker account (such as Dhan) through the secure authentication process.',
                      ),
                      _Step(
                        number: 3,
                        title: 'Create Your Challenge',
                        body:
                            'Define your personal trading rules: Trading Capital, Maximum Daily Profit, Maximum Daily Loss, Maximum Trades Per Day, and Position Sizing Rules.',
                      ),
                      _Step(
                        number: 4,
                        title: 'Start Trading',
                        body:
                            'Place trades through the Investapas trading terminal. Before every order, Investapas checks whether your trade follows your selected challenge rules.',
                      ),
                      _Step(
                        number: 5,
                        title: 'Rule Enforcement',
                        body:
                            'If a trade violates your selected rules, Investapas may show warnings, trigger cooldown periods, block order execution, or require quick unlock confirmation.',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Challenge Rules
                _InfoCard(
                  icon: Icons.shield_rounded,
                  iconColor: const Color(0xFF26C6DA),
                  title: 'Challenge Rules',
                  child: Column(
                    children: [
                      _RuleRow(
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colorz.primary,
                        title: 'Trading Capital',
                        body:
                            'The maximum capital you choose to allocate for your challenge.',
                      ),
                      _RuleRow(
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFF4CAF50),
                        title: 'Maximum Profit Limit',
                        body:
                            'Once your selected daily profit target is achieved, Investapas may restrict additional trading activity.',
                      ),
                      _RuleRow(
                        icon: Icons.trending_down_rounded,
                        color: const Color(0xFFEF5350),
                        title: 'Maximum Loss Limit',
                        body:
                            'Once your selected daily loss limit is reached, Investapas may restrict further trading activity.',
                      ),
                      _RuleRow(
                        icon: Icons.repeat_rounded,
                        color: const Color(0xFFFFA726),
                        title: 'Maximum Trades Per Day',
                        body:
                            'Limits the total number of trades allowed during a trading session.',
                      ),
                      _RuleRow(
                        icon: Icons.candlestick_chart_outlined,
                        color: const Color(0xFF26C6DA),
                        title: 'Position Sizing',
                        body:
                            'Controls maximum quantity exposure according to your challenge settings.',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Demo Mode
                _InfoCard(
                  icon: Icons.science_rounded,
                  iconColor: const Color(0xFF9C27B0),
                  title: 'Demo Mode',
                  child: _bodyText(
                      'Demo Mode allows users to practice discipline-based trading using virtual funds without risking real capital.'),
                ),

                const SizedBox(height: 14),

                // Feedback
                _InfoCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  title: 'Feedback',
                  child: _bodyText(
                      'Users are encouraged to report bugs, suggestions, and improvement ideas during beta testing.'),
                ),

                const SizedBox(height: 14),

                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFFFA726).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFFFA726), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Disclaimer',
                              style: AppTextStyles.semiBold.copyWith(
                                color: const Color(0xFFE65100),
                                fontSize: SizeConfig.mediumFont,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _bodyText(
                                'Investapas does not guarantee profits, trading success, or reduction of losses. Trading involves substantial risk.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.sp),

                // Footer
                Center(
                  child: Column(
                    children: [
                      Image.asset(Assets.logoTransparent,
                          height: 32.sp, fit: BoxFit.contain),
                      const SizedBox(height: 6),
                      Text(
                        'INVESTAPAS  •  Beta Version',
                        style: AppTextStyles.medium.copyWith(
                          color: Colorz.hintTextColor,
                          fontSize: SizeConfig.smallerFont,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.sp),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bodyText(String text) => Text(
        text,
        style: AppTextStyles.medium.copyWith(
          color: Colorz.hintTextColor,
          fontSize: SizeConfig.smallFont,
          height: 1.6,
        ),
      );
}

// ── Reusable info card ─────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor,
                    fontSize: SizeConfig.mediumFont,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colorz.dividerColor, height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Numbered step widget ───────────────────────────────────────────────────────
class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String body;
  final bool isLast;

  const _Step({
    required this.number,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number + connector
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: Colorz.primaryButtonGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: AppTextStyles.semiBold.copyWith(
                      color: Colors.white,
                      fontSize: SizeConfig.smallFont,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: Colorz.primary.withValues(alpha: 0.2),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.semiBold.copyWith(
                      color: Colorz.textColor,
                      fontSize: SizeConfig.smallFont,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor,
                      fontSize: SizeConfig.smallerFont,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rule row with icon ────────────────────────────────────────────────────────
class _RuleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final bool isLast;

  const _RuleRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.semiBold.copyWith(
                    color: Colorz.textColor,
                    fontSize: SizeConfig.smallFont,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor,
                    fontSize: SizeConfig.smallerFont,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

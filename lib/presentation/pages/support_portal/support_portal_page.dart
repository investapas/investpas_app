import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';

class SupportPortalPage extends StatelessWidget {
  const SupportPortalPage({super.key});

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
            backgroundColor: const Color(0xFF1E88E5),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
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
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(Assets.logoTransparent,
                            fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Support Portal',
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

                // Need Help section
                _SectionCard(
                  icon: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  title: 'Need Help?',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our support team is available to assist with:',
                        style: AppTextStyles.medium.copyWith(
                          color: Colorz.hintTextColor,
                          fontSize: SizeConfig.smallFont,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._topics.map((t) => _BulletRow(text: t)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Contact Methods
                _SectionCard(
                  icon: Icons.contact_support_rounded,
                  iconColor: const Color(0xFF26C6DA),
                  title: 'Contact Methods',
                  child: Column(
                    children: [
                      // Email
                      _ContactTile(
                        icon: Icons.mail_outline_rounded,
                        iconBg: const Color(0xFF1E88E5),
                        label: 'Email Support',
                        value: 'support@investapas.in',
                        onCopy: () => _copy(context, 'support@investapas.in'),
                      ),
                      const SizedBox(height: 12),
                      // WhatsApp
                      _ContactTile(
                        icon: Icons.chat_rounded,
                        iconBg: const Color(0xFF4CAF50),
                        label: 'WhatsApp Support',
                        value: 'Official Support Number',
                        isPlaceholder: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Response Time
                _SectionCard(
                  icon: Icons.schedule_rounded,
                  iconColor: const Color(0xFFFFA726),
                  title: 'Response Time',
                  child: Column(
                    children: [
                      _ResponseRow(
                        label: 'Priority Issues',
                        value: 'Within 24 hours',
                        color: const Color(0xFFEF5350),
                        icon: Icons.flash_on_rounded,
                      ),
                      const SizedBox(height: 10),
                      _ResponseRow(
                        label: 'General Queries',
                        value: '1–3 business days',
                        color: const Color(0xFFFFA726),
                        icon: Icons.schedule_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Report a Bug
                _SectionCard(
                  icon: Icons.bug_report_outlined,
                  iconColor: const Color(0xFFEF5350),
                  title: 'Report a Bug',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'When reporting a bug, please include:',
                        style: AppTextStyles.medium.copyWith(
                          color: Colorz.hintTextColor,
                          fontSize: SizeConfig.smallFont,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._bugItems.map((b) => _BulletRow(
                            text: b,
                            bulletColor: const Color(0xFFEF5350),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Beta Testing Feedback
                _SectionCard(
                  icon: Icons.science_rounded,
                  iconColor: const Color(0xFF9C27B0),
                  title: 'Beta Testing Feedback',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We actively welcome:',
                        style: AppTextStyles.medium.copyWith(
                          color: Colorz.hintTextColor,
                          fontSize: SizeConfig.smallFont,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._feedbackItems.map((f) => _BulletRow(
                            text: f,
                            bulletColor: const Color(0xFF9C27B0),
                          )),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF9C27B0)
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_rounded,
                                color: Color(0xFF9C27B0), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your feedback directly contributes to improving Investapas.',
                                style: AppTextStyles.medium.copyWith(
                                  color: Colorz.hintTextColor,
                                  fontSize: SizeConfig.smallerFont,
                                  height: 1.5,
                                ),
                              ),
                            ),
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

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colorz.primary,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static const _topics = [
    'Account setup',
    'Broker connection issues',
    'Challenge configuration',
    'Trading terminal issues',
    'Subscription questions',
    'Beta testing feedback',
    'Bug reporting',
  ];

  static const _bugItems = [
    'Device model',
    'App version',
    'Screenshot (if available)',
    'Detailed description of the issue',
  ];

  static const _feedbackItems = [
    'Feature requests',
    'UI improvement suggestions',
    'User experience feedback',
    'Rule enhancement ideas',
  ];
}

// ── Section card ───────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
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
              Text(
                title,
                style: AppTextStyles.semiBold.copyWith(
                  color: Colorz.textColor,
                  fontSize: SizeConfig.mediumFont,
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

// ── Bullet row ─────────────────────────────────────────────────────────────────
class _BulletRow extends StatelessWidget {
  final String text;
  final Color? bulletColor;

  const _BulletRow({required this.text, this.bulletColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: bulletColor ?? Colorz.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.medium.copyWith(
                color: Colorz.hintTextColor,
                fontSize: SizeConfig.smallFont,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact tile ───────────────────────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String value;
  final bool isPlaceholder;
  final VoidCallback? onCopy;

  const _ContactTile({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colorz.backgroundColor2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colorz.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor,
                    fontSize: SizeConfig.smallerFont,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.semiBold.copyWith(
                    color: isPlaceholder
                        ? Colorz.hintTextColor
                        : Colorz.textColor,
                    fontSize: SizeConfig.smallFont,
                    fontStyle: isPlaceholder
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colorz.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: Colorz.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded,
                        size: 12, color: Colorz.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.primary,
                        fontSize: SizeConfig.smallerFont,
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

// ── Response time row ──────────────────────────────────────────────────────────
class _ResponseRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ResponseRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.medium.copyWith(
                color: Colorz.textColor,
                fontSize: SizeConfig.smallFont,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: AppTextStyles.semiBold.copyWith(
                color: Colors.white,
                fontSize: SizeConfig.smallerFont,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

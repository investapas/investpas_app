import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorz.backgroundColor2,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200.sp,
            pinned: true,
            backgroundColor: const Color(0xFF00897B),
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
                    colors: [Color(0xFF004D40), Color(0xFF26A69A)],
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
                        'Contact Us',
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
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 20.sp),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Intro text
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF00897B).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.waving_hand_rounded,
                          color: Color(0xFF00897B), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Thank you for using Investapas. For support, feedback, partnerships, media inquiries, or general questions, please contact us.',
                          style: AppTextStyles.medium.copyWith(
                            color: Colorz.hintTextColor,
                            fontSize: SizeConfig.smallFont,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Contact card
                _SectionCard(
                  icon: Icons.contact_mail_rounded,
                  iconColor: const Color(0xFF00897B),
                  title: 'Get In Touch',
                  child: Column(
                    children: [
                      _ContactTile(
                        icon: Icons.support_agent_rounded,
                        iconBg: const Color(0xFF1E88E5),
                        label: 'Support',
                        value: 'support@investapas.in',
                        onCopy: () =>
                            _copy(context, 'support@investapas.in'),
                      ),
                      const SizedBox(height: 12),
                      _ContactTile(
                        icon: Icons.business_rounded,
                        iconBg: const Color(0xFF7B1FA2),
                        label: 'Business Inquiries',
                        value: 'founders@investapas.in',
                        onCopy: () =>
                            _copy(context, 'founders@investapas.in'),
                      ),
                      const SizedBox(height: 12),
                      _ContactTile(
                        icon: Icons.language_rounded,
                        iconBg: const Color(0xFF00897B),
                        label: 'Website',
                        value: 'www.investapas.in',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // FAQ header
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.quiz_rounded,
                          color: Color(0xFFFFA726), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Frequently Asked Questions',
                      style: AppTextStyles.semiBold.copyWith(
                        color: Colorz.textColor,
                        fontSize: SizeConfig.mediumFont,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // FAQ accordion
                ..._faqs.asMap().entries.map((e) {
                  final i = e.key;
                  final faq = e.value;
                  final open = _expanded.contains(i);
                  return _FaqTile(
                    question: faq[0],
                    answer: faq[1],
                    isOpen: open,
                    onTap: () => setState(() {
                      if (open) {
                        _expanded.remove(i);
                      } else {
                        _expanded.add(i);
                      }
                    }),
                  );
                }),

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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static const _faqs = [
    [
      'What is Investapas?',
      'Investapas is a behavioural trading discipline platform designed to help traders follow predefined trading rules and reduce emotional decision-making.',
    ],
    [
      'Is Investapas a broker?',
      'No. Investapas is not a broker and does not hold client funds.',
    ],
    [
      'Does Investapas provide stock tips?',
      'No. Investapas does not provide investment advice or guaranteed trading recommendations.',
    ],
    [
      'Can Investapas guarantee profits?',
      'No. Trading always involves risk and Investapas does not guarantee profitability.',
    ],
    [
      'Why do I need to link my broker account?',
      'Broker integration allows Investapas to monitor trades and enforce challenge rules.',
    ],
    [
      'Can Investapas place trades without my permission?',
      'No. Users remain responsible for their trading decisions.',
    ],
    [
      'What happens if I reach my maximum loss limit?',
      'Investapas may restrict further trading activity according to your challenge settings.',
    ],
    [
      'What happens if I exceed my daily trade limit?',
      'The platform may activate a cooldown period or block additional trades.',
    ],
    [
      'What is Quick Unlock?',
      'Quick Unlock is a feature that allows users to bypass certain restrictions under defined conditions.',
    ],
    [
      'Is my trading data safe?',
      'We use reasonable security measures and do not sell user data to third parties.',
    ],
    [
      'Can I use Investapas without a subscription?',
      'Certain features may be available during free trial periods, while advanced features require an active subscription.',
    ],
    [
      'Does Investapas support demo trading?',
      'Yes. Demo trading functionality may be available to help users practice discipline-based trading with virtual funds.',
    ],
    [
      'Which brokers are supported?',
      'Supported brokers may vary. Please refer to the latest broker integration list inside the application.',
    ],
    [
      'How do I cancel my subscription?',
      'Subscription management options are available within your account settings.',
    ],
    [
      'Do you offer refunds?',
      'Please refer to the Refund & Subscription Policy available on our website.',
    ],
    [
      'How can I provide feedback?',
      'You can contact our support team through email, WhatsApp, or the in-app feedback section.',
    ],
    [
      'What makes Investapas different?',
      'Investapas focuses on behavioural discipline, risk control, and rule enforcement rather than stock recommendations or trading tips.',
    ],
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

// ── Contact tile ───────────────────────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _ContactTile({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
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
                    color: Colorz.textColor,
                    fontSize: SizeConfig.smallFont,
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
                    Icon(Icons.copy_rounded, size: 12, color: Colorz.primary),
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

// ── FAQ accordion tile ─────────────────────────────────────────────────────────
class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isOpen;
  final VoidCallback onTap;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpen
              ? const Color(0xFF00897B).withValues(alpha: 0.4)
              : Colorz.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOpen
                            ? const Color(0xFF00897B)
                            : Colorz.hintTextColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        question,
                        style: AppTextStyles.semiBold.copyWith(
                          color: isOpen
                              ? const Color(0xFF00897B)
                              : Colorz.textColor,
                          fontSize: SizeConfig.smallFont,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: isOpen
                            ? const Color(0xFF00897B)
                            : Colorz.hintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(30, 0, 14, 14),
                child: Text(
                  answer,
                  style: AppTextStyles.medium.copyWith(
                    color: Colorz.hintTextColor,
                    fontSize: SizeConfig.smallFont,
                    height: 1.6,
                  ),
                ),
              ),
              crossFadeState: isOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

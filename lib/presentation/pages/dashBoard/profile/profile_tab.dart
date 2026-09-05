import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/core/utils/navigationService.dart';
import 'package:investapas/presentation/bloc/profile/profile_bloc.dart';
import 'package:investapas/presentation/bloc/profile/profile_event.dart';
import 'package:investapas/presentation/bloc/profile/profile_state.dart';
import 'package:investapas/presentation/pages/dashBoard/profile/widget/thin_progress_bar.dart';
import 'package:investapas/routes/appRoutes.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/utils/shared_prefs_helper.dart';
import '../../../../core/utils/toast_helper.dart';
import '../../../../core/services/demo_mode_service.dart';
import '../../../../routes/appRoutes.dart';
import '../../../bloc/demo/demo_bloc.dart';
import '../../../bloc/demo/demo_event.dart';
import '../../../bloc/demo/demo_state.dart';

const String _marketDataClientId = '1102454980';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _pickAndUpload(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      context.read<ProfileBloc>().add(UploadProfilePictureEvent(picked.path));
    }
  }

  void _showPhotoOptions(BuildContext context, bool hasPicture) {
    if (!hasPicture) {
      _pickAndUpload(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colorz.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Change Photo
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colorz.backgroundColor2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined, color: Colorz.primary, size: 20),
              ),
              title: Text('Change Photo',
                  style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor)),
              subtitle: Text('Pick a new photo from gallery',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(context);
              },
            ),
            const Divider(height: 1, color: Colorz.dividerColor),
            // Remove Photo
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colorz.redBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Colorz.redColor, size: 20),
              ),
              title: Text('Remove Photo',
                  style: AppTextStyles.semiBold.copyWith(color: Colorz.redColor)),
              subtitle: Text('Delete your current profile picture',
                  style: AppTextStyles.medium.copyWith(
                      color: Colorz.hintTextColor, fontSize: SizeConfig.smallFont)),
              onTap: () {
                Navigator.pop(context);
                context.read<ProfileBloc>().add(const RemoveProfilePictureEvent());
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.only(
            top: 50.sp,
            left: SizeConfig.spaceBetween*2,
            right: SizeConfig.spaceBetween*2
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*2),
                Row(
                  children: [
                    // profile avatar — tappable
                    GestureDetector(
                      onTap: state.isUploadingPicture ? null : () => _showPhotoOptions(context, state.profilePicture.isNotEmpty),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 68.sp,
                            height: 68.sp,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2A2A2A)),
                            child: ClipOval(
                              child: state.isUploadingPicture
                                  ? Center(child: SizedBox(width: 24.sp, height: 24.sp, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                                  : state.profilePicture.isNotEmpty
                                      ? Image.network(state.profilePicture, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26.sp))
                                      : Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26.sp),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 22.sp,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100), bottomRight: Radius.circular(100)),
                              ),
                              child: Center(
                                child: Text(
                                  state.profilePicture.isNotEmpty ? "Edit" : "Add",
                                  style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*1.5),
                    Expanded(
                      child: Text(
                        state.clientName,
                        style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.headerThreeFont),
                      ),
                    ),
                    SvgPicture.asset(Assets.editSvg),
                  ],
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),

                // Market Data Token — only for client 1102454980
                if (state.clientId == _marketDataClientId)
                  _MarketTokenSection(),

                if (state.clientId == _marketDataClientId)
                  SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),

                // ── Demo Trading card ─────────────────────────────────────
                BlocListener<DemoBloc, DemoState>(
                  listenWhen: (p, c) => !p.showWelcomeDialog && c.showWelcomeDialog,
                  listener: (ctx, demoState) {
                    ctx.read<DemoBloc>().add(const ClearDemoMessage());
                    _showDemoWelcomeDialog(ctx, demoState);
                  },
                  child: ListenableBuilder(
                    listenable: DemoModeService.instance,
                    builder: (context, _) {
                      final isDemo = DemoModeService.instance.isActive;
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.sp),
                          gradient: LinearGradient(
                            colors: isDemo
                                ? [const Color(0xFF1A73E8), const Color(0xFF0D47A1)]
                                : [Colorz.bottomPillBg, Colorz.bottomPillBg],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.science_outlined,
                                        size: 18.sp,
                                        color: isDemo ? Colors.white : Colorz.textColor,
                                      ),
                                      SizeConfig.horizontalSpace(width: 6),
                                      Text(
                                        'Demo Trading',
                                        style: AppTextStyles.semiBold.copyWith(
                                          color: isDemo ? Colors.white : Colorz.textColor,
                                          fontSize: SizeConfig.mediumFont,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizeConfig.verticalSpace(height: 4),
                                  Text(
                                    isDemo
                                        ? 'Active — using Demo Coins (1 Coin = ₹1)'
                                        : 'Practice with 1,00,000 free Demo Coins',
                                    style: AppTextStyles.medium.copyWith(
                                      color: isDemo
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : Colorz.hintTextColor,
                                      fontSize: SizeConfig.smallerFont,
                                    ),
                                  ),
                                  if (isDemo) ...[
                                    SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                                    GestureDetector(
                                      onTap: () => NavigatorService.pushNamed(AppRoutes.demoPage),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20.sp),
                                        ),
                                        child: Text(
                                          'View Portfolio & Orders',
                                          style: AppTextStyles.semiBold.copyWith(
                                            color: Colors.white,
                                            fontSize: SizeConfig.smallFont,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            FlutterSwitch(
                              value: isDemo,
                              onToggle: (v) {
                                DemoModeService.instance.setActive(v);
                                if (v) {
                                  // Activate on backend → grants free coins if first time
                                  context.read<DemoBloc>().add(const ActivateDemoMode());
                                }
                              },
                              activeColor: Colors.white.withValues(alpha: 0.3),
                              inactiveColor: Colorz.hintTextColor.withValues(alpha: 0.2),
                              activeToggleColor: Colors.white,
                              inactiveToggleColor: Colorz.hintTextColor,
                              width: 48.sp,
                              height: 26.sp,
                              toggleSize: 20.sp,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

                // ── AI Trading Bot card ──────────────────────────────────
                // UNCOMMENT BELOW TO SHOW AI BOT BUTTON
                // GestureDetector(
                //   onTap: () => NavigatorService.pushNamed(AppRoutes.botPage),
                //   child: Container(
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(12.sp),
                //       gradient: const LinearGradient(
                //         colors: [Color(0xFF1A237E), Color(0xFF283593)],
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //       ),
                //     ),
                //     padding: EdgeInsets.all(SizeConfig.spaceBetween * 1.5),
                //     child: Row(
                //       children: [
                //         Container(
                //           width: 40.sp,
                //           height: 40.sp,
                //           decoration: BoxDecoration(
                //             color: Colors.white.withValues(alpha: 0.15),
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22.sp),
                //         ),
                //         SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                //         Expanded(
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 'AI Trading Bot',
                //                 style: AppTextStyles.semiBold.copyWith(
                //                   color: Colors.white,
                //                   fontSize: SizeConfig.mediumFont,
                //                 ),
                //               ),
                //               SizeConfig.verticalSpace(height: 2),
                //               Text(
                //                 'Auto-trade with AI in Demo Mode',
                //                 style: AppTextStyles.medium.copyWith(
                //                   color: Colors.white.withValues(alpha: 0.7),
                //                   fontSize: SizeConfig.smallerFont,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16.sp),
                //       ],
                //     ),
                //   ),
                // ),

                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),
                // ── Account Info ──────────────────────────────────────────

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sp),
                    color: Colorz.bottomPillBg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spaceBetween*2,
                          vertical: SizeConfig.spaceBetween
                        ),
                        child: Text(
                          "Account Info",
                          style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor),
                        ),
                      ),
                      Divider(color: Colorz.white,thickness: 1.sp,),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              Assets.dhanImage,
                              height: 20,
                              width: 20,
                            ),
                            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
                            Text(
                              "Linked Broker : ",
                              style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                            ),
                            Text(
                              "Dhan",
                              style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.smallFont),
                            )
                          ],
                        ),
                      ),
                      Divider(color: Colorz.white,thickness: 1.sp,),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Funds",
                                style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor,fontSize: SizeConfig.smallFont),
                              ),
                            ),
                            state.isFundLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colorz.primary,
                                    ),
                                  )
                                : Text(
                                    "₹ ${state.availableBalance.toStringAsFixed(2)}",
                                    style: AppTextStyles.semiBold.copyWith(
                                        color: Colorz.primary,
                                        fontSize: SizeConfig.smallFont),
                                  ),
                          ],
                        ),
                      ),
                      Divider(color: Colorz.white,thickness: 1.sp,),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "App Version",
                                style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8C00), Color(0xFFFFB300)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16.sp),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8C00).withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.rocket_launch_rounded,
                                      color: Colors.white, size: 11),
                                  const SizedBox(width: 4),
                                  Text(
                                    "BETA",
                                    style: AppTextStyles.headerOne.copyWith(
                                        color: Colorz.white,
                                        letterSpacing: 1.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colorz.white,thickness: 1.sp,),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "AI Assistance",
                                style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                              ),
                            ),
                            FlutterSwitch(
                              width: 50,
                              height: 30,
                              toggleSize: 22,
                              value: state.isAssistance,
                              borderRadius: 15,
                              padding: 4,
                              toggleColor: Colorz.white,
                              inactiveToggleColor: Colorz.lineColor,
                              activeColor: Colorz.primary,
                              inactiveColor: Colorz.lightPrimary,
                              onToggle: (val) {
                                context.read<ProfileBloc>().add(ToggleAiAssistance(val));
                              },
                            ),
                          ],
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                    ],
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(color: Colorz.borderColor,width: 1.sp)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Text(
                          "Challenge & App Info",
                          style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor),
                        ),
                      ),
                      Divider(color: Colorz.dividerProfileColor,thickness: 1.sp,),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Challenge Data",
                                    style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                                  ),
                                ),
                                Text(
                                  "4/10",
                                  style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                                ),
                              ],
                            ),
                            SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.5),
                            const ThinProgressBar(
                              progress: 0.4,
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colorz.dividerProfileColor,thickness: 1.sp,),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "App Version",
                                style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                              ),
                            ),
                            Text(
                              "1.0.0",
                              style: AppTextStyles.small.copyWith(color: Colorz.textColor),
                            ),
                          ],
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                    ],
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
                Text(
                  "Help & Support",
                  style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(color: Colorz.borderColor, width: 1.sp),
                  ),
                  child: Column(
                    children: [
                      _helpItem(
                        icon: Icons.headset_mic_outlined,
                        label: "Support Portal",
                        onTap: () => NavigatorService.pushNamed(AppRoutes.supportPortalPage),
                      ),
                      Divider(color: Colorz.dividerProfileColor, thickness: 1.sp, height: 0),
                      _helpItem(
                        icon: Icons.mail_outline_rounded,
                        label: "Contact Us",
                        onTap: () => NavigatorService.pushNamed(AppRoutes.contactUsPage),
                      ),
                      Divider(color: Colorz.dividerProfileColor, thickness: 1.sp, height: 0),
                      _helpItem(
                        icon: Icons.menu_book_outlined,
                        label: "User Manual",
                        onTap: () => NavigatorService.pushNamed(AppRoutes.userManualPage),
                      ),
                    ],
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
                InkWell(
                  onTap: () async {
                    NavigatorService.markSessionEnded();
                    await SharedPrefsHelper().clearUserData();
                    NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginPage);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      color: Colorz.redBgColor
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.power_settings_new_rounded,color: Colorz.redColor,),
                        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
                        Text(
                          "Logout",
                          style: AppTextStyles.semiBold.copyWith(color: Colorz.redColor,fontSize: SizeConfig.mediumFont),
                        ),
                      ],
                    ),
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
                Text(
                  "Future Integrations",
                  style: AppTextStyles.semiBold.copyWith(color: Colorz.textColor),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: Colorz.borderColor,width: 1.sp)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SvgPicture.asset(Assets.linkSvg),
                                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
                                  Text(
                                    "Link Zerodha",
                                    style: AppTextStyles.small.copyWith(fontSize: SizeConfig.mediumFont,color: Colorz.linkColor,decoration: TextDecoration.underline,decorationColor: Colorz.linkColor),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "Coming soon",
                              style: AppTextStyles.small.copyWith(color: Colorz.hintColor3,fontSize: SizeConfig.mediumFont),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colorz.dividerProfileColor,thickness: 1.sp,),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.spaceBetween*2,
                            vertical: SizeConfig.spaceBetween
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SvgPicture.asset(Assets.linkSvg),
                                  SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
                                  Text(
                                    "Link Angle One",
                                    style: AppTextStyles.small.copyWith(fontSize: SizeConfig.mediumFont,color: Colorz.linkColor,decoration: TextDecoration.underline,decorationColor: Colorz.linkColor),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "Coming soon",
                              style: AppTextStyles.small.copyWith(color: Colorz.hintColor3,fontSize: SizeConfig.mediumFont),
                            ),
                          ],
                        ),
                      ),
                      SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),
                    ],
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
                // Invite Others
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      gradient: Colorz.primaryButtonGradient,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_giftcard_rounded, color: Colorz.white),
                        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.5),
                        Text(
                          "Invite Others",
                          style: AppTextStyles.semiBold.copyWith(
                            color: Colorz.white,
                            fontSize: SizeConfig.mediumFont,
                          ),
                        ),
                        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.3),
                        Text(
                          "• Earn rewards for every referral",
                          style: AppTextStyles.medium.copyWith(
                            color: Colorz.white.withValues(alpha: 0.8),
                            fontSize: SizeConfig.smallerFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*3),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _helpItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spaceBetween * 2,
          vertical: SizeConfig.spaceBetween * 1.2,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colorz.primary, size: 20),
            SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color: Colorz.textColor,
                  fontSize: SizeConfig.mediumFont,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colorz.hintTextColor, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Market Data Token Section (only for client 1102454980) ───────────────────
class _MarketTokenSection extends StatefulWidget {
  @override
  State<_MarketTokenSection> createState() => _MarketTokenSectionState();
}

class _MarketTokenSectionState extends State<_MarketTokenSection> {
  final _pinCtrl  = TextEditingController();
  final _totpCtrl = TextEditingController();
  bool _loading   = false;
  bool _success   = false;

  @override
  void dispose() {
    _pinCtrl.dispose();
    _totpCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_pinCtrl.text.trim().isEmpty || _totpCtrl.text.trim().isEmpty) {
      ToastHelper.showToast("Enter PIN and TOTP", isSuccess: false);
      return;
    }
    setState(() { _loading = true; _success = false; });

    final resp = await ApiHelper.post(ApiEndpoints.generateMarketTokenApi, {
      'pin':  _pinCtrl.text.trim(),
      'totp': _totpCtrl.text.trim(),
    });

    setState(() { _loading = false; });

    if (resp != null && resp['status'] == true) {
      setState(() { _success = true; });
      _pinCtrl.clear();
      _totpCtrl.clear();
      ToastHelper.showToast("Market token refreshed ✅", isSuccess: true);
    } else {
      ToastHelper.showToast(resp?['message'] ?? "Failed", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween * 2),
      padding: EdgeInsets.all(SizeConfig.spaceBetween * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: Colorz.primary, width: 1.5),
        color: Colorz.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wifi_tethering_rounded, color: Colorz.primary, size: 18),
              SizeConfig.horizontalSpace(width: 6),
              Text(
                "Refresh Market Data Token",
                style: AppTextStyles.semiBold.copyWith(color: Colorz.primary),
              ),
              if (_success) ...[
                SizeConfig.horizontalSpace(width: 8),
                Icon(Icons.check_circle_rounded, color: Colorz.greenColor, size: 16),
              ],
            ],
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 0.5),
          Text(
            "Generate a fresh SELF token for live price feed",
            style: AppTextStyles.medium.copyWith(
              color: Colorz.hintTextColor,
              fontSize: SizeConfig.smallFont,
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

          // PIN field
          TextField(
            controller: _pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: AppTextStyles.medium.copyWith(color: Colorz.textColor),
            decoration: InputDecoration(
              hintText: "Dhan PIN",
              hintStyle: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

          // TOTP field
          TextField(
            controller: _totpCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.medium.copyWith(color: Colorz.textColor),
            decoration: InputDecoration(
              hintText: "TOTP (6-digit authenticator code)",
              hintStyle: AppTextStyles.medium.copyWith(color: Colorz.hintTextColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _loading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colorz.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _loading
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colorz.white),
                    )
                  : Text(
                      "Generate & Save Token",
                      style: AppTextStyles.semiBold.copyWith(color: Colorz.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Demo welcome dialog — shown once on first activation ──────────────────────
void _showDemoWelcomeDialog(BuildContext context, DemoState demoState) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colorz.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.sp)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(
        SizeConfig.spaceBetween * 2,
        SizeConfig.spaceBetween * 2,
        SizeConfig.spaceBetween * 2,
        SizeConfig.spaceBetween * 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colorz.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

          // Coin icon
          Container(
            width: 72.sp, height: 72.sp,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.toll_rounded, color: Colors.white, size: 36),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

          Text(
            '🎉 Welcome to Demo Trading!',
            style: AppTextStyles.semiBold.copyWith(
              fontSize: SizeConfig.headerTwoFont,
              color: Colorz.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween),

          // Free coins badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spaceBetween * 1.5,
              vertical: SizeConfig.spaceBetween * 0.75,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.toll_rounded, color: Color(0xFF1A73E8), size: 20),
                const SizedBox(width: 8),
                Text(
                  '1,00,000 Free Demo Coins Added!',
                  style: AppTextStyles.semiBold.copyWith(
                    color: const Color(0xFF1A73E8),
                    fontSize: SizeConfig.mediumFont,
                  ),
                ),
              ],
            ),
          ),
          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 1.5),

          // Info rows
          _welcomeRow(Icons.toll_rounded,       '1 Demo Coin = ₹1 trading power'),
          _welcomeRow(Icons.trending_up_rounded, 'Profit on trades increases your coins'),
          _welcomeRow(Icons.trending_down_rounded,'Loss on trades decreases your coins'),
          _welcomeRow(Icons.add_circle_outline,  'Need more coins? Buy 1 Lakh for just ₹${demoState.coinPackPrice.toStringAsFixed(0)}'),

          SizeConfig.verticalSpace(height: SizeConfig.spaceBetween * 2),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                NavigatorService.pushNamed(AppRoutes.demoPage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                padding: EdgeInsets.symmetric(vertical: 14.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                ),
              ),
              child: Text(
                'Start Demo Trading',
                style: AppTextStyles.semiBold.copyWith(
                  color: Colors.white,
                  fontSize: SizeConfig.mediumFont,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _welcomeRow(IconData icon, String text) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: SizeConfig.spaceBetween * 0.4),
    child: Row(
      children: [
        Icon(icon, size: 18.sp, color: Colorz.hintTextColor),
        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween * 0.75),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.medium.copyWith(
              color: Colorz.textColor,
              fontSize: SizeConfig.smallFont,
            ),
          ),
        ),
      ],
    ),
  );
}

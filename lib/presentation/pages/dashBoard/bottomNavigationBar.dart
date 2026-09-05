import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Widgets/Widgets.dart';
import '../../../core/constants/constants.dart';
import '../../../core/theme/data.dart';
import '../../bloc/dashboard/bloc.dart';
import '../../bloc/dashboard/event.dart';
import '../../bloc/dashboard/state.dart';

/// dash board bottom navigation bar
class DashBoardNavigationBar extends StatelessWidget {
  /// constructor
  const DashBoardNavigationBar({super.key});

  /// Returns a widget that displays a bottom navigation bar icon.
  ///
  /// The widget consists of an [Expanded] widget that contains an [Inkk] widget.
  /// The [Inkk] widget has an [onTap] callback that is called when the widget is tapped.
  /// The [onTap] callback is only called if the [onTap] parameter is not null.
  ///
  /// The [Inkk] widget's child is a [Column] widget that centers its children vertically.
  /// The [Column] widget contains three children:
  /// - A [SizeConfig.verticalSpaceSmall] widget.
  /// - A [Center] widget that contains a [ViewAppImage] widget.
  /// - A [SizeConfig.verticalSpaceSmall] widget.
  /// - An [Expanded] widget that contains a [Txt] widget.
  ///
  /// The [ViewAppImage] widget displays an image with the specified [assetPath].
  /// The [Txt] widget displays the specified [text] with the specified color.
  /// If [text] is null, an empty string is displayed.
  ///
  /// The color of the [ViewAppImage] and [Txt] widgets is determined by the value of [isActive].
  /// If [isActive] is true, the color is [Colorz.primary].
  /// Otherwise, the color is [Colorz.gray].
  ///
  /// Parameters:
  /// - `assetPath`: The path to the image asset.
  /// - `text`: The text to be displayed.
  /// - `isActive`: Indicates whether the icon is active or not.
  /// - `onTap`: The callback function to be called when the widget is tapped.
  ///
  /// Returns:
  /// A [Widget] representing the bottom navigation bar icon.
  Widget _navItem(
      BuildContext context, {
        required int index,
        required String icon,
        required String label,
        required bool isActive,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        context
            .read<DashBoardBloc>()
            .add(ChangeTabDashBoardEvent(index));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 48.h,
        padding: EdgeInsets.only(
          right: isActive ? 16.w : 0,
          left: isActive ? 5.w : 0,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colorz.bottomPillBg
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 36.h,
              width: 36.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colorz.primary
                    : Colorz.bottomPillBg,
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  height: 18.sp,
                  width: 18.sp,
                  color: isActive
                      ? Colors.white
                      : Colorz.primary
                ),
              ),
            ),
            if (isActive) ...[
              SizedBox(width: 10.w),
              Text(
                label,
                style: AppTextStyles.semiBold.copyWith(fontSize: SizeConfig.smallerFont,color: Colorz.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adapts to system nav bar: gesture mode = small padding, 3-button = larger padding
    final systemBottom = MediaQuery.of(context).viewPadding.bottom;
    final bottomPad = systemBottom > 0 ? systemBottom : 16.h;

    return BlocBuilder<DashBoardBloc, DashBoardState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: bottomPad,
          ),
          child: SizedBox(
            height: 56.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(
                  context,
                  index: 0,
                  icon: Assets.homeSvg,
                  label: 'Dashboard',
                  isActive: state.pageIndex == 0,
                ),
                _navItem(
                  context,
                  index: 1,
                  icon: Assets.terminalSvg,
                  label: 'Trading Terminal',
                  isActive: state.pageIndex == 1,
                ),
                _navItem(
                  context,
                  index: 2,
                  icon: Assets.journalSvg,
                  label: 'Trading Journal',
                  isActive: state.pageIndex == 2,
                ),
                _navItem(
                  context,
                  index: 3,
                  icon: Assets.profileSvg,
                  label: 'Profile',
                  isActive: state.pageIndex == 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

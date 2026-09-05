import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Widgets/Widgets.dart';
import '../../../core/constants/constants.dart';

/// profile circular image
class ProfileCircularImage extends StatelessWidget {
  /// name text and image url
  final String? nameText, imageUrl;

  /// size of image
  final double? size;
  /// pick image file
  final XFile? imageFile;

  /// constructor
  const ProfileCircularImage(
      {super.key, this.imageUrl, this.nameText, this.size,this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colorz.primary, width: 2),
          shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(0.5),
        child: ((imageUrl != '' && imageUrl != null)||imageFile!=null)
            ? ViewAppImage(
              imageFile: imageFile,
                height: size ?? 100.sp,
                width: size ?? 100.sp,
                radius: size ?? 100.sp,
                imageUrl: imageUrl,
              )
            : SizedBox(
                height: size ?? 100.sp,
                width: size ?? 100.sp,
                child: CircleAvatar(
                  backgroundColor: Colorz.primary,
                  radius: 100.sp,
                  child: Txt(
                    _getTwoCharacterFromName(nameText),
                    color: Colorz.white,
                  ),
                ),
              ),
      ),
    );
  }

  static String _getTwoCharacterFromName(String? name) {
    if (name != null && name != '') {
      if (name.split(' ').length > 1) {
        if (name.split(' ')[1] != '') {
          return '${name[0].toUpperCase()}${name.split(" ")[1][0].toUpperCase()}';
        } else {
          return name[0].toUpperCase();
        }
      } else {
        return name[0].toUpperCase();
      }
    } else {
      return '';
    }
  }
}

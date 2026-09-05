
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/constants.dart';
import 'Widgets.dart';

/// rating bar
class RatingBarr extends StatelessWidget {
  /// rating
  final double ?rating;
  /// constructor
  const RatingBarr({super.key, this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(SizeConfig.borderRadius)
          ),
          child: Padding(
            padding:  EdgeInsets.all(3.sp),
            child: RatingBar.builder(
                    initialRating: rating ?? 0,
                    minRating: 1,
                    itemSize: 15.sp,
                    unratedColor: Colors.white,
                    allowHalfRating: true,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.cyan,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
          ),
        ),
        SizeConfig.horizontalSpace(),
        Txt(rating,color:  Colorz.blue,),
      ],
    );
  }
}

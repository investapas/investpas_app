// ignore_for_file: deprecated_consistency

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart' as oktoast;

import '../Extensions/Extensions.dart';
import '../core/constants/constants.dart';

import '../core/constants/local/locale_keys.dart';
import '../core/theme/data.dart';
import '../data/models/Widgets/richString.dart';
import '../presentation/bloc/theme/bloc.dart';

part './Button.dart';
part './ColorTile.dart';
part './CrossFade.dart';
part './Expandile.dart';
part './Img.dart';
part './Inkk.dart';
part './Loader.dart';

part './Txt.dart';
part 'Cardd.dart';
part 'Chipp.dart';
part 'ColoredIcon.dart';
part 'Iconbutton.dart';
part 'TxtButton.dart';
part 'TxtField.dart';
part 'Enabler.dart';
part 'ViewAppImage.dart';
part 'richTxt.dart';
part 'appLoading.dart';
part 'theme_button.dart';

@Deprecated('Use Widgets.instance')
///common widget
class Common {

  Common._privateConstructor();
  static final Common _instance = Common._privateConstructor();
  ///instance of common widgets
  static Common get instance => _instance;
}
/// page routes


class FadePageRoute<T> extends PageRouteBuilder<T> {
  /// navigation widget
  final Widget widget;
  /// constructor
  FadePageRoute({required this.widget})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return widget;
            },
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation,
            Widget child) {
              return SlideTransition(
                  transformHitTests: false,
                  position:
                      Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(animation),
                  child: SlideTransition(
                      position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.0))
                          .animate(secondaryAnimation),
                      child: child));
            });
}
/// all Widgets
class Widgets {
  Widgets._privateConstructor();
  static final Widgets _instance = Widgets._privateConstructor();
  ///
  static Widgets get instance => _instance;

/// app decimal place
  static int decimalPlace=2;
  /// app currency symbol
  static String currencySymbol=r'$';
  

/// avatar image url
  static String avatar(String phoneNumberOrRemoteKey) {
    final String fileName = phoneNumberOrRemoteKey.replaceAll('+', '%2B');
    return 'https://firebasestorage.googleapis.com/v0/b/service-ad14a.appspot.com/o/avatars%2F$fileName.jpg?alt=media';
  }
  /// circler loader

  static Widget loadingCircle({Color? color, double size = 26}) {
    return Material(
      type: MaterialType.circle,
      color: color,
      child: SizedBox(
        height: size,
        width: size,
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  ///This will return the darken color of the given value
  static Color darkenColor(Color color, double value) =>
      HSLColor.fromColor(color).withLightness(value).toColor();

/// subtitle Widget
  static Txt subtitle(BuildContext context, String text,
      {TextAlign? textAlign, double? fontSize = 12}) {
    return Txt( text, textAlign: textAlign, fontSize: fontSize, color: subtitleColor(context));
  }
  /// subtitle Color

  static Color subtitleColor(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.color!;
  }

  /// common duration
  static const Duration duration = Duration(milliseconds: 350);
  /// duration for 1 second
  static const Duration duration1Sec = Duration(seconds: 1);
  /// duration for 2 second
  static const Duration duration2Sec = Duration(seconds:2);
  /// duration for 3 second
  static const Duration duration3Sec = Duration(seconds:3);
  /// default curve
  static const Curve curve = Curves.easeIn;
  /// check debugging

  static bool debugging = kDebugMode;
  ///check debugMode
  static bool debugMode = kDebugMode;

  /// tags generte

  static List<String> generateTags(List<dynamic> sentences) {
    final List<String> tags = <String>[];
    for (final dynamic sentence in sentences) {
      if (sentence != null) {
        final List<String> words = '$sentence'.toLowerCase().split(' ');
        for (final String word in words) {
          if (tags.contains(word) == false) {
            tags.add(word);
          }
        }
      }
    }
    return tags
      ..sort((String b, String a) => a.length.compareTo(b.length))
      ..removeWhere((String element) => element.length < 3);
  }

  /// bold heading Text widget
  static Widget boldHeading(String string, {double? left}) {
    return Container(
      padding: EdgeInsets.only(top: 18, bottom: 3, left: left ?? 8),
      alignment: Alignment.centerLeft,
      child: Txt(
         string,
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.start,
        fontSize: 16,
      ),
    );
  }

  ///An [Ios] style tiny arrow widget, which can be used on [ListTile] widgets with customizations
  static Widget arrow({Color? color, bool back = false, double angle = 90}) {
    final Color color0 = color ?? Colors.grey.shade200;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color0.withAlpha(150),
        shape: BoxShape.circle,
      ),
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: Icon(
          back ? Icons.chevron_left : Icons.chevron_right,
          size: 18,
          color: color0,
        ),
      ),
    );
  }

  /// covert to list of string
  static List<String> generateListString(List<dynamic>? list) {
    if (list == null) {
      return <String>[];
    }
    return List<String>.generate(list.length, (int index) => '${list[index]}');
  }

  // static List<Logg> generateLogs(List? list) {
  //   if (list == null) return [];
  //   return List<Logg>.generate((list).length, (index) => Logg.fromJson(list[index]));
  // }
/// get today date
  static String get today => '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';

  // static Future<bool?> call(String number) async {
  // return await FlutterPhoneDirectCaller.callNumber(number);
  // }

  // static Future<void> sendSMS(String phoneNumber, {required String text}) async {
  //   String url = 'sms:$phoneNumber?body=$text';
  //   await launchurl(url);
  // }
  //Parses and returns the [double] without error
  /// null safe double
  static double safeDouble(Json json, String key, {double? orElse}) {
    return double.tryParse('${json[key]}') ?? orElse ?? 0.0;
  }
  /// null safe int
  static int safeInt(Json json, String key, {int? orElse}) {
    ///Sometimes the amount are in double, but the results are treated as [0]
    ///So we are getting to return a [double] and then easily make it as [int]
    return safeDouble(json, key).toInt();
  }
  /// delete widget
  static Widget deleted() {
    return const Center(
      child: Txt(
        'Deleted',
        fontSize: 16,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.center,
      ),
    );
  }
  /// common no data widget
  static Widget noDataAvailable(){
    return const Card(
      child: ListTile(
        title: Text('No data available'),
      ),
    );
  }

  // static RichTxt staffLabel(StaffType type, {String? prefix, int? time}) {
  //   return RichTxt(maxLines: 1, richStrings: [
  //     RichString(_staffTypeLabel(type)),
  //     if (prefix != null) RichString(prefix, color: Colors.grey),
  //     if (time != null) RichString(ago(time), color: Colors.grey),
  //   ]);
  // }

  // static Widget _staffTypeLabel(StaffType type) {
  //   return Container(
  //       child: Txt(
  //         text: type.viewer,
  //         fontSize: 8,
  //         color: Colors.white,
  //       ),
  //       padding: EdgeInsets.all(2),
  //       decoration: BoxDecoration(
  //         color: type.color,
  //         borderRadius: BorderRadius.circular(4),
  //       ));
  // }
  /// show toast message
  static void showToast(dynamic m, {int? seconds}) {
    if ('$m'.contains('Already in tracking')) {
      seconds = 5;
    }
    if (m == 'Failed to process') {
      ///Temporarily hidding as we are going to show custom error messages!
      return;
    }
    String message = '$m';
    debugPrint('Showing toast as $message');

    ///SQL PYTHON SERVER ERRORS

    if (message.contains('404: Not Found')) {
      message = 'End point unavailable';
    }

    if (message.contains('ngrok-free.app not found')) {
      message = 'Server is offline!';
    }
    if (message.contains('Unexpected end of input')) {
      message = 'Some information is missing, please fill them!';
    }
    try {
      oktoast.showToast(
        message,
        duration: Duration(seconds: seconds ?? 2),
        backgroundColor: Colors.grey.shade900,
      );
    } catch (e) {
      debugPrint('Error showing Toast: $e');
    }
  }
  /// Returns a loading indicator widget.
  static Widget loader({
    Color? valueColor,
    Color backgroundColor = Colors.transparent,
    bool centre = true,
    bool useMaterial = false,
    double? size,
  }) {
    final Widget loader = Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: size,
        width: size,
        child: FittedBox(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(valueColor ?? Colorz.primary),
            backgroundColor: backgroundColor,
          ),
        ),
      ),
    );

    final Widget material = useMaterial ? Material(child: loader) : loader;

    final Widget center = centre ? Center(child: material) : material;
    return center;
  }
  /// get time ago from millisecondsSinceEpoch
  static String ago(int millisecondsSinceEpoch, {bool numericDates = true}) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 8) {
      return dateTime.toString().substring(0, 10);
    } else if ((difference.inDays / 7).floor() >= 1) {
      return numericDates ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return numericDates ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return numericDates ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return numericDates ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }

  /// common not found widget
  static Widget notFoundWidget({String? subtitle}) {
    return  Material(
      child: Center(
        child: ListTile(
          title:  Txt(
             'Not found!',
            fontWeight: FontWeight.bold,
            fontSize: 50.sp,
            textAlign: TextAlign.center,
          ),
          subtitle: Txt(
          subtitle?? 'The requested content is not found at this moment.',
            fontSize: 20.sp,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  /// common no access widget

  static Widget noAccess() {
    return const Material(
      child: Center(
        child: Txt(
         'You have no permission to see this content',
          fontSize: 20,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// check is theme is light
  static bool isLight(BuildContext context) => Theme.of(context).brightness == Brightness.light;

  // static Future<bool> sendEmail(String email) async {
  //   bool success = false;
  //   email = email.toLowerCase();
  //   if (email.contains('@')) {
  //     success = true;
  //     await launch("mailto:$email", forceSafariVC: false, forceWebView: false);
  //   } else {
  //     showToast("Email address not found");
  //   }
  //   return success;
  // }
/// copy function
  static Future<void> copy(dynamic text) async {
    await Clipboard.setData(ClipboardData(text: '$text'));
    // showToast("Text copied!");
  }

  // static void debugToast(dynamic message) {
  //   if (debugging) showToast(message);
  // }

  // static void showToast(dynamic message) {
  //   if (debugging) print("$message");
  //   try {
  //     Fluttertoast.showToast(
  //       msg: '$message',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       backgroundColor: Colorz.primaryColor,
  //       textColor: Colors.white,
  //       fontSize: 16,
  //     );
  //   } catch (e) {
  //     print("Error showing Toast: $e");
  //   }
  // }

  ///[filter] Removes all the special characters and spaces
  static String filter(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '').replaceAll('_', '');
  }

  ///Returns the [DateTime] values in a human readable format
  static String timeAgo(
    dynamic input, {
    String? prefix,
  }) {
    DateTime? finalDateTime;

    if (input is DateTime) {
      finalDateTime = input;
    }
    if (input is int) {
      finalDateTime = DateTime.fromMillisecondsSinceEpoch(input);
    }

    ///If the input is not valid, then just return ''
    if (finalDateTime == null) {
      return '';
    }

    final Duration difference = DateTime.now().difference(finalDateTime);
    final bool isPast = finalDateTime.millisecondsSinceEpoch <= DateTime.now().millisecondsSinceEpoch;
    String ago;

    if (difference.inDays > 8) {
      ago = finalDateTime.toString().substring(0, 10);
    } else if ((difference.inDays / 7).floor() >= 1) {
      ago = isPast ? '1 week ago' : '1 week';
    } else if (difference.inDays >= 2) {
      ago = isPast ? '${difference.inDays} days ago' : '${difference.inDays} days';
    } else if (difference.inDays >= 1) {
      ago = isPast ? 'Yesterday' : 'Tomorrow';
    } else if (difference.inHours >= 2) {
      ago = '${difference.inHours} hours ${isPast ? 'ago' : ''}';
    } else if (difference.inHours >= 1) {
      ago = '1 hour ${isPast ? 'ago' : ''}';
    } else if (difference.inMinutes >= 2) {
      ago = '${difference.inMinutes} minutes ${isPast ? 'ago' : ''}';
    } else if (difference.inMinutes >= 1) {
      ago = '1 minute ${isPast ? 'ago' : ''}';
    } else if (difference.inSeconds >= 3) {
      ago = '${difference.inSeconds} seconds ${isPast ? 'ago' : ''}';
    } else {
      ago = isPast ? 'Just now' : 'now';
    }
    return prefix == null ? ago : '$prefix $ago';
  }

  /// int to dateTime
  static String toDateTime(int createdAt) {
    return '${toDate(createdAt)} @ ${toTime(createdAt)}';
  }

  /// int to date
  static String toDate(int createdAt, {bool showFullYear = true, bool showYear = true}) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final int day = date.day;
    final int month0 = date.month;
    final String month = toMonth(month0);
    final String year = showYear ? toYear(createdAt, showFullYear: showFullYear) : '';
    return '$day $month $year';
  }
/// int to time
  static String toTime(int createdAt) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final int hour = date.hour > 12 ? (date.hour - 12) : date.hour;
    final String minutes = date.minute < 10 ? '0${date.minute}' : '${date.minute}';
    final String amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minutes $amPm';
  }

  /// int to year
  static String toYear(int createdAt, {bool showFullYear = true}) {
    final int yr = DateTime.fromMillisecondsSinceEpoch(createdAt).year;
    return showFullYear ? '$yr' : '$yr'.substring(0, 2);
  }
/// int to month
  static String toMonth(int month) {
    return month > 0 ? months[month - 1] : '$month';
  }
/// months of year
  static const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // static Future<void> launchurl(String? url, {bool inApp = false}) async {
  //   try {
  //     if (url != null) {
  //       print("URL: $url");
  //       await launch(url, forceSafariVC: inApp, forceWebView: inApp);
  //     } else {
  //       showToast("No url!");
  //     }
  //   } catch (exception) {
  //     showToast("Error $exception");
  //   }
  // }

  /// wait widget
  static Future<void> wait([int milliseconds = 350]) async {
    await Future<void>.delayed(Duration(milliseconds: milliseconds));
  }
/// push to page
  static void push(
      Widget? page,
      BuildContext context, {
        bool fullScreen = true,
        bool barrierDismissible = true,
        ///Customized width of the screen
        double? screenWidth,
      }) {
    if (page != null) {
      showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext builder) {
          if (fullScreen) {
            final Widget widget = Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: page,
                ),
              ),
            );
            if (screenWidth != null) {
              return Container(
                color: Colors.green,
                width: double.maxFinite,
                alignment: Alignment.center,
                child: SizedBox(
                  width: screenWidth,
                  child: widget,
                ),
              );
            }
            return widget;
          }
          return Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Inkk(
                    onTap: () {
                      if (barrierDismissible) {
                        Widgets.pop(context);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: double.maxFinite,
                      width: double.maxFinite,
                      color: Colors.black26,
                    ),
                  ),
                ),
                SizedBox(
                  width: 480,
                  child: Material(
                    color: Colors.transparent,
                    child: page,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      showToast('No destination page found');
    }
  }

  @Deprecated('Use pop')
  /// close page
  static void close(BuildContext context) => pop(context);

  /// navigation pop
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  /// height of the screen
  static double mHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
/// width of the screen
  static double mWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// empty widget
  static Widget empty() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Icon(
            Icons.delete,
            size: 100,
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  /// common divider
  static Widget divider({Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Divider(
        height: 4.5,
        color: color,
      ),
    );
  }

  /// common heading
  static Widget heading({dynamic text,Color ?color,double ?fontSize}) {
    return Txt(
      text,
      fontSize: fontSize??SizeConfig.largeFont,
      color: color??Colors.black,
      fontWeight: FontWeight.bold,
    );
  }

  /// off Header widget
  static Widget offHeader(bool hide, dynamic text) {
    return Offstage(
      offstage: hide,
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.only(top: 20, left: 6),
        child: Txt(
           text,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  static Timer? _timer;

  ///A callback which will not execute the given action until a time meets
  ///Eg:used in text field along with http calls
  static void bouncer(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(duration, action);
  }
}

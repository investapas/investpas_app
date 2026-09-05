part of 'constants.dart';

/// This class provides static color constants.
class Colorz {
  /// Private constructor to prevent instantiation of this class.
  Colorz._();

  ///Primary colors of the app
  static const Color primary = Color(0xff436AF5);
  ///darkPrimary colors of the app
  static const Color darkPrimary = Color(0xff2D4EC3);
  ///blue colors of the app
  static const Color blue = Color(0xff147ef1);
  ///blueAccent colors of the app
  static const Color blueAccent = Color(0xff08679a);
  ///offWhite colors of the app
  static const Color offWhite = Color(0xfff2f2f2);
  ///lightBlue colors of the app
  static const Color lightBlue = Color(0xFF4269F2);
  ///skyBlue colors of the app
  static const Color skyBlue = Color(0xFFA4B8FF);
  ///skyBlue colors of the app
  static const Color backgroundColor1 = Color(0xFFE8EEFF);
  ///skyBlue colors of the app
  static const Color backgroundColor2 = Color(0xFFF5F7FF);

  static const Color textColor = Color(0xFF333A40);

  static const Color hintTextColor = Color(0xFF7D8D9D);
  static const Color hintTextColor2 = Color(0xFF5D6975);
  static const Color lightTextColor = Color(0xFFB5C5FF);
  static const Color profileBgColor = Color(0xFFF0F3FF);

  static const Color bottomPillBg = Color(0xFFECF0FD);
  static const Color lightWhiteColor = Color(0xFFDAE2FF);

  static const Color lightPrimary = Color(0xFFC1CEFF);

  static const Color ruleSummaryColor1 = Color(0xFFCCE1FF);
  static const Color ruleSummaryColor2 = Color(0xFFECF2FB);
  static const Color dividerColor = Color(0xFFDFEAF4);
  static const Color textFieldBorderColor = Color(0xFFABC0D4);

  static const Color lineColor = Color(0xFFF8F8F8);
  static const Color calenderDateBg = Color(0xFFF4F4F4);
  static const Color calenderDayColor = Color(0xFFB5B5B5);
  static const Color lightRedColor = Color(0xFFD88388);
  static const Color redColor = Color(0xFFFF3737);
  static const Color redBgColor = Color(0xFFFFE6E6);
  static const Color greenColor = Color(0xFF3AAE00);
  static const Color lightPurpleColor = Color(0xFFF4F1F8);
  static const Color purpleColor = Color(0xFF6951A9);
  static const Color borderColor = Color(0xFFE2E2E2);
  static const Color dividerProfileColor = Color(0xFFF0F0F0);
  static const Color progressBgColor = Color(0xFFE5E7EB);
  static const Color progressBarColor = Color(0xFF9FB4FF);
  static const Color linkColor = Color(0xFFA6BAFF);
  static const Color hintColor3 = Color(0xFFACACAC);
  static const Color newsBg = Color(0xFFF8F9FF);

  static const Color strongSellColor = Color(0xFFDD0000);
  static const Color sellColor = Color(0xFFF97979);
  static const Color neutralColor = Color(0xFF616161);
  static const Color buyColor = Color(0xFF90F24F);
  static const Color strongBuyColor = Color(0xFF4EA117);
  static const Color buyBgColor = Color(0xFFF7F7F7);
  static const Color newBorderColor = Color(0xFFE7E7E7);
  static const Color buyNewBgColor = Color(0xFFEFF6FF);
  static const Color sellNewBgColor = Color(0xFFFFEDED);
  static const Color sellButtonColor = Color(0xFFF54343);
  static const Color sellLightButtonColor = Color(0xFF530000);

  ///white colors of the app
  static const Color white = Colors.white;

  ///black colors of the app
  static const Color black = Colors.black;
  ///drawerColor colors of the app
  static const Color drawerColor = Colors.white;

  ///red colors of the app
  static const Color red = Colors.redAccent;

  ///gray colors of the app
  static const Color gray = Colors.grey;

  ///canvasColor colors of the app
  static Color canvasColor = Colors.white;

  ///green colors of the app
  static Color green = Colors.green;

  ///primary dark colors of the app
  static Color get dark => primary.dark();

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primary,
      darkPrimary
    ],
  );

  static const LinearGradient whiteButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      white,
      lightWhiteColor
    ],
  );

  static const LinearGradient summaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      ruleSummaryColor1,
      ruleSummaryColor2
    ],
  );

  static const LinearGradient sellButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      sellButtonColor,
      sellLightButtonColor
    ],
  );

}

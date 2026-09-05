part of './Widgets.dart';

///Including user app
///A customized simple to use represenation wrap widget of the [RichText]
class RichTxt extends StatelessWidget {
  ///TextAlign.center, left, right
  final TextAlign? textAlign;

  ///Bold, Normal
  final FontWeight? fontWeight;

  ///It defines the size of text
  final double? fontSize;

  ///Italic, Normal
  final FontStyle? fontStyle;

  ///Color of the text
  final Color? color;

  ///List of children to be rendered dynamically
  final List<RichString> richStrings;

  ///If enabled it will add a space between two [RichStrings]
  final bool autoSpacing;

  ///It defines the number of lines to be shown
  final int? maxLines;

  ///Constructor
  const RichTxt({
    super.key,
    this.textAlign,
    this.fontWeight,
    this.fontSize,
    this.fontStyle,
    this.color,
    required this.richStrings,
    this.autoSpacing = true,
    this.maxLines,
  });
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      text: TextSpan(
        style: TextStyle(
          fontWeight: fontWeight ?? FontWeight.normal,
          fontSize: fontSize,
          fontStyle: fontStyle,
          color: color ?? Theme.of(context).textTheme.bodyLarge!.color,
        ),
        children: richStrings.map((RichString richString) {
          final bool isFirst = richStrings.indexOf(richString) == 0;
          if (richString.child is Widget) {
            return WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(left: autoSpacing ? (isFirst ? 0 : 2) : 0),
                child: richString.child as Widget,
              ),
            );
          }
          final String _textString = richString.child as String;
          return TextSpan(
            text: autoSpacing ? "${isFirst ? '' : ' '}$_textString" : _textString,
            style: TextStyle(
              fontWeight: richString.fontWeight,
              fontSize: richString.fontSize,
              fontStyle: richString.fontStyle,
              color: richString.color,
              decoration: richString.lineThrough
                  ? TextDecoration.lineThrough
                  : (richString.underline ? TextDecoration.underline : null),
            ),
            recognizer: TapGestureRecognizer()..onTap = richString.onTap,
          );
        }).toList(),
      ),
    );
  }
}

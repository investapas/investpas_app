part of 'Widgets.dart';

/// A customized text widget that provides various text formatting options.
class Txt extends StatefulWidget {
  /// The font style to be applied to the text.
  final FontStyle? style;

  /// The font weight to be applied to the text.
  final FontWeight? fontWeight;

  /// The maximum number of lines allowed for the text.
  final int? maxlines;

  /// The font size of the text.
  final double? fontSize;

  /// The color of the text.
  final Color? color;

  /// The alignment of the text within the widget.
  final TextAlign? textAlign;

  /// Whether to use text overflow ellipsis when the text overflows its container.
  final bool useoverflow;

  /// Whether to capitalize the first letter of the text.
  final bool upperCaseFirst;

  /// Whether to enclose the text in quotation marks (❝...❞).
  final bool quoted;

  ///To
  final bool useFiler;

  ///To give an underline
  final bool underline;

  ///to Upper case everything
  final bool fullUpperCase;

  ///Any input
  final dynamic text;

  ///Font family
  final String? family;

  ///To insert a currency symbol along with decimal placement
  final bool toCurrency;

  ///Prefix if toTimeAgo is used
  final String? prefix;

  ///To strike the text
  final bool strikeThrough;

  /// textStyle
 final TextStyle? textStyle;

  ///Constructor
  const Txt(
      this.text, {
        super.key,
        this.textStyle,
        this.style,
        this.fontWeight,
        this.maxlines,
        this.fontSize,
        this.color,
        this.textAlign,
        this.useoverflow = false,
        this.upperCaseFirst = false,
        this.quoted = false,
        this.useFiler = false,
        this.underline = false,
        this.fullUpperCase = false,
        this.family,
        this.prefix,
        this.toCurrency = false,
        this.strikeThrough = false,
      });

  @override
  _TxtState createState() => _TxtState();
}

class _TxtState extends State<Txt> {
  String finalText = ''; // finalText = strings.english;

  @override
  Widget build(BuildContext context) {
    if (widget.text is String) {
      finalText = widget.text?.toString() ?? 'Error';
    } else if (widget.text is double || widget.text is int) {
      if (widget.toCurrency) {
        double amount = 0.0;
        if (widget.text is double) {
          amount = widget.text as double;
        }
        if (widget.text is int) {
          amount = (widget.text as int).toDouble();
        }
        finalText = amount.toCurrency;
      } else {
        ///If not to be shown as currency, then show as it is.
        finalText = '${widget.text}';
      }
    } else if (widget.text is DateTime) {
      finalText = Widgets.toDate(widget.text);
    } else {
      finalText = widget.text.toString();
    }

    if (widget.upperCaseFirst) {
      finalText = finalText.upperCaseFirst;
    }

    if (widget.quoted) {
      finalText = '❝$finalText❞';
    }

    if (widget.useFiler) {
      finalText = finalText
          .replaceAll('*', '')
          .replaceAll('_', '')
          .replaceAll('-', '')
          .replaceAll('#', '')
          .replaceAll('\n', '')
          .replaceAll('!', '')
          .replaceAll('[', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll(']', '');
    }
    if (widget.fullUpperCase) {
      finalText = finalText.toUpperCase();
    }

    return Text(
      finalText,
      overflow: widget.useoverflow ? TextOverflow.ellipsis : null,
      textAlign: widget.textAlign,
      maxLines: widget.maxlines,
      textScaler: TextScaler.noScaling,
      style: widget.textStyle?? TextStyle(
        decoration: widget.underline
            ? TextDecoration.underline
            : (widget.strikeThrough ? TextDecoration.lineThrough : null),
        color: widget.color??AppThemeData.textColor,
        fontSize: (widget.fontSize ?? 14) - 2,
        fontWeight: widget.fontWeight ?? FontWeight.w700,
        fontStyle: widget.style,
        fontFamily: widget.family,
      ),
    );
  }
}

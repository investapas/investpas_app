part of 'Widgets.dart';
/// common Text button
class TxtButton extends StatelessWidget {
  /// title of the text
  final String ?text;
  /// onPressed function of text button
  final VoidCallback? onPressed;
  /// title color
  final Color ?color;
  /// text align
  final TextAlign? textAlign;
  /// constructor
  const TxtButton({super.key,this.text,this.onPressed,this.color,this.textAlign});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child:  Txt(text??'', color: color??Colorz.blueAccent,
      textAlign: textAlign,
      fontSize: 17.sp,),
    );
  }
}

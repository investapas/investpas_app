part of 'Widgets.dart';

/// common Ink widget of app
class Inkk extends StatelessWidget {
  /// child of ink widget
  final Widget child;
  /// spalshColor of widget
  final Color? spalshColor;
  /// radius of the widget
  final double? radius;
  /// onTap widget function
  final VoidCallback? onTap;
  /// tooltip of the widget
  final String? tooltip;
  /// enable/disable ink widget
  final bool disable;
/// constructor
  const Inkk(
      {super.key,
      required this.child,
      this.onTap,
      this.radius,
      this.spalshColor,
      this.tooltip,
      this.disable = false,
      });

 
  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius ?? 8);
    return Semantics(
       label: tooltip??'Button',
        child: ClipRRect(
        borderRadius: borderRadius,
          child: stack(borderRadius),
       ),
     );
  }  
/// 
  Widget stack(BorderRadius borderRadius){
    return Stack(
              children: <Widget>[
                child,
                 if(disable==false) Positioned.fill(
                 child: Material(
                  color: Colors.transparent,
                  borderRadius: borderRadius,
                  child: InkWell(
                    highlightColor: (spalshColor?? Colorz.primary).withAlpha(35),
                    splashColor: (spalshColor?? Colorz.primary).withAlpha(250),
                    onTap: onTap?? (){},
                  ),
                )
              ),
              ],
            );
  }
}

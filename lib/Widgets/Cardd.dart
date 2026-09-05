part of './Widgets.dart';

/// app common card widget
class Cardd extends StatelessWidget {
  /// card child
  final Widget? child;

  /// color of card
  final Color? color;

  /// margin of card
  final EdgeInsets? padding;

  /// border side of card
  final BorderSide? side;

  /// card elevation
  final double? elevation;

  /// card border color
  final Color? borderColor;

  /// card height and width
  final double? height, width;
  /// card radius
  final double? radius;

  /// constructor
  const Cardd(
      {super.key,
      this.height,
      this.radius,
      this.width,
      this.child,
      this.padding,
      this.elevation,
      this.side,
      this.color,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(radius??SizeConfig.borderRadius),
          boxShadow: SizeConfig.appShadow,
          border: Border.all(color: Colors.grey.withAlpha(50)),
        ),
        child: child);
  }
}

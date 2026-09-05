part of './Widgets.dart';

///A small widget to make the given widget as [enabled] or [disabled]
///A best alternative for [CrossFade]
class Enabler extends StatelessWidget {
  ///Child to be enabled or disabled
  final Widget child;

  ///To enable or disable
  final bool enabled;

  ///Disabled color
  final Color? color;

  ///Opacity when disabled
  final double? opacity;

  ///Constructor
  const Enabler({
    super.key,
    required this.enabled,
    required this.child,
    this.color,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return child;
    } else {
      return Opacity(opacity: opacity ?? 0.25, child: Inkk(child: child));
    }
  }
}

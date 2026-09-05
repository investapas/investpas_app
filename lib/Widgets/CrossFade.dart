part of 'Widgets.dart';

/// common CrossFade widget
class CrossFade extends StatelessWidget {
  /// The widget to be displayed when [show] is true.
  final Widget child;

  /// The widget to be displayed when [show] is false. If null, an empty Container() is used.
  final Widget? hiddenChild;

  /// A boolean flag to determine whether to show the [child] or the [hiddenChild].
  final bool show;

  /// The padding around the CrossFade widget.
  final EdgeInsets? padding;

  /// A flag to specify whether the [child] should be wrapped inside a Center widget.
  final bool useCenter;

  /// The duration of the cross-fade animation. Defaults to 500 milliseconds.
  final Duration? duration;

  /// Constructor for the CrossFade widget.
  const CrossFade({
    super.key,
    required this.show,
    required this.child,
    this.hiddenChild,

    this.padding,
    this.useCenter = true,
    this.duration,
  });

  /// Build method for the CrossFade widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: AnimatedCrossFade(
        firstChild: hiddenChild ?? Container(),
        secondChild: childX(),
        duration: duration ?? const Duration(milliseconds: 500),
        crossFadeState: show ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      ),
    );
  }

  /// Returns the child widget wrapped inside a Center widget if [useCenter] is true,
  /// otherwise returns the child widget as it is.
  Widget childX() {
    if (useCenter) {
      return Center(child: child);
    }
    return child;
  }
}

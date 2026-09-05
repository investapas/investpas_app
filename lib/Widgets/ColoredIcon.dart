part of 'Widgets.dart';
/// A custom widget that displays an icon with a colored background.
class ColoredIcon extends StatelessWidget {
  /// The data of the icon to be displayed.
  final IconData icon;

  /// The color of the icon.
  final Color iconColor;

  /// The color of the background.
  final Color backgroundColor;

  /// A callback function that will be executed when the icon is pressed.
  final VoidCallback? onPressed;

  /// The tooltip text to be shown when the user hovers over the icon.
  final String? tooltip;

  /// The size of the icon.
  final double? size;

  /// The padding around the icon.
  final double padding;

  /// Constructor for the ColoredIcon widget.
  const ColoredIcon({
    super.key,
    this.size = 18,
    this.padding = 4,
    required this.icon,
    this.iconColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return onPressed == null
        ? stack()
        : IconButton(
            icon: stack(),
            onPressed: onPressed,
            tooltip: tooltip,
          );
  }

  /// Builds the stack of widgets that include the background and the icon.
  Widget stack() {
    return Stack(
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      children: <Widget>[
        background(),
        Icon(icon, color: iconColor, size: size),
      ],
    );
  }

  /// Builds the background container for the icon.
  Widget background() {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size, color: backgroundColor),
    );
  }
}

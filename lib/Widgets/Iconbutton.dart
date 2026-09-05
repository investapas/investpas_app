part of './Widgets.dart';

/// A stateful widget that represents an icon button.
class Iconbutton extends StatefulWidget {
  /// The icon to be displayed in the button.
  final Object icon;

  /// The color of the button. This can be nullable.
  final Color? color;

  /// The size of the button. This can be nullable.
  final double? size;

  /// The tooltip to be shown when the button is hovered.
  final String? tooltip;

  /// The callback function to be executed when the button is pressed.
  final dynamic onPressed;

  ///Custom padding between icon area
  final EdgeInsets? padding;

  ///Let say the icon is square or circle and want to fill the background color
  final Color? fillColor;

  ///Radius of the filling background eg: square or circle
  final double? fillRadius;

  /// Constructs an Iconbutton widget.
  const Iconbutton({
    super.key,
    required this.icon,
    this.color,
    this.size,
    this.tooltip,
    this.onPressed,
    this.padding,
    this.fillColor,
    this.fillRadius,
  });

  @override
  State<Iconbutton> createState() => _IconbuttonState();
}

/// The state class for the Iconbutton widget.
class _IconbuttonState extends State<Iconbutton> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding:
      widget.padding ?? ((isProcessing || widget.icon != IconData) ? EdgeInsets.zero : null),
      icon: isProcessing
          ? Widgets.loader(size: 15, valueColor: widget.color)
          : Container(
        decoration: BoxDecoration(
          color: widget.fillColor,
          borderRadius: BorderRadius.circular(widget.fillRadius ?? 0),
        ),
        child: icon,
      ),
      tooltip: widget.tooltip,
      onPressed: () async {
        if (widget.onPressed == null) {
          return;
        }
        print('te');
        if (isProcessing) {
          Widgets.showToast('Processing...');
          return;
        }
        if (mounted) {
          setState(() => isProcessing = true);
        }
        final bool isAsync = widget.onPressed.runtimeType.toString().contains('Future');

        if (isAsync) {
          await widget.onPressed!();
        } else {
          widget.onPressed!();
        }
        if (mounted) {
          setState(() => isProcessing = false);
        }
      },
    );
  }

  /// Returns the appropriate icon widget based on the icon type.
  Widget get icon {
    if (widget.icon is Icon) {
      return widget.icon as Icon;
    }
    if (widget.icon is IconData) {
      return Icon(
        widget.icon as IconData,
        color: widget.color,
        size: widget.size,
      );
    }
    if (widget.icon is Widget) {
      return widget.icon as Widget;
    }
    return Txt(
      widget.icon,
      maxlines: 1,
      color: widget.color,
      fontSize: widget.size,
    );
  }
}

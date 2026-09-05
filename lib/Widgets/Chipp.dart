part of './Widgets.dart';

/// A custom [Chip] widget which extends the standard [Chip] with additional features.
///
/// The `Chipp` widget allows you to create a customized [Chip] with various options
/// like custom colors, icons, and handling of user interactions. It can be used to
/// represent tags, categories, or any other items in a visually appealing way.
class Chipp extends StatelessWidget {
  /// The text displayed inside the chip.
  final String text;

  /// The maximum length of the text shown in the chip. If the text exceeds this length,
  /// it will be truncated and followed by an ellipsis (...)
  final int maxLength;

  /// Whether the chip is in a selected state or not.
  final bool selected;

  /// The background color of the chip when it is in the selected state.
  final Color? color;

  /// The background color of the chip when it is not in the selected state.
  final Color? unSelectedColor;

  /// A callback function that will be invoked when the chip is tapped.
  final VoidCallback? onPressed;

  /// A callback function that will be invoked when the chip's delete icon is tapped.
  final VoidCallback? onDeleted;

  /// The icon displayed on the chip. It can be an IconData or a custom Widget.
  final dynamic icon;

  /// The padding applied around the chip's content.
  final double padding;

  /// The color of the icon displayed on the chip. If not provided, it will use the
  /// [textColor] when the chip is in the selected state, or [Colors.white] otherwise.
  final Color? iconColor;

  ///Color of the unselected text
  final Color? unselectedTextColor;

/// selected Text color 
  final Color? selectedTextColor;

  /// Constructor for creating a [Chipp] widget.
  ///
  /// The [key] parameter is an optional identifier for this widget.
  const Chipp({
    super.key,
    required this.text,
    this.maxLength = 10,
    this.selected = false,
    this.color,
    this.unSelectedColor,
    this.onPressed,
    this.onDeleted,
    this.padding = 8,
    this.icon,
    this.iconColor,
    this.unselectedTextColor,
    this.selectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        selected ? color ?? Colorz.primary : (unSelectedColor ?? Colors.grey);
    final Color? textColor = (selected ? selectedTextColor : unselectedTextColor);
    
    Widget? avatar;
    if (icon is IconData) {
      avatar = Icon(
        icon as IconData,
        size: 18,
        color: iconColor ?? textColor,
      );
    }
    if (icon is Widget) {
      avatar = icon as Widget;
    }
    return AnimatedPadding(
      duration: Widgets.duration,
      padding: EdgeInsets.symmetric(horizontal: padding + (selected ? 2 : 0)),
      child: GestureDetector(
        onTap: onPressed,
        child: Chip(
          backgroundColor: backgroundColor,
          avatar: avatar,
          onDeleted: selected ? onDeleted : null,
          label: Txt(
            text.characters.length < maxLength ? text : text.substring(0, maxLength - 1),
            color: textColor,
          ),
        ),
      ),
    );
  }
}

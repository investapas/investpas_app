part of 'Widgets.dart';

/// common Button
class Button extends StatefulWidget {

  //gradient color
  final Gradient? gradient;

  /// button icon
  final dynamic icon;

  /// task completed icon
  final dynamic onTaskCompletedIcon;

  /// button text
  final dynamic text;

  /// processing text
  final String? processingText;

  /// completed text
  final String? ontaskCompletedText;

  /// text color
  final Color? textColor;

  /// radius of button
  final double? radius;

  /// onPressed function of button
  final Function onPressed;

  /// button color
  final Color? buttonColor;

  /// text size
  final double? fontSize;

  /// icon size
  final double iconSize;

  /// max text lines
  final int? maxLines;

  /// button width
  final double? width;

  /// button padding
  final EdgeInsets? padding;

  /// text fontWeight
  final FontWeight? fontWeight;

  /// first text Capital enable/disable
  final bool upperCaseFirst;

  /// is big size button
  final bool isBig;

  /// elevation of button
  final double elevation;

  /// is outline of button
  final bool isOutlined;

  /// enable/disable void onPressed function
  final bool isVoid;

  ///On some times, the [onPressed] function is called out of the button
  ///For example, pressing the [Enter] key from a [TextField],
  ///to simulate this button as pressed by hand, we can pass [simulating] as [true]
  final bool? simulating;

  ///Optional color of the circular progress indicator
  final Color? valueColor;

  /// constructor
  const Button({
    super.key,
    this.gradient,
    this.isBig = false,
    this.isOutlined = true,
    this.simulating,
    this.fontSize,
    this.iconSize = 20,
    this.icon,
    this.text,
    this.textColor,
    this.radius = 8,
    this.onPressed = invalidAction,
    this.buttonColor,
    this.maxLines,
    this.width,
    this.fontWeight,
    this.upperCaseFirst = false,
    this.processingText,
    this.ontaskCompletedText,
    this.onTaskCompletedIcon,
    this.elevation = 1,
    this.isVoid = false,
    this.valueColor,
    this.padding,
  });

  ///Used in [tools] of the filterview in most cases
  factory Button.add(BuildContext context,
      {required Widget page,
      bool fullScreen = false,
      bool barrierDismissible = true}) {
    return Button(
      isVoid: true,
      icon: Icons.add,
      text: 'Add',
      processingText: 'Adding',
      onPressed: () {
        Widgets.push(page, context,
            fullScreen: fullScreen, barrierDismissible: barrierDismissible);
      },
    );
  }

  ///Used to submit a master
  factory Button.submit({
    required Function submitFn,
    required VoidCallback showErrorFn,
    required bool isValid,
    Color? buttonColor,
    double? radius,
    double elevation = 2.5,
  }) {
    return Button(
      elevation: elevation,
      radius: radius,
      width: double.infinity,
      buttonColor: buttonColor ??
          (isValid ? Colorz.primary : Colorz.primary.withAlpha(40)),
      text: 'Submit',
      fontWeight: FontWeight.bold,
      processingText: 'Submitting...',
      onPressed: isValid ? submitFn : showErrorFn,
    );
  }

  ///Used to Addd/Update a master
  factory Button.addUpdate({
    required bool toEdit,
    bool isMini = false,
    String? text,
    required Function completeFn,
    required VoidCallback showErrorFn,
    required bool isValid,
    Color? buttonColor,
    double? radius,
    double elevation = 2.5,
  }) {
    return Button(
      elevation: elevation,
      radius: radius,
      width: isMini ? null : double.infinity,
      icon: toEdit ? Icons.save : Icons.add,
      buttonColor: buttonColor ?? (isValid ? Colorz.primary : Colors.grey),
      text: text ?? (toEdit ? 'Save' : 'Add'),
      processingText: toEdit ? 'Saving...' : 'Adding',
      onPressed: isValid ? completeFn : showErrorFn,
    );
  }

  ///Used in [Footers] of [GriddView]
  factory Button.save({
    required Function saveFn,
    double? width,
    bool isValid = true,
    Color? buttonColor,
    bool isBig = false,
  }) {
    return Button(
      isBig: isBig,
      width: width,
      icon: Icons.check,
      text: 'Save',
      processingText: 'Saving...',
      onPressed: saveFn,
      buttonColor: isValid ? buttonColor ?? Colorz.primary : Colors.grey,
    );
  }

  @override
  _ButtonState createState() => _ButtonState();

  /// invalid action button
  static Future<void> invalidAction() async {
    debugPrint('Invalid Action');
  }
}

class _ButtonState extends State<Button> {
  bool processing = false;
  bool processed = false;

  @override
  void initState() {
    if (widget.simulating != null) {
      processing = widget.simulating!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      height: widget.isBig ? 48.sp : 48.sp,
      width: widget.width ?? double.infinity,
      padding: widget.padding ?? EdgeInsets.zero,
      decoration: widget.gradient != null
          ? BoxDecoration(
        gradient: widget.gradient,
        borderRadius: shape.borderRadius,
      )
          : BoxDecoration(
        color: _buttonColor,
        borderRadius: shape.borderRadius,
      ),

      child: finalButton(),
    );
  }

  Widget finalButton() {
    if (isIconButton) {
      return iconButton();
    } else {
      return normalButton();
    }
  }

  Widget iconButton() {
    if (widget.isOutlined) {
      return OutlinedButton.icon(
        icon: iconWidget(),
        style: outlinedButtonStyle,
        label: txtWidget(),
        onPressed: onPressed,
      );
    } else {
      return ElevatedButton.icon(
        icon: iconWidget(),
        label: txtWidget(),
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor:
          MaterialStateProperty.all(Colors.transparent),
          shadowColor:
          MaterialStateProperty.all(Colors.transparent),
          surfaceTintColor:
          MaterialStateProperty.all(Colors.transparent),
          overlayColor:
          MaterialStateProperty.all(Colors.transparent),
          elevation: MaterialStateProperty.all(0),
          padding:
          MaterialStateProperty.all(EdgeInsets.zero),
          minimumSize:
          MaterialStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: MaterialStateProperty.all(shape),
        ),
      );
    }
  }

  Widget normalButton() {
    if (widget.isOutlined) {
      return OutlinedButton(
        style: outlinedButtonStyle,
        onPressed: onPressed,
        child: txtWidget(),
      );
    }

    if (widget.gradient != null) {
      return SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.isBig ? 48.sp : 48.sp,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: shape.borderRadius,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: shape,
            ),
            child: Center(
              child: processing
                  ? SizedBox(
                height: 24.sp,
                width: 24.sp,
                child: Widgets.loader(
                  valueColor: widget.valueColor ?? Colors.white,
                ),
              )
                  : txtWidget(),
            ),
          ),
        ),
      );
    }

    return ElevatedButton(
      style: textButtonStyle,
      onPressed: onPressed,
      child: txtWidget(),
    );
  }

  Widget txtWidget() {
    if (processing) {
      return const SizedBox.shrink();
    }

    dynamic finalText;
    if (processed) {
      finalText = widget.ontaskCompletedText;
    }
    finalText ??= widget.text;

    return Txt(
      finalText,
      fontSize: widget.isBig ? 18 : widget.fontSize,
      fontWeight: widget.fontWeight,
      maxlines: widget.maxLines ?? 1,
      useoverflow: true,
      color: _textColor,
      upperCaseFirst: widget.upperCaseFirst,
      family: 'Inter',
    );
  }

  Widget iconWidget() {
    Widget? child;
    final dynamic icon =
        processed ? (widget.onTaskCompletedIcon ?? widget.icon) : widget.icon;
    if (icon is IconData) {
      child = Icon(icon, color: _textColor, size: widget.iconSize);
    }
    if (icon is Widget) {
      child = icon;
    }
    if (processing) {
      child = SizedBox(
          height: widget.isBig ? 35.sp : 32.sp,
          child: Widgets.loader(valueColor: widget.valueColor ?? Colors.white));
    }
    return child!;
  }

  Future<void> onPressed() async {
    if (processing) {
      Widgets.showToast('Processing...');
      return;
    } else {
      ///If the function is a not using [async] we don't need to process it to avoid [loading] indication
      if (widget.isVoid) {
        widget.onPressed();
        return;
      }
      if (mounted) {
        setState(() {
          processing = true;
          processed = false;
        });
      }
      await Widgets.wait();
      try {
        await widget.onPressed();
      } catch (e) {
        Widgets.showToast('Error: $e');
      }
      if (mounted) {
        await Widgets.wait();
        if (mounted) {
          setState(() {
            processing = false;
            processed = true;
          });
        }
      }
    }
  }

  bool get isIconButton => widget.icon != null || processing == true;

  Color? get _textColor {
    if (widget.isOutlined) {
      return widget.textColor ?? Colorz.white;
    } else {
      ///As the primary color is [Teal], the black is not matching. So manually setting it to white.
      ///This will work until the primary color is changed from teal to some other.
      if (widget.buttonColor == Colorz.primary) {
        return Colors.white;
      }
      return widget.textColor ?? bc.readable;
    }
  }

  Color get bc => widget.buttonColor ?? Colorz.primary;

  Color get _darkenButtonColor =>
      HSLColor.fromColor(bc).withLightness(0.45).toColor();

  Color get _buttonColor => processing ? _darkenButtonColor : bc;

  ButtonStyle get textButtonStyle => TextButton.styleFrom(
        backgroundColor: _buttonColor,
        shape: shape,
        shadowColor: widget.buttonColor,
        elevation: widget.elevation,
      );

  ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
        shadowColor: _buttonColor,
        disabledForegroundColor: _buttonColor,
        foregroundColor: _buttonColor,
        backgroundColor: _buttonColor,
        side: const BorderSide(
          color: Colorz.primary,
          width: 2,
        ),
        shape: shape,
      );

  RoundedRectangleBorder get shape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          widget.radius ?? 6,
        ),
      );
}

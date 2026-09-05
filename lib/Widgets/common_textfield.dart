import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:investapas/core/constants/constants.dart';

class CommonTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isPasswordfield;
  final String? Function(String?)? validator;
  final TextStyle? textStyle;
  final InputDecoration? inputDecoration;
  final String? suffixIcon;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputFormatter ? textInputFormatter;
  final Function(String)?  onChanged;
  final VoidCallback? onTap;
  final Widget? prefixWidget;
  final Widget? suffixWidget;

  const CommonTextfield(
      {super.key,
      required this.controller,
      required this.hintText,
      this.keyboardType = TextInputType.text,
      this.isPassword = false,
      this.isPasswordfield = false,
      this.validator,
      this.textStyle,
      this.inputDecoration,
      this.suffixIcon,
        this.readOnly = false,
      this.maxLines = 1,
      this.maxLength,
      this.onChanged,
        this.textInputFormatter,
        this.onTap,
        this.prefixWidget,
        this.suffixWidget
      });

  @override
  State<CommonTextfield> createState() => _CommonTextfieldState();
}

class _CommonTextfieldState extends State<CommonTextfield> {
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = widget.isPassword == false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      cursorColor: Colorz.textColor,
      obscureText: widget.isPassword ? !_passwordVisible : false,
      autovalidateMode: AutovalidateMode.disabled,
      validator: widget.validator,
      onTap: widget.onTap ?? null,
      style: widget.textStyle ?? AppTextStyles.medium.copyWith(color: Colorz.textColor),
      textAlign: TextAlign.start,
      decoration: widget.inputDecoration ??
          InputDecoration(
            helperText: "",
            errorStyle: const TextStyle(height: 0),
            helperStyle: const TextStyle(height: 0),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: AppTextStyles.medium.copyWith(color: Colorz.textColor),
            hintText: widget.hintText,
            hintStyle: AppTextStyles.small.copyWith(color: Colorz.hintTextColor),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colorz.textFieldBorderColor, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colorz.redColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colorz.textFieldBorderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colorz.textFieldBorderColor, width: 1),
            ),
            filled: false,
            counterText: '',
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            prefixIcon: widget.prefixWidget == null
                ? null
                : Align(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: widget.prefixWidget,
              ),
            ),
            suffixIcon: widget.suffixWidget == null
                ? null
                : Align(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: widget.suffixWidget,
              ),
            ),
            isDense: true,
          ),
      inputFormatters: widget.textInputFormatter == null ? null : [widget.textInputFormatter!],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:investapas/core/constants/constants.dart';

class CustomDropdown extends StatefulWidget {
  final selectedValue;
  final hintText;
  final items;
  final onTap;
  final onChanged;
  final Color? borderColor;
  const CustomDropdown(
      {Key? key,
      required this.selectedValue,
      required this.hintText,
      required this.items,
       this.onTap,
        this.borderColor = Colors.transparent,
      required this.onChanged})
      : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.all(color: Colorz.borderColor ,width: 1)
      ),
      alignment: Alignment.center,
      child: DropdownButtonFormField<String>(
        value: widget.selectedValue,
        isExpanded: true,
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Colorz.hintTextColor),
        style: AppTextStyles.small.copyWith(
          color: Colorz.textColor,
          height: 1.2,
        ),
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        hint: Text(
          widget.hintText,
          style: AppTextStyles.small.copyWith(color: Colorz.hintTextColor,fontSize: SizeConfig.smallerFont),
        ),
        items: widget.items,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
      ),
    );
  }
}

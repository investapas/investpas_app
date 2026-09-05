import 'package:flutter/material.dart';

import '../core/constants/constants.dart';

class CommonRadioBool extends StatelessWidget {
  final int? index;
  final GestureTapCallback? onTap;
  final bool? selectedIndex;
  const CommonRadioBool({super.key,this.onTap,this.index,this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onTap,
      child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selectedIndex! ? Colors.transparent : Colorz.borderColor),
              color: selectedIndex! ? Colorz.primary.withOpacity(0.18) :  Colors.transparent ),
          child:  selectedIndex! ? Icon(Icons.circle,
              color: Colorz.primary, size: 13) : null),
    );
  }
}


class CommonRadio extends StatelessWidget {
  final int? index,selectedIndex;
  final GestureTapCallback? onTap;
  const CommonRadio({super.key,this.onTap,this.index,this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onTap,
      child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: index == selectedIndex ? Colors.transparent : Colorz.borderColor),
              color: selectedIndex == null?  Colors.transparent :index == selectedIndex ? Colorz.primary.withOpacity(0.18) : Colors.transparent),
          child: selectedIndex != null && index == selectedIndex ? Icon(Icons.circle,
              color: Colorz.primary, size: 13) : null),
    );
  }
}
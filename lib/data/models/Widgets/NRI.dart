import 'package:flutter/material.dart';

import 'IconLabel.dart';

///[Navigation Rail Item] is a class, to hold the icon, text, page of the navigation rail menu
class NRI extends IconLabel {
  ///Page to be opened on selection
  final Widget page;

  ///When enabled, on clicking the specific page, the drawer will be hidden automatically
  final bool autoHideDrawer;

  ///Width of the page
  final double? width;

  ///Constructor
  const NRI({
    required super.icon,
    required super.label,
    required this.page,
    this.autoHideDrawer = false,
    this.width,
  });

  ///Creates an [NRI] without icon. Usage: TabView
  factory NRI.iconLabel({required String label, required Widget page, double? width}) {
    return NRI(
      icon: Icons.brightness_1,
      label: label,
      page: page,
      width: width,
    );
  }

  ///Used to show a divider between a group of menus
  static const NRI divider = NRI(
      icon: Icons.linear_scale_outlined,
      label: 'Divider',
      page: CircleAvatar(
        backgroundColor: Colors.transparent,
      ));

  ///Checks if the given NRI is a divider or not
  bool get isDivider => this == divider;

  @override
  List<dynamic> get props => <dynamic>[
        page,
        autoHideDrawer,
        width,
      ];
}

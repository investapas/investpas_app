import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

///A simple class to hold the icon, text, color data to be used in any widget/page
class IconLabel extends Equatable {
  ///Primary icon to be shown
  final IconData icon;

  ///Primary text to be shown either on tooltip or in any other text widgets
  final String label;

  ///Optional color of the title & icon
  final Color? color;

  ///Extra details about the [label]
  final String? description;

  ///Optional function to be executed instead of default onPressed operation
  final VoidCallback? onTap;

  ///Constructor
  const IconLabel(
      {required this.icon, required this.label, this.description, this.color, this.onTap});

  ///When a data is not returned properly, this will be returned
  static IconLabel invalid = const IconLabel(icon: Icons.help, label: 'Unknown');

  @override
  List<dynamic> get props => <dynamic>[icon, label, color, description, onTap];
  @override
  String toString() {
    return label;
  }
}

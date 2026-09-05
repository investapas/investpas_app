

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A simple class to hold the rich text data to be used in any widget/page
class RichString extends Equatable{
  /// child
  final dynamic child;
  /// font weight
  final FontWeight? fontWeight;
  /// font size
  final double? fontSize;
  /// font style
  final FontStyle? fontStyle;
  /// color
  final Color? color;
  /// lineThrough text
  final bool lineThrough;
  /// underline text
  final bool underline;
  /// onTap
  final VoidCallback? onTap;
  /// constructor
  const RichString(this.child, {this.fontWeight, this.fontSize, this.fontStyle, this.color, this.onTap,
  this.underline=false,this.lineThrough=false,});

  @override
  List<dynamic> get props => <dynamic>[child, fontWeight, fontSize, fontStyle, color, onTap, lineThrough,underline];

  @override
  /// Returns a string representation of the `child` property.
  ///
  /// This method calls the `toString()` method of the `child` object and returns the result as a string.
  ///
  /// Returns:
  ///   A string representation of the `child` property.
  String toString(){
   return child.toString();
  }
}

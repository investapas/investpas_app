part of './Extensions.dart';

///Color extension
extension ColorExtension on Color? {
  ///Returns Black or While color better readablity for this backgroundColor
  Color get readable =>
      (this ?? Colors.grey).computeLuminance() > 0.35 ? Colors.black : Colors.white;

  ///It returns the [darken Color] of the given [color] with the [value] adjustment.
  ///Usage: [0.1] is too dark & [1] is too light.
  ///There are no identified [value], which returns the [original] color
  ///And the [result] will be changing for diffrent [color] inputs.
  Color dark([double value = 0.45]) =>
      HSLColor.fromColor(this ?? Colors.grey).withLightness(value).toColor();
}

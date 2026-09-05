///A label class which is used in [ListCard] which is used in [ListView]
class Label {
  ///Title to be shown in table header
  final dynamic title;

  ///Content to be shown in table elements
  final dynamic content;

  ///Width of the label
  final double? width;

  ///Constructor
  const Label(this.title, this.content, {this.width});
}

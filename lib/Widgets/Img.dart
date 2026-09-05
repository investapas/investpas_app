part of './Widgets.dart';

/// view image widget of app
class Img extends StatefulWidget {
  /// image url
  final String imgUrl;
  /// height of image widget
  final double? height;
  /// width of image widget
  final double? width;
  /// no Image placeHolder widget
  final Widget? placeHolder;
  /// error image widget
  final Widget? errorWidget;
  /// image fit with the box
  final BoxFit? fit;
  /// image alignment
  final Alignment? alignment;
  /// onTap image
  final VoidCallback? onTap;
  /// child of image widget
  final Widget? child;
  /// outer padding of image
  final double? outterPadding;
  /// radius of image widget
  final double radius;
  /// color of image
  final Color? imgColor;
  /// elevation of image widget
  final double? elevation;
  /// enable effect
  final bool enableRippleEffect;
  /// constructor
  const Img({
    super.key,
    required this.imgUrl,
    this.height,
    this.width,
    this.placeHolder,
    this.errorWidget,
    this.fit,
    this.alignment,
    this.onTap,
    this.child,
    this.outterPadding,
    this.radius = 8,
    this.imgColor,
    this.elevation,
    this.enableRippleEffect = true,
  });
  @override
  _ImgState createState() => _ImgState();
}

class _ImgState extends State<Img> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final BorderRadius borderRadius = BorderRadius.circular(widget.radius,);
    return Inkk(
      onTap: widget.onTap ?? viewImageFn,
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: EdgeInsets.all(widget.outterPadding ?? 0),
        child: Material(
            elevation: widget.elevation ?? 1.5,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            color: widget.imgColor,
            child: imgWidget()),
      ),
    );
  }

  Widget imgWidget() {
    final Widget imgWidget = CachedNetworkImage(
      imageUrl: widget.imgUrl,
      fit: widget.fit ?? BoxFit.fill,
      height: widget.height,
      width: widget.width,
      progressIndicatorBuilder: placeholder,
      errorWidget: errorWidget,
    );
    return Stack(
      clipBehavior: Clip.antiAlias,
      alignment: widget.alignment ?? Alignment.center,
      children: <Widget>[
        if (widget.enableRippleEffect) Inkk(
                onTap: widget.onTap ?? () {},
                radius: widget.radius,
                child: imgWidget,
              ) else imgWidget,
        if (widget.child != null) widget.child!,
      ],
    );
  }

  Widget placeholder(BuildContext c,String s, dynamic e) {
    return widget.placeHolder ?? background(false);
  }

  Widget errorWidget(BuildContext c, String s, dynamic e) {
    return widget.errorWidget ?? background(true);
  }

  Widget background(bool error) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: error ? const Icon(Icons.error, size: 100) : const CircularProgressIndicator(),
    );
  }

  void viewImageFn() {
    Widgets.push(
        Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CachedNetworkImage(
              imageUrl: widget.imgUrl,
              width: double.maxFinite,
              placeholder: (
                BuildContext c,
                String s,
              ) =>
                  placeholder(c, s, s),
              errorWidget: errorWidget,
            ),
          ),
        ),
        context);
  }
}

part of 'Widgets.dart';

/// view App Image
class ViewAppImage extends StatelessWidget {
  /// image url
  final String? imageUrl;
  /// image file
  final XFile? imageFile;
  /// assets images
  final String? assetsUrl,emptyAssetUrl;
  /// height of the image
  final double? height;
  /// width of the image
  final double? width;
  /// radius of the image
  final double radius;
  /// border Radius of the image
  final BorderRadius? borderRadius;
  /// fit with image
  final BoxFit? fit;
  /// color of the image
  final Color? color;
/// constructor
  const ViewAppImage({super.key, this.fit,this.imageUrl,this.emptyAssetUrl,this.width,this.height,this.radius=0.0,this.assetsUrl,this.imageFile,this.borderRadius,this.color});
  @override
  Widget build(BuildContext context) {
    final double screenWidth=MediaQuery.of(context).size.width;
    final double screenHeight=MediaQuery.of(context).size.height;
    return ClipRRect(
      borderRadius: borderRadius??BorderRadius.all(Radius.circular(radius)),
      child: imageFile!=null?Container(
        width: width,height: height,
        decoration: BoxDecoration(
            image: DecorationImage(image: FileImage(File(imageFile!.path)),fit: fit??BoxFit.cover,),
            borderRadius:  const BorderRadius.all(Radius.circular(10))
        ),
      ):SizedBox(
        width: width??screenWidth,height: height??screenHeight,
        child: imageUrl!=null&&imageUrl!=''?CachedNetworkImage(imageUrl:imageUrl!,
          errorWidget: (BuildContext context, String url, Object error) =>
              Image.asset(assetsUrl!=null?assetsUrl!:(emptyAssetUrl??Assets.noPhoto),fit: fit??BoxFit.contain,
            color: color,),
          fit: BoxFit.cover,
          placeholder: (BuildContext context, String url) => Widgets.loader(
            size: 40
          ),):Image.asset(assetsUrl!=null?assetsUrl!:(emptyAssetUrl??Assets.noPhoto),fit:fit?? BoxFit.contain,
          color: color,),
      ),
    );
  }
}

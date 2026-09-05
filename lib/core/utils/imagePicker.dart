import 'package:image_picker/image_picker.dart';

/// image picker service
class ImagePickerService {
  ImagePickerService._();
  /// Retrieves an image from the specified source.
  ///
  /// - Parameters:
  ///   - source: The source from which the image should be retrieved.
  /// - Returns:
  ///   - A `Future` that completes with an `XFile` object representing the
  ///     selected image, or `null` if no image was selected.
  static Future<XFile?> getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
    );
    return image;
  }
}
